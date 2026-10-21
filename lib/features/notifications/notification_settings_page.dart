import 'package:flutter/material.dart';

import '../../core/components/app_glass_sheet.dart';
import '../../core/components/app_toast.dart';
import '../../core/components/fun_widgets.dart';
import '../../core/database/detected_repository.dart';
import '../../core/database/wallet_repository.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import 'bank_parser.dart';
import 'notification_capture_service.dart';

/// Pengaturan deteksi transaksi dari notifikasi bank (Android).
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage>
    with WidgetsBindingObserver {
  DetectedRepository get _repo => getIt<DetectedRepository>();
  NotificationCaptureService get _capture => getIt<NotificationCaptureService>();

  bool _granted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    final g = await _capture.isPermissionGranted();
    if (mounted) setState(() => _granted = g);
    if (g) await _capture.start();
  }

  Future<void> _toggle(bool on) async {
    if (on && !_granted) {
      await _capture.requestPermission(); // membuka pengaturan sistem
    }
    await _repo.setCaptureEnabled(on);
    if (on) {
      await _refreshPermission();
    } else {
      await _capture.stop();
    }
  }

  Future<void> _addSource() async {
    final wallets = await getIt<WalletRepository>().watchWallets().first;
    if (!mounted) return;
    if (wallets.isEmpty) {
      AppToast.showWarning(context, 'Buat dompet dulu di halaman Dompet');
      return;
    }
    await AppGlassSheet.show(
      context: context,
      builder: (_) => _AddSourceSheet(repo: _repo, wallets: wallets),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: GlassPage(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  FunRoundButton(Icons.arrow_back_rounded,
                      size: 40, onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: FunPageHeader(
                      title: 'Deteksi Otomatis',
                      subtitle: 'Baca transaksi dari notifikasi bank',
                    ),
                  ),
                  FunRoundButton(Icons.add_rounded,
                      size: 40, onTap: _addSource),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _refreshPermission();
                  setState(() {});
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  FunCard(
                    padding: const EdgeInsets.all(16),
                    child: StreamBuilder<bool>(
                      stream: _repo.watchCaptureEnabled(),
                      builder: (context, snap) {
                        final on = snap.data ?? false;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text('Aktifkan deteksi',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800)),
                                ),
                                Switch(
                                  value: on && _granted,
                                  onChanged: _capture.isSupported ? _toggle : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              !_capture.isSupported
                                  ? 'Fitur ini hanya tersedia di Android.'
                                  : _granted
                                      ? 'Izin akses notifikasi sudah diberikan.'
                                      : 'Perlu izin "Akses notifikasi" di pengaturan sistem.',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.inkMuted),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Hanya nominal, jenis, dan nama merchant yang disimpan. '
                              'Isi notifikasi tidak disimpan. Notifikasi yang masuk '
                              'saat app tertutup dibaca ketika app dibuka lagi.',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.inkMuted),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FunLabel('Aplikasi yang dipantau'),
                  const SizedBox(height: 8),
                  StreamBuilder<List<SourceView>>(
                    stream: _repo.watchSources(),
                    builder: (context, snap) {
                      final sources = snap.data ?? const <SourceView>[];
                      if (sources.isEmpty) {
                        return const FunCard(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: Text(
                                'Belum ada. Tekan + untuk menambah aplikasi bank.',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.inkMuted),
                              ),
                            ),
                          ),
                        );
                      }
                      return StreamBuilder<List<WalletView>>(
                        stream: getIt<WalletRepository>().watchWallets(),
                        builder: (context, wsnap) {
                          final names = {
                            for (final w in wsnap.data ?? const <WalletView>[])
                              w.id: w.name,
                          };
                          return Column(
                            children: [
                              for (final s in sources)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: FunCard(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 8, 8, 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _label(s.packageName),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              Text(
                                                '→ ${names[s.walletId] ?? 'Dompet dihapus'}',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.inkMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: s.isEnabled,
                                          onChanged: (v) =>
                                              _repo.setSourceEnabled(s.id, v),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: AppColors.inkMuted),
                                          onPressed: () =>
                                              _repo.deleteSource(s.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  String _label(String pkg) {
    for (final k in knownBankPackages) {
      if (k.$2 == pkg) return k.$1;
    }
    return pkg;
  }
}

class _AddSourceSheet extends StatefulWidget {
  final DetectedRepository repo;
  final List<WalletView> wallets;
  const _AddSourceSheet({required this.repo, required this.wallets});

  @override
  State<_AddSourceSheet> createState() => _AddSourceSheetState();
}

class _AddSourceSheetState extends State<_AddSourceSheet> {
  String? _package = knownBankPackages.first.$2;
  late String _walletId = widget.wallets.first.id;
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pkg = _custom.text.trim().isNotEmpty ? _custom.text.trim() : _package;
    if (pkg == null) return;
    final nav = Navigator.of(context);
    await widget.repo.upsertSource(packageName: pkg, walletId: _walletId);
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppGlassSheet(
      title: 'Tambah Aplikasi',
      subtitle: 'Pilih bank atau e-wallet untuk dideteksi',
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FunLabel('Aplikasi'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final k in knownBankPackages)
                  FunPill(
                    label: k.$1,
                    selected: _package == k.$2 && _custom.text.isEmpty,
                    onTap: () => setState(() {
                      _package = k.$2;
                      _custom.clear();
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: glassFill(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: _custom,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'atau ketik package name lain',
                  hintStyle: TextStyle(color: AppColors.inkMuted, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const FunLabel('Catat ke dompet'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final w in widget.wallets)
                  FunPill(
                    label: w.name,
                    selected: _walletId == w.id,
                    onTap: () => setState(() => _walletId = w.id),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _save,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryButtonGradient,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0x66FFFFFF),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x332563EB),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text('Simpan',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
