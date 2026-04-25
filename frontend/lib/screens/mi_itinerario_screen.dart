import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/auth_manager.dart';
import '../widgets/login_modal.dart';
import 'login_screen.dart';
import 'mi_itinerario_first_screen.dart';

class MiItinerarioScreen extends StatefulWidget {
  const MiItinerarioScreen({super.key});

  @override
  State<MiItinerarioScreen> createState() => _MiItinerarioScreenState();
}

class _MiItinerarioScreenState extends State<MiItinerarioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AuthManager().isLoggedIn) {
        _showLoginModal();
      }
    });
  }

  void _showLoginModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoginModal(
        onLoginSuccess: () {
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthManager().isLoggedIn) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Por favor, ',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                TextSpan(
                  text: 'inicia sesión',
                  style: const TextStyle(
                    color: Color.fromRGBO(25, 52, 89, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      ).then((result) {
                        if (result == true) {
                          setState(() {});
                        }
                      });
                    },
                ),
                const TextSpan(
                  text: ' para ver tu itinerario',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const ItinerarioFirstScreen();
  }
}
