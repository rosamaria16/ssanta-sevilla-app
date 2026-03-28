import 'package:flutter/material.dart';

class NoticiasScreen extends StatelessWidget {
  const NoticiasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Pantalla de Noticias',
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
    );
  }
}
