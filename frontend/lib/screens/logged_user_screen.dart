import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_manager.dart';

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

  @override
  void initState() {
    super.initState();
    final user = AuthManager().currentUser;
    _nombreController = TextEditingController(text: user?['nombre'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
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

    if (nombre.isEmpty || email.isEmpty) {
      setState(() {
        _message = 'El nombre y el email no pueden estar vacíos';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      await ApiService.updateProfile(
        user['id'],
        nombre: nombre,
        email: email,
      );
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
          _message = 'Perfil actualizado correctamente';
          _isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _message = e.toString().replaceFirst('Exception: ', '');
          _isError = true;
        });
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String? dialogError;
    bool dialogLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Cambiar contraseña'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña actual',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmar nueva contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        dialogError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dialogLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: dialogLoading
                      ? null
                      : () async {
                          final currentPass = currentPasswordController.text;
                          final newPass = newPasswordController.text;
                          final confirmPass = confirmPasswordController.text;

                          if (currentPass.isEmpty ||
                              newPass.isEmpty ||
                              confirmPass.isEmpty) {
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
                              dialogError =
                                  'La contraseña debe tener al menos 6 caracteres';
                            });
                            return;
                          }

                          setDialogState(() {
                            dialogLoading = true;
                            dialogError = null;
                          });

                          try {
                            final user = AuthManager().currentUser;
                            await ApiService.changePassword(
                              user!['id'],
                              currentPass,
                              newPass,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Contraseña cambiada correctamente'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              dialogLoading = false;
                              dialogError = e
                                  .toString()
                                  .replaceFirst('Exception: ', '');
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(25, 52, 89, 1),
                  ),
                  child: dialogLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Cambiar',
                          style: TextStyle(color: Colors.white)),
                ),
              ],
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
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(25, 52, 89, 1),
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit,
                color: Colors.white),
            onPressed: _isSaving ? null : _toggleEdit,
            tooltip: _isEditing ? 'Cancelar' : 'Editar perfil',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isEditing
                          ? _buildEditField('Nombre', _nombreController,
                              icon: Icons.person)
                          : _buildInfoRow(
                              'Nombre', user['nombre'] ?? 'Usuario'),
                      const SizedBox(height: 16),
                      _isEditing
                          ? _buildEditField('Email', _emailController,
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress)
                          : _buildInfoRow(
                              'Email', user['email'] ?? 'Email no disponible'),
                    ],
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                      border: Border.all(
                          color: _isError ? Colors.red : Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _message!,
                      style: TextStyle(
                          color: _isError ? Colors.red : Colors.green.shade800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                if (_isEditing) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      icon: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        _isSaving ? 'Guardando...' : 'Guardar cambios',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showChangePasswordDialog,
                    icon: const Icon(Icons.lock_outline),
                    label: const Text(
                      'Cambiar contraseña',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(25, 52, 89, 1),
                      side: const BorderSide(
                          color: Color.fromRGBO(25, 52, 89, 1)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ApiService.logout();
                      Navigator.pop(context, 'logout');
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEditField(String label, TextEditingController controller,
      {IconData? icon, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }
}
