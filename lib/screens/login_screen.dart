import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:match_up_sports/routes/app_router.dart';
import 'package:match_up_sports/theme/app_theme.dart';
import 'package:match_up_sports/widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulação de login (integrar com API futuramente)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header visual
              Container(
                width: double.infinity,
                color: AppColors.dark,
                padding: const EdgeInsets.fromLTRB(28, 48, 28, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MATCH UP',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 40,
                        color: AppColors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      'SPORTS YES',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 22,
                        color: AppColors.primary,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bem-vindo de volta!',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Entre na sua conta para reservar quadras.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ),

              // Formulário
              Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'E-mail',
                        hint: 'seu@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe seu e-mail';
                          }
                          if (!value.contains('@')) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Senha',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.gray,
                          ),
                          onPressed: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe sua senha';
                          }
                          if (value.length < 6) {
                            return 'Senha deve ter ao menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Esqueci minha senha',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.go(AppRoutes.register),
                        child: const Text('Criar conta'),
                      ),
                      const SizedBox(height: 32),

                      // Divisor com OU
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: AppColors.grayLight)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'ou entre como',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, color: AppColors.gray),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: AppColors.grayLight)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Botões de perfil
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileButton(
                              emoji: '🏃',
                              label: 'Jogador',
                              onTap: () => context.go(AppRoutes.home),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileButton(
                              emoji: '🏟️',
                              label: 'Dono de Quadra',
                              onTap: () => context.go(AppRoutes.home),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.grayLight),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
