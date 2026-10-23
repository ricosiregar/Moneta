import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/app_glass_sheet.dart';
import '../../../../core/components/app_toast.dart';
import '../../../../core/components/fun_widgets.dart';
import '../../../../core/utils/usecase.dart';
import '../../../wallets/domain/entities/wallet_entity.dart';
import '../../../wallets/domain/usecases/wallet_usecases.dart';
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
              FunPill(
                label: 'Muat ulang status',
                selected: false,
                onTap: _refreshPermission,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addSource() async {
    final wallets = (await getIt<GetWalletsUseCase>()(
      const NoParams(),
    )).getOrElse(() => const <WalletEntity>[]);
    if (!mounted) return;
    if (wallets.isEmpty) {
      AppToast.showWarning(context, 'Buat dompet dulu di halaman Dompet');
      return;
    }
    await AppGlassSheet.show(
      context: context,
      builder: (_) => _AddSourceSheet(cubit: _cubit, wallets: wallets),
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
                  FunRoundButton(
                    Icons.add_rounded,
                    size: 40,
                    onTap: _addSource,
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
                      child: BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
                        bloc: _cubit,
                        builder: (context, settings) {
                          final on = settings.captureEnabled;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Aktifkan deteksi',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
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
                                'Yang disimpan permanen hanya nominal, jenis, dan nama merchant. '
                                'Teks notifikasi hanya ditahan sementara sampai dibaca, lalu dihapus. Notifikasi yang masuk '
                                'saat app tertutup ditangkap sistem dan dibaca '
                                'ketika app dibuka lagi.',
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
                    const FunLabel('Aplikasi yang dipantau'),
                    const SizedBox(height: 8),
                    BlocBuilder<
                      NotificationSettingsCubit,
                      NotificationSettingsState
                    >(
                      bloc: _cubit,
                      builder: (context, settings) {
                        final sources = settings.sources;
                        if (sources.isEmpty) {
                          return const FunCard(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  'Belum ada. Tekan + untuk menambah aplikasi bank.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return StreamBuilder(
                          stream: getIt<WatchWalletsUseCase>()(),
                          builder: (context, wsnap) {
                            final names = {
                              for (final w
                                  in wsnap.data?.getOrElse(
                                        () => const <WalletEntity>[],
                                      ) ??
                                      const <WalletEntity>[])
                                w.id: w.name,
                            };
                            return Column(
                              children: [
                                for (final s in sources)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: FunCard(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        8,
                                        8,
                                        8,
                                      ),
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
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  '→ ${names[s.walletId] ?? 'Dompet dihapus'}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.inkMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Switch(
                                            value: s.isEnabled,
                                            onChanged: (v) => _cubit
                                                .setSourceEnabled(s.id, v),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: AppColors.inkMuted,
                                            ),
                                            onPressed: () =>
                                                _cubit.deleteSource(s.id),
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
  final NotificationSettingsCubit cubit;
  final List<WalletEntity> wallets;
  const _AddSourceSheet({required this.cubit, required this.wallets});

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
    final r = await widget.cubit.addSource(
      packageName: pkg,
      walletId: _walletId,
    );
    if (!mounted) return;
    r.fold((f) => AppToast.showError(context, f.message), (_) => nav.pop());
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
            _Dropdown<String>(
              value: _package,
              enabled: _custom.text.trim().isEmpty,
              items: [
                for (final k in knownBankPackages)
                  DropdownMenuItem(value: k.$2, child: Text(k.$1)),
              ],
              onChanged: (v) => setState(() {
                _package = v;
                _custom.clear();
              }),
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
            _Dropdown<String>(
              value: _walletId,
              items: [
                for (final w in widget.wallets)
                  DropdownMenuItem(value: w.id, child: Text(w.name)),
              ],
              onChanged: (v) => setState(() => _walletId = v ?? _walletId),
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
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown bergaya kaca, dipakai di sheet tambah aplikasi.
class _Dropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xD9FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder, width: 1.2),
        ),
        child: Material(
          color: Colors.transparent,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              value: items.any((i) => i.value == value) ? value : null,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.accentBlue,
              ),
              borderRadius: BorderRadius.circular(16),
              dropdownColor: Colors.white,
              menuMaxHeight: 280,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.inkPrimary,
              ),
              items: items,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ),
    );
  }
}
