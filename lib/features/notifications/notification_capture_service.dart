import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

import '../../core/database/detected_repository.dart';
import 'bank_parser.dart';

/// Menangkap notifikasi bank (Android) dan menyimpannya ke inbox
/// `detected_transactions`. Hanya hasil parsing yang disimpan; teks notifikasi
/// mentah tidak pernah ditulis ke database.
///
/// Batasan: plugin mengirim event lewat engine Flutter, jadi notifikasi yang
/// datang saat app benar-benar tertutup baru terbaca saat app dibuka lagi
/// (lewat [scanActive], selama notifikasinya masih ada di tray).
class NotificationCaptureService {
  NotificationCaptureService(this._repo);

  final DetectedRepository _repo;
  StreamSubscription<ServiceNotificationEvent>? _sub;

  bool get isSupported => !kIsWeb && Platform.isAndroid;
  bool get isListening => _sub != null;

  Future<bool> isPermissionGranted() async =>
      isSupported && await NotificationListenerService.isPermissionGranted();

  Future<bool> requestPermission() async =>
      isSupported && await NotificationListenerService.requestPermission();

  /// Mulai mendengarkan bila fitur aktif dan izin sudah diberikan.
  Future<void> start() async {
    if (!isSupported || _sub != null) return;
    if (!await _repo.isCaptureEnabled()) return;
    if (!await NotificationListenerService.isPermissionGranted()) return;

    _sub = NotificationListenerService.notificationsStream.listen(
      _handle,
      onError: (Object e) => debugPrint('Notification stream error: $e'),
    );
    await scanActive();
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  static const MethodChannel _channel =
      MethodChannel('x-slayer/notifications_channel');

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
        final e = ServiceNotificationEvent(
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
    if (source == null) return;

    final parsed = parseBankNotification(
      e.title,
      e.content,
      parserKey: source.parserKey,
    );
    if (parsed == null) return;

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
      walletId: source.walletId,
      sourcePackage: pkg,
      amount: parsed.amount,
      type: parsed.type,
      merchant: parsed.merchant,
      detectedAt: postedAt,
    );
  }
}
