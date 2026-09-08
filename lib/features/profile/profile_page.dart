import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_event.dart';
import '../auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _cachedName = '';
  String _cachedEmail = '';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
  }

  /// Baca nama & email dari SharedPreferences (cache offline)
  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _cachedName = prefs.getString('user_name') ?? '';
        _cachedEmail = prefs.getString('saved_email') ?? '';
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Keluar Akun",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari akun Moneta Anda?",
          style: TextStyle(fontSize: 14, color: Color(0xFF636366)),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              "Batal",
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63946),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: const Text(
              "Keluar",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Sinkronisasi cache lokal saat AuthBloc update user
      listenWhen: (prev, curr) =>
          prev.user?.fullName != curr.user?.fullName ||
          prev.user?.email != curr.user?.email,
      listener: (context, state) {
        final name = state.user?.fullName ?? '';
        final email = state.user?.email ?? '';
        if (mounted) {
          setState(() {
            if (name.isNotEmpty) _cachedName = name;
            if (email.isNotEmpty) _cachedEmail = email;
          });
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Prioritas: AuthBloc (online) → SharedPreferences (offline cache)
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
                    : "Pengguna Moneta");
          final String initial = name.isNotEmpty
              ? name.substring(0, 1).toUpperCase()
              : "M";
          final String displayEmail = email.isNotEmpty
              ? email
              : "Belum terhubung";

          return Scaffold(
            backgroundColor: AppColors.bgOffWhite,
            body: SingleChildScrollView(
              child: Column(
              children: [
                // Top Header with Yellow Gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                  decoration: const BoxDecoration(
                    gradient: AppColors.yellowGradient,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Settings List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildSettingsCard(
                        title: "Pengaturan Akun",
                        items: [
                          _buildSettingsTile(
                            icon: Icons.person_outline_rounded,
                            title: "Edit Profil",
                            subtitle: "Ubah nama dan informasi akun",
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildSettingsTile(
                            icon: Icons.shield_outlined,
                            title: "Keamanan Akun",
                            subtitle: "Ganti kata sandi & 2FA",
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildSettingsTile(
                            icon: Icons.notifications_none_rounded,
                            title: "Notifikasi",
                            subtitle: "Atur pengingat anggaran dan transaksi",
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildSettingsCard(
                        title: "Aplikasi",
                        items: [
                          _buildSettingsTile(
                            icon: Icons.language_rounded,
                            title: "Bahasa",
                            subtitle: "Bahasa Indonesia",
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildSettingsTile(
                            icon: Icons.help_outline_rounded,
                            title: "Pusat Bantuan & FAQ",
                            subtitle: "Panduan pemakaian Moneta",
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      InkWell(
                        onTap: () => _showLogoutDialog(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECEE),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFCDD2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFE63946),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Keluar dari Akun",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE63946),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
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

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.toggleBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.textDark, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFC7C7CC),
        size: 22,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      endIndent: 16,
      color: Color(0xFFF2F2F7),
    );
  }
}
