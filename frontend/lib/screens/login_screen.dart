import 'dart:async';
import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../utils/app_theme.dart';
import '../utils/app_message.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  Timer? _errorTimer;

  @override
  void dispose() {
    _errorTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String text) {
    _errorTimer?.cancel();
    setState(() => _errorMessage = text);
    _errorTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showError('Por favor, introduce tus credenciales');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await UsuarioService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _goToRegister() async {
    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
    if (registered == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 32,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Accede a tu cuenta',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textOnPrimaryMuted,
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: AppInputDecoration.build(
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: AppInputDecoration.build(
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    AppMessage(
                      message: _errorMessage!,
                      isError: true,
                      onDismiss: () => setState(() => _errorMessage = null),
                    ),
                  ],

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Iniciar Sesión',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¿Olvidaste tu contraseña? Contacta con rosespmar@alum.us.es',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Container(
                    height: 1,
                    color: AppColors.divider,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : _goToRegister,
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
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
    );
  }
}