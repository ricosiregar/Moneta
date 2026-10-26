import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

import '../../../../core/database/detected_repository.dart';
import 'bank_parser.dart';

/// Menangkap notifikasi bank (Android) dan menyimpannya ke inbox
/// `detected_transactions`. Hanya hasil parsing yang disimpan; teks notifikasi
/// mentah tidak pernah ditulis ke database.
///
/// Notifikasi yang datang saat app tertutup total ditangkap oleh service
/// native (`MonetaNotificationListener`) ke antrean di penyimpanan Android,
/// lalu dibaca di sini lewat [drainQueue] saat app dibuka / kembali aktif.
/// Daftar paket yang disimpan native dikirim lewat [syncAllowedPackages].
class NotificationCaptureService {
  NotificationCaptureService(this._repo, {bool? supportedOverride})
      : _supportedOverride = supportedOverride;

  final DetectedRepository _repo;
  final bool? _supportedOverride;
  StreamSubscription<ServiceNotificationEvent>? _sub;
  StreamSubscription<dynamic>? _configSub;
  _ResumeHook? _hook;

  bool get isSupported =>
      _supportedOverride ?? (!kIsWeb && Platform.isAndroid);
  bool get isListening => _sub != null;

  Future<bool> isPermissionGranted() async =>
      isSupported && await NotificationListenerService.isPermissionGranted();

  Future<bool> requestPermission() async =>
      isSupported && await NotificationListenerService.requestPermission();

  /// Mulai mendengarkan bila fitur aktif dan izin sudah diberikan.
  Future<void> start() async {
    if (!isSupported) return;
    // Selalu beri tahu native paket mana yang boleh disimpan (kosong bila
    // fitur dimatikan), dan ikuti perubahan sumber/saklar selama app hidup.
    await syncAllowedPackages();
    _configSub ??= _repo.watchSources().listen((_) => syncAllowedPackages());
    if (!await _repo.isCaptureEnabled()) return;
    if (!await NotificationListenerService.isPermissionGranted()) return;

    _sub ??= NotificationListenerService.notificationsStream.listen(
      _handle,
      onError: (Object e) => debugPrint('Notification stream error: $e'),
    );
    _hook ??= _ResumeHook(drainQueue)..attach();
    await drainQueue();
    await scanActive();
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await syncAllowedPackages();
  }

  static const MethodChannel _channel =
      MethodChannel('x-slayer/notifications_channel');
  static const MethodChannel _queue =
      MethodChannel('moneta/notification_queue');

  /// Status listener native: tersambung, bebas pembatasan baterai, antrean.
  Future<ListenerStatus> getStatus() async {
    if (!isSupported) return const ListenerStatus();
    try {
      final m = await _queue.invokeMapMethod<String, dynamic>('status');
      if (m == null) return const ListenerStatus();
      return ListenerStatus(
        connected: m['connected'] == true,
        ignoringBattery: m['ignoringBattery'] == true,
        queued: (m['queued'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      debugPrint('getStatus error: $e');
      return const ListenerStatus();
    }
  }

  Future<void> openBatterySettings() async {
    if (isSupported) await _queue.invokeMethod<void>('openBatterySettings');
  }

  Future<void> openAppSettings() async {
    if (isSupported) await _queue.invokeMethod<void>('openAppSettings');
  }

  /// Kirim daftar paket sumber aktif ke native. Kosong bila fitur mati.
  Future<void> syncAllowedPackages() async {
    if (!isSupported) return;
    try {
      final enabled = await _repo.isCaptureEnabled();
      final pkgs = enabled
          ? <String>{
              for (final k in knownBankPackages) k.$2,
              for (final s in await _repo.getEnabledSources()) s.packageName,
            }.toList()
          : <String>[];
      await _queue.invokeMethod<void>('setAllowedPackages', pkgs);
    } catch (e) {
      debugPrint('syncAllowedPackages error: $e');
    }
  }

  /// Baca notifikasi yang ditangkap service native saat app tertutup.
  Future<void> drainQueue() async {
    if (!isSupported) return;
    try {
      final raw = await _queue.invokeMethod<List<dynamic>>('drain');
      if (raw == null || raw.isEmpty) return;
      for (final item in raw) {
        if (item is! Map) continue;
        await _handle(_eventFromMap(Map<dynamic, dynamic>.from(item)));
      }
    } catch (e) {
      debugPrint('drainQueue error: $e');
    }
  }

  ServiceNotificationEvent _eventFromMap(Map<dynamic, dynamic> map) =>
      ServiceNotificationEvent(
        id: map['id'] ?? 0,
        canReply: map['canReply'] ?? false,
        haveExtraPicture: map['haveExtraPicture'] ?? false,
        hasRemoved: map['hasRemoved'] ?? false,
        packageName: (map['packageName'] ?? '').toString(),
        title: (map['title'] ?? '').toString(),
        content: (map['content'] ?? '').toString(),
        onGoing: map['onGoing'] ?? false,
        timestamp: map['postTime'] ?? 0,
        appIcon: map['appIcon'],
        extrasPicture: map['notificationExtrasPicture'],
        largeIcon: map['largeIcon'],
      );

  /// Baca notifikasi yang masih ada di tray (menutup celah saat app tertutup).
  Future<void> scanActive() async {
    if (!isSupported) return;
    try {
      final List<dynamic>? rawList =
          await _channel.invokeMethod<List<dynamic>>('getActiveNotifications');
      if (rawList == null || rawList.isEmpty) return;

      for (final raw in rawList) {
        if (raw is! Map) continue;
        final map = Map<dynamic, dynamic>.from(raw);
        // Workaround bug plugin notification_listener_service:
        // getActiveNotifications pada Android tidak menyertakan 'haveExtraPicture',
        // sehingga ServiceNotificationEvent.fromMap melempar 'Null is not a subtype of bool'.
        final e = _eventFromMap(map);
        await _handle(e);
      }
    } catch (e) {
      debugPrint('scanActive error: $e');
    }
  }

  Future<void> _handle(ServiceNotificationEvent e) async {
    if (e.hasRemoved == true || e.onGoing == true) return;
    final pkg = e.packageName;
    if (pkg.isEmpty) return;

    final sources = await _repo.getEnabledSources();
    final source = sources.where((s) => s.packageName == pkg).firstOrNull;
    final isKnownBank = bankLabelForPackage(pkg) != null;
    if (source == null && !isKnownBank) return;

    final parsed = parseBankNotification(
      e.title,
      e.content,
      parserKey: source?.parserKey ?? 'generic',
    );
    if (parsed == null) return;

    final walletId = await _repo.resolveWalletIdForPackage(pkg);

    // Event live bisa datang tanpa timestamp (0). Pakai waktu sekarang agar
    // fingerprint tidak bertabrakan antar notifikasi berbeda; duplikat
    // sungguhan disaring oleh jendela waktu di DetectedRepository.addDetected.
    final ts = e.timestamp > 0
        ? e.timestamp
        : DateTime.now().millisecondsSinceEpoch;
    final postedAt = DateTime.fromMillisecondsSinceEpoch(ts);

    await _repo.addDetected(
      // Stabil untuk notifikasi yang sama (tidak ganda saat dibaca ulang).
      fingerprint: '$pkg|$ts|${e.id}|${parsed.amount}|${parsed.type}',
      walletId: walletId,
      sourcePackage: pkg,
      amount: parsed.amount,
      type: parsed.type,
      merchant: parsed.merchant,
      detectedAt: postedAt,
    );
  }
}

/// Memicu [drainQueue] setiap app kembali ke foreground.
class _ResumeHook with WidgetsBindingObserver {
  _ResumeHook(this._onResume);

  final Future<void> Function() _onResume;

  void attach() => WidgetsBinding.instance.addObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onResume();
  }
}

/// Kondisi listener native, untuk diagnosa di layar pengaturan.
class ListenerStatus {
  const ListenerStatus({
    this.connected = false,
    this.ignoringBattery = false,
    this.queued = 0,
  });

  /// Listener sedang tersambung ke sistem notifikasi Android.
  final bool connected;

  /// App dikecualikan dari penghematan baterai (lebih jarang dimatikan).
  final bool ignoringBattery;

  /// Jumlah notifikasi menunggu dibaca.
  final int queued;
}
