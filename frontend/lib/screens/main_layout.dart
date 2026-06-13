import 'package:flutter/material.dart';
import 'noticias_screen.dart';
import 'programa_oficial_first_screen.dart';
import 'mi_itinerario_screen.dart';
import 'radio_screen.dart';
import 'login_screen.dart';
import 'logged_user_screen.dart';
import 'admin_screen.dart';
import '../services/auth_manager.dart';
import '../services/radio_player_controller.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;
  final RadioPlayerController _radioController = RadioPlayerController();

  final List<String> screenTitles = [
    'Noticias',
    'Programa Oficial',
    'Mi Itinerario',
    'Radio',
  ];

  void _handleUserIconClick() {
    if (AuthManager().isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoggedUserScreen()),
      ).then((result) {
        if (result == 'logout') {
          setState(() {
            currentIndex = 0;
          });
        } else {
          setState(() {});
        }
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      ).then((result) {
        if (result == true) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AuthManager().isAdmin) {
      return AdminScreen(onLogout: () => setState(() {}));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(25, 52, 89, 1),
        centerTitle: true,
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.account_circle),
          onPressed: _handleUserIconClick,
        ),
        title: Text(
          screenTitles[currentIndex],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: getScreen(currentIndex)),
          _buildRadioBar(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        backgroundColor: const Color.fromRGBO(25, 52, 89, 1),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Noticias'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Programa'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Mi Itinerario'),
          BottomNavigationBarItem(icon: Icon(Icons.radio), label: 'Radio'),
        ],
      ),
    );
  }

  Widget getScreen(int index) {
    switch (index) {
      case 0: return const NoticiasScreen();
      case 1: return const ProgramaFirstScreen();
      case 2: return MiItinerarioScreen(onLoginSuccess: () => setState(() {}));
      case 3: return RadioScreen(controller: _radioController);
      default: return const NoticiasScreen();
    }
  }

  Widget _buildRadioBar() {
    return ListenableBuilder(
      listenable: _radioController,
      builder: (context, _) {
        final emisora = _radioController.currentEmisora;
        if (emisora == null) return const SizedBox.shrink();

        final isPlaying = _radioController.isPlaying;

        return GestureDetector(
          onTap: () {
            setState(() {
              currentIndex = 3;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color.fromRGBO(25, 52, 89, 1),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    emisora.urlImagen,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.radio, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    emisora.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: isPlaying
                      ? _radioController.pause
                      : _radioController.resume,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: _radioController.stop,
                  icon: const Icon(Icons.stop),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
