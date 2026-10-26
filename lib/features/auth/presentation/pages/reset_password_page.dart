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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSavePasswordPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        UpdatePasswordSubmitted(newPassword: _passwordController.text),
      );
    }
  }

  void _showSuccessDialog() {
    AppGlassDialog.show(
      context: context,
      barrierDismissible: false,
      showCancel: false,
      title: "Password Diperbarui!",
      message:
          "Kata sandi akun Anda telah berhasil diubah. Silakan masuk menggunakan kata sandi baru Anda.",
      confirmLabel: "Masuk Sekarang",
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
        child: const Icon(
          Icons.lock_reset_rounded,
          size: 32,
          color: AppColors.inkPrimary,
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
        } else if (state.status == AuthStatus.passwordUpdated) {
          _showSuccessDialog();
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Scaffold(
          body: AuroraLoadingOverlay(
            isLoading: isLoading,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.auroraHeaderGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // TOP SECTION (Header)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
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
                                context.go('/login');
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Buat Password Baru",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.inkPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Amankan kembali akun Moneta Anda",
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Password Field
                                    AuthTextField(
                                      label: "Password Baru",
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
                                          return "Password baru tidak boleh kosong";
                                        }
                                        if (value.length < 6) {
                                          return "Password minimal 6 karakter";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 18),

                                    // Confirm Password Field
                                    AuthTextField(
                                      label: "Konfirmasi Password Baru",
                                      hint: "Ulangi password baru Anda",
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
                                        if (value != _passwordController.text) {
                                          return "Konfirmasi password tidak cocok";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 32),

                                    // Submit Button
                                    PrimaryGradientButton(
                                      text: "Simpan Password Baru",
                                      onPressed: isLoading
                                          ? null
                                          : _onSavePasswordPressed,
                                      isLoading: isLoading,
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
            ),
          ),
        );
      },
    );
  }
}
