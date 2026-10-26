import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/app_toast.dart';
import '../../../../core/components/fun_widgets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/bank_parser.dart';
import '../../data/services/notification_capture_service.dart';
import '../cubit/notification_settings_cubit.dart';
import '../cubit/notification_settings_state.dart';

/// Pengaturan deteksi transaksi dari notifikasi bank (Android).
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage>
    with WidgetsBindingObserver {
  late final NotificationSettingsCubit _cubit =
      getIt<NotificationSettingsCubit>()..start();
  NotificationCaptureService get _capture =>
      getIt<NotificationCaptureService>();

  bool _granted = false;
  ListenerStatus _status = const ListenerStatus();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cubit.close();
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
    final st = await _capture.getStatus();
    if (mounted) setState(() => _status = st);
  }

  Future<void> _toggle(bool on) async {
    if (on && !_granted) {
      await _capture.requestPermission(); // membuka pengaturan sistem
    }
    final r = await _cubit.setCaptureEnabled(on);
    if (!mounted) return;
    final failure = r.fold((f) => f.message, (_) => null);
    if (failure != null) {
      AppToast.showError(context, failure);
      return;
    }
    if (on) {
      await _refreshPermission();
    } else {
      await _capture.stop();
    }
  }

  Widget _statusRow(String label, bool ok, String okText, String badText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            size: 18,
            color: ok ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            ok ? okText : badText,
            style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    return FunCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status deteksi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          _statusRow('Izin akses notifikasi', _granted, 'Aktif', 'Belum'),
          _statusRow(
            'Listener sistem',
            _status.connected,
            'Tersambung',
            'Belum tersambung',
          ),
          _statusRow(
            'Penghematan baterai',
            _status.ignoringBattery,
            'Tanpa batasan',
            'Dibatasi',
          ),
          if (_status.queued > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${_status.queued} notifikasi menunggu dibaca.',
                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Agar notifikasi tetap tertangkap saat app tertutup, atur app ke '
            '"Tanpa batasan" baterai dan aktifkan Autostart (di Info aplikasi '
            'pada beberapa merek HP).',
            style: TextStyle(fontSize: 11, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FunPill(
                label: 'Pengaturan baterai',
                selected: false,
                onTap: _capture.openBatterySettings,
              ),
              FunPill(
                label: 'Info aplikasi',
                selected: false,
                onTap: _capture.openAppSettings,
              ),
            ],
          ),
        ],
      ),
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
                  FunRoundButton(
                    Icons.arrow_back_rounded,
                    size: 40,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: FunPageHeader(
                      title: 'Deteksi Otomatis',
                      subtitle: 'Baca transaksi dari notifikasi bank',
                    ),
                  ),
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
                      child:
                          BlocBuilder<
                            NotificationSettingsCubit,
                            NotificationSettingsState
                          >(
                            bloc: _cubit,
                            builder: (context, settings) {
                              final on = settings.captureEnabled;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            const Text(
                                              'Aktifkan deteksi',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.warningLight
                                                    .withValues(alpha: 0.9),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                border: Border.all(
                                                  color: AppColors.warning
                                                      .withValues(alpha: 0.35),
                                                ),
                                              ),
                                              child: const Text(
                                                'BETA',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.5,
                                                  color: AppColors.warning,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: on && _granted,
                                        onChanged: _capture.isSupported
                                            ? _toggle
                                            : null,
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
                                      fontSize: 12,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Fitur ini masih dalam tahap uji coba, '
                                    'data notifikasi tidak disimpan permanen ke database, '
                                    'tapi hanya membaca nominal, jenis, dan nama merchant saja.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                    ),
                    if (_capture.isSupported) ...[
                      const SizedBox(height: 16),
                      _statusCard(),
                    ],
                    const SizedBox(height: 16),
                    const FunLabel('Bank yang Dipantau Otomatis'),
                    const SizedBox(height: 8),
                    for (final (bankName, _) in knownBankPackages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FunCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.accentBlue.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_balance_outlined,
                                  size: 19,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  bankName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.inkPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    FunCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.accentBlue.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Jika ingin bank Anda masuk ke daftar ini, silakan hubungi developer.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
