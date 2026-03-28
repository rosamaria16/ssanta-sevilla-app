import 'package:flutter/material.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Pantalla de Radio',
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
    );
  }
}
