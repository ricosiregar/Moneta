import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
            UpdatePasswordSubmitted(
              newPassword: _passwordController.text,
            ),
          );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    gradient: AppColors.yellowGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 38,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Password Diperbarui!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Kata sandi akun Anda telah berhasil diubah. Silakan masuk menggunakan kata sandi baru Anda.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF636366),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryGradientButton(
                  text: "Masuk Sekarang",
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              backgroundColor: const Color(0xFFE63946),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (state.status == AuthStatus.passwordUpdated) {
          _showSuccessDialog();
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.yellowGradient,
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
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.textDark,
                              size: 20,
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
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Amankan kembali akun Moneta Anda",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // BOTTOM SECTION (Form Container)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.bgOffWhite,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                      ),
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
                                    _isPasswordVisible = !_isPasswordVisible;
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
                                isPasswordVisible: _isConfirmPasswordVisible,
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
                                onPressed:
                                    isLoading ? null : _onSavePasswordPressed,
                                isLoading: isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
