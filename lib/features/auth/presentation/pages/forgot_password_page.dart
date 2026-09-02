import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            ForgotPasswordSubmitted(
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  void _showSuccessDialog(String email) {
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
                    Icons.mark_email_read_rounded,
                    size: 38,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Tautan Terkirim!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Kami telah mengirimkan instruksi pemulihan kata sandi ke:\n$email\n\nSilakan periksa kotak masuk atau spam email Anda dan klik tautan untuk membuat kata sandi baru.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF636366),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryGradientButton(
                  text: "Kembali ke Login",
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/login');
                    }
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
        } else if (state.status == AuthStatus.passwordResetEmailSent) {
          _showSuccessDialog(_emailController.text.trim());
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
                  // TOP SECTION (Header with Back Button)
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
                              "Lupa Password",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Pulihkan akses akun Moneta Anda",
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
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: AppColors.accentExpense,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Masukkan alamat email yang terdaftar. Kami akan mengirimkan tautan untuk membuat kata sandi baru.",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF636366),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email Field
                              AuthTextField(
                                label: "Email Terdaftar",
                                hint: "nama@email.com",
                                controller: _emailController,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Email tidak boleh kosong";
                                  }
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value.trim())) {
                                    return "Format email tidak valid";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Submit Button
                              PrimaryGradientButton(
                                text: "Kirim Tautan Pemulihan",
                                onPressed:
                                    isLoading ? null : _onSendResetPressed,
                                isLoading: isLoading,
                              ),
                              const SizedBox(height: 24),

                              // Back to Login Link
                              Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go('/login');
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 18,
                                    color: AppColors.accentExpense,
                                  ),
                                  label: const Text(
                                    "Kembali ke Halaman Masuk",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentExpense,
                                    ),
                                  ),
                                ),
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
