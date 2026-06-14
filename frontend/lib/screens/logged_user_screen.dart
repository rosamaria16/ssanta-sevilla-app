import 'dart:async';
import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../services/auth_manager.dart';
import '../utils/app_theme.dart';
import '../utils/app_message.dart';

class LoggedUserScreen extends StatefulWidget {
  const LoggedUserScreen({super.key});

  @override
  State<LoggedUserScreen> createState() => _LoggedUserScreenState();
}

class _LoggedUserScreenState extends State<LoggedUserScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _message;
  bool _isError = false;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    final user = AuthManager().currentUser;
    _nombreController = TextEditingController(text: user?['nombre'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showMessage(String text, {bool isError = false}) {
    _messageTimer?.cancel();
    setState(() {
      _message = text;
      _isError = isError;
    });
    _messageTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _message = null);
      }
    });
  }

  void _dismissMessage() {
    _messageTimer?.cancel();
    setState(() => _message = null);
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        final user = AuthManager().currentUser;
        _nombreController.text = user?['nombre'] ?? '';
        _emailController.text = user?['email'] ?? '';
      }
      _isEditing = !_isEditing;
      _message = null;
    });
  }

  Future<void> _saveProfile() async {
    final user = AuthManager().currentUser;
    if (user == null) return;

    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();

    if (nombre.isEmpty) {
      _showMessage('El nombre no puede estar vacío', isError: true);
      return;
    }
    if (email.isEmpty) {
      _showMessage('El email no puede estar vacío', isError: true);
      return;
    }
    if (!email.contains('@')) {
      _showMessage('Email inválido', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      await UsuarioService.updateProfile(
        user['id'],
        nombre: nombre,
        email: email,
      );
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        _showMessage('Perfil actualizado correctamente');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String? dialogError;
    bool dialogLoading = false;
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.lock_outline, color: AppColors.primary, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Cambiar contraseña',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: currentPasswordController,
                      obscureText: obscureCurrent,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppInputDecoration.build(
                        label: 'Contraseña actual',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppInputDecoration.build(
                        label: 'Nueva contraseña',
                        icon: Icons.lock_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppInputDecoration.build(
                        label: 'Confirmar nueva contraseña',
                        icon: Icons.lock_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                        ),
                      ),
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 14),
                      AppMessage(
                        message: dialogError!,
                        isError: true,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: dialogLoading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: dialogLoading
                                ? null
                                : () async {
                                    final currentPass = currentPasswordController.text;
                                    final newPass = newPasswordController.text;
                                    final confirmPass = confirmPasswordController.text;

                                    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                                      setDialogState(() {
                                        dialogError = 'Rellena todos los campos';
                                      });
                                      return;
                                    }

                                    if (newPass != confirmPass) {
                                      setDialogState(() {
                                        dialogError = 'Las contraseñas nuevas no coinciden';
                                      });
                                      return;
                                    }

                                    if (newPass.length < 6) {
                                      setDialogState(() {
                                        dialogError = 'La contraseña debe tener al menos 6 caracteres';
                                      });
                                      return;
                                    }

                                    setDialogState(() {
                                      dialogLoading = true;
                                      dialogError = null;
                                    });

                                    try {
                                      final user = AuthManager().currentUser;
                                      await UsuarioService.changePassword(
                                        user!['id'],
                                        currentPass,
                                        newPass,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        _showMessage('Contraseña cambiada correctamente');
                                      }
                                    } catch (e) {
                                      setDialogState(() {
                                        dialogLoading = false;
                                        dialogError = e.toString().replaceFirst('Exception: ', '');
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primaryLight,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: dialogLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Cambiar', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthManager().currentUser;

    if (user == null) {
      return const Center(
        child: Text('No hay usuario autenticado'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header con avatar
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2.5),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user['nombre'] ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textOnPrimaryMuted,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  // Message
                  if (_message != null) ...[
                    AppMessage(
                      message: _message!,
                      isError: _isError,
                      onDismiss: _dismissMessage,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Profile info / edit card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.badge_outlined, color: AppColors.primaryLight, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isEditing ? 'Editar perfil' : 'Información personal',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _isSaving ? null : _toggleEdit,
                              child: Text(
                                _isEditing ? 'Cancelar' : 'Modificar',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _isEditing ? AppColors.textSecondary : AppColors.accentDark,
                                  decoration: _isEditing ? null : TextDecoration.underline,
                                  decorationColor: AppColors.accentDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_isEditing) ...[
                          TextField(
                            controller: _nombreController,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: AppInputDecoration.build(
                              label: 'Nombre',
                              icon: Icons.person_outline,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: AppInputDecoration.build(
                              label: 'Email',
                              icon: Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.primaryLight,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Guardar cambios',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ] else ...[
                          _buildInfoRow(
                            icon: Icons.person_outline,
                            label: 'Nombre',
                            value: user['nombre'] ?? 'Usuario',
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Container(height: 1, color: AppColors.divider),
                          ),
                          _buildInfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: user['email'] ?? 'Email no disponible',
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Actions
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        _buildActionTile(
                          icon: Icons.lock_outline,
                          label: 'Cambiar contraseña',
                          onTap: _showChangePasswordDialog,
                        ),
                        Container(height: 1, color: AppColors.divider),
                        _buildActionTile(
                          icon: Icons.logout_rounded,
                          label: 'Cerrar Sesión',
                          isDestructive: true,
                          onTap: () {
                            UsuarioService.logout();
                            Navigator.pop(context, 'logout');
                          },
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
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.destructive : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? AppColors.destructive : AppColors.primaryLight, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
