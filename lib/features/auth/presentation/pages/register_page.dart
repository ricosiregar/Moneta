import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/components/components.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterSubmitted(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _onGoogleSignInPressed() {
    context.read<AuthBloc>().add(const GoogleSignInSubmitted());
  }

  void _showVerificationDialog(String email) {
    AppGlassDialog.show(
      context: context,
      barrierDismissible: false,
      showCancel: false,
      title: "Verifikasi Email Dikirim!",
      message:
          "Kami telah mengirimkan tautan konfirmasi ke:\n$email\n\nSilakan periksa kotak masuk atau spam email Anda dan klik tautan untuk mengaktifkan akun.",
      confirmLabel: "Masuk ke Akun",
      isDestructive: false,
      customIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.auroraHeaderGradient,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x150F172A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
      onConfirm: () {
        context.go('/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.errorMessage != null) {
          AppToast.showError(context, state.errorMessage);
        } else if (state.status == AuthStatus.registeredNeedsVerification) {
          final email = state.unverifiedEmail ?? _emailController.text.trim();
          _showVerificationDialog(email);
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: AuroraLoadingOverlay(
            isLoading: isLoading,
            child: Column(
              children: [
                // TOP SECTION (AuroraHeader with Back Button)
                AuroraHeader(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 52),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x120F172A),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.inkPrimary,
                            size: 18,
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/login');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Buat Akun Baru",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.inkPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Kelola finansial cerdas bersama Moneta",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // BOTTOM SECTION (Frosted Glass Platter)
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -36,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppColors.glassSheetGradient,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(36),
                            ),
                            border: Border.all(
                              color: AppColors.glassBorder,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x140F172A),
                                blurRadius: 28,
                                offset: Offset(0, -6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(36),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 28.0,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Full Name Field
                                      AuthTextField(
                                        label: "Nama Lengkap",
                                        hint: "Contoh: Alex Pratama",
                                        controller: _nameController,
                                        prefixIcon:
                                            Icons.person_outline_rounded,
                                        keyboardType: TextInputType.name,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Nama lengkap tidak boleh kosong";
                                          }
                                          if (value.trim().length < 2) {
                                            return "Nama minimal 2 karakter";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Email Field
                                      AuthTextField(
                                        label: "Email",
                                        hint: "nama@email.com",
                                        controller: _emailController,
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Email tidak boleh kosong";
                                          }
                                          if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(value.trim())) {
                                            return "Format email tidak valid";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Password Field
                                      AuthTextField(
                                        label: "Password",
                                        hint: "Minimal 6 karakter",
                                        controller: _passwordController,
                                        prefixIcon: Icons.lock_outline,
                                        isPassword: true,
                                        isPasswordVisible: _isPasswordVisible,
                                        onToggleVisibility: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Password tidak boleh kosong";
                                          }
                                          if (value.length < 6) {
                                            return "Password minimal 6 karakter";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Confirm Password Field
                                      AuthTextField(
                                        label: "Konfirmasi Password",
                                        hint: "Ulangi password Anda",
                                        controller: _confirmPasswordController,
                                        prefixIcon: Icons.lock_reset_rounded,
                                        isPassword: true,
                                        isPasswordVisible:
                                            _isConfirmPasswordVisible,
                                        onToggleVisibility: () {
                                          setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          });
                                        },
                                        textInputAction: TextInputAction.done,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Konfirmasi password tidak boleh kosong";
                                          }
                                          if (value !=
                                              _passwordController.text) {
                                            return "Konfirmasi password tidak cocok";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 28),

                                      // Register Button
                                      PrimaryGradientButton(
                                        text: "Daftar Sekarang",
                                        onPressed: isLoading
                                            ? null
                                            : _onRegisterPressed,
                                        isLoading: isLoading,
                                      ),
                                      const SizedBox(height: 24),

                                      // Divider
                                      const AuthDivider(
                                        label: "atau daftar dengan",
                                      ),
                                      const SizedBox(height: 20),

                                      // Google Sign In Button
                                      GoogleSignInButton(
                                        onPressed: isLoading
                                            ? null
                                            : _onGoogleSignInPressed,
                                        isLoading: isLoading,
                                      ),
                                      const SizedBox(height: 32),

                                      // Login Link Footer
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Sudah punya akun? ",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.inkSecondary,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              context.go('/login');
                                            },
                                            child: const Text(
                                              "Masuk Disini",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.accentBlue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
