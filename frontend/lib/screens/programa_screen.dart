import 'package:flutter/material.dart';

class ProgramaScreen extends StatelessWidget {
  const ProgramaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Pantalla de Programa Oficial',
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
    );
  }
}
