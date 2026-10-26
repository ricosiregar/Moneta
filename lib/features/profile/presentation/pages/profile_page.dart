import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/components/app_toast.dart';
import '../../../../core/components/fun_widgets.dart';
import '../../../../core/components/app_glass_dialog.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../categories/presentation/pages/categories_manage_page.dart';
import '../../../notifications/presentation/pages/notification_settings_page.dart';
import '../../../wallets/presentation/pages/wallets_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/profile_cubit.dart';

/// Akun page — static UI matching React. Only profile name/email and
/// logout stay wired to the auth flow.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileCubit _cubit = getIt<ProfileCubit>();
  String get _cachedName => _cubit.state.cachedName;
  String get _cachedEmail => _cubit.state.cachedEmail;

  @override
  void initState() {
    super.initState();
    _cubit.stream.listen((_) {
      if (mounted) setState(() {});
    });
    _cubit.loadCached();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showLogoutSheet(BuildContext context) {
    AppGlassDialog.show(
      context: context,
      icon: Icons.logout_rounded,
      title: 'Keluar dari akun?',
      message: 'Kamu akan diarahkan ke halaman login.',
      confirmLabel: 'Keluar',
      isDestructive: true,
      onConfirm: () {
        context.read<AuthBloc>().add(const LogoutRequested());
      },
    );
  }

  void _showClearSheet(BuildContext context) {
    AppGlassDialog.show(
      context: context,
      icon: Icons.delete_outline_rounded,
      title: 'Hapus semua data?',
      message: 'Semua transaksi dan dompet lokal akan dihapus permanen.',
      confirmLabel: 'Hapus Semua',
      isDestructive: true,
      onConfirm: () {
        _run(_cubit.clearAll, success: 'Semua data dihapus');
      },
    );
  }

  Future<void> _run(
    Future<Either<Failure, void>> Function() action, {
    String? success,
  }) async {
    final r = await action();
    if (!mounted) return;
    r.fold((f) => AppToast.showError(context, f.message), (_) {
      if (success != null) AppToast.showSuccess(context, success);
    });
  }

  Future<void> _importJson() async {
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      final bytes = picked?.files.single.bytes;
      if (bytes == null) return;
      final r = await _cubit.importJson(utf8.decode(bytes));
      if (!mounted) return;
      r.fold(
        (f) => AppToast.showError(context, f.message),
        (n) => AppToast.showSuccess(
          context,
          '$n data dipulihkan. Tekan sinkron untuk mengirim ke cloud.',
        ),
      );
    } catch (e) {
      if (mounted) AppToast.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.user?.fullName != curr.user?.fullName ||
          prev.user?.email != curr.user?.email,
      listener: (context, state) {
        final name = state.user?.fullName ?? '';
        final email = state.user?.email ?? '';
        _cubit.updateFromAccount(name: name, email: email);
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final String fullName = state.user?.fullName?.isNotEmpty == true
              ? state.user!.fullName!
              : _cachedName;
          final String email = (state.user?.email ?? '').isNotEmpty
              ? state.user!.email
              : _cachedEmail;
          final String name = fullName.isNotEmpty
              ? fullName
              : (email.contains('@')
                    ? email.split('@').first
                    : 'Pengguna Moneta');
          final parts = name.trim().split(RegExp(r'\s+'));
          final String initial =
              (parts.length > 1
                      ? '${parts[0][0]}${parts[1][0]}'
                      : name.substring(0, name.length >= 2 ? 2 : 1))
                  .toUpperCase();
          final String displayEmail = email.isNotEmpty
              ? email
              : 'Belum terhubung';

          return GlassPage(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FunPageHeader(
                    title: 'Akun',
                    subtitle: 'Kelola data dan preferensi',
                  ),
                  const SizedBox(height: 20),
                  FunCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: auroraActiveDecoration(radius: 16),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.inkPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displayEmail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Section('Wallet', Icons.credit_card_outlined, [
                    _Row(
                      Icons.account_balance_wallet_outlined,
                      'Kelola Dompet',
                      'Dompet Parent, anak, dan pembagian gaji',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WalletsPage()),
                      ),
                    ),
                    _Row(
                      Icons.category_outlined,
                      'Atur Kategori',
                      'Kelola & tambah kategori transaksi kustom',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CategoriesManagePage(),
                        ),
                      ),
                    ),
                    _Row(
                      Icons.notifications_active_outlined,
                      'Deteksi Otomatis',
                      'Baca transaksi dari notifikasi bank',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsPage(),
                        ),
                      ),
                    ),
                  ]),

                  _Section('Data & Backup', Icons.cloud_outlined, [
                    _Row(
                      Icons.file_download_outlined,
                      'Ekspor JSON',
                      'Simpan semua data',
                      onTap: () => _run(_cubit.exportJson),
                    ),
                    _Row(
                      Icons.file_upload_outlined,
                      'Impor JSON',
                      'Pulihkan dari berkas cadangan',
                      onTap: _importJson,
                    ),
                    _Row(
                      Icons.table_chart_outlined,
                      'Ekspor CSV',
                      'Buka di spreadsheet',
                      onTap: () => _run(_cubit.exportCsv),
                    ),
                    _Row(
                      Icons.delete_outline_rounded,
                      'Hapus semua data',
                      'Tindakan ini tidak bisa dibatalkan',
                      onTap: () => _showClearSheet(context),
                    ),
                  ]),
                  _Section('Akun', Icons.person_outline_rounded, [
                    _Row(
                      Icons.logout_rounded,
                      'Keluar dari Akun',
                      'Kamu akan diarahkan ke halaman login',
                      onTap: () => _showLogoutSheet(context),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Moneta v1.0',
                      style: TextStyle(fontSize: 11, color: AppColors.inkMuted),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Row> rows;
  const _Section(this.title, this.icon, this.rows);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: glassFill(context),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  child: Icon(icon, size: 12, color: AppColors.accentBlue),
                ),
                const SizedBox(width: 8),
                FunLabel(title),
              ],
            ),
          ),
          FunCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  rows[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback? onTap;
  const _Row(this.icon, this.label, this.sub, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconBox(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
