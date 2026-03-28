import 'package:flutter/material.dart';
import 'noticias_screen.dart';
import 'programa_screen.dart';
import 'mi_itinerario_screen.dart';
import 'radio_screen.dart';
import 'login_screen.dart';
import 'logged_user_screen.dart';
import '../services/auth_manager.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

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
      body: getScreen(currentIndex),
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
      case 1: return const ProgramaScreen();
      case 2: return const MiItinerarioScreen();
      case 3: return const RadioScreen();
      default: return const NoticiasScreen();
    }
  }
}
