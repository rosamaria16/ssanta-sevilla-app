import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProgramaSecondScreen extends StatefulWidget {
  
  final int idDia;
  final String nombreDia;
  const ProgramaSecondScreen({super.key, required this.idDia, required this.nombreDia});

  @override
  State<ProgramaSecondScreen> createState() => _ProgramaSecondScreenState();

}

class _ProgramaSecondScreenState extends State<ProgramaSecondScreen> {
  late List<String> listaHermandades = [];

  @override
  void initState() {
    super.initState();
    _cargarHermandades();
  }

  Future<void> _cargarHermandades() async {
    final hermandades = await Hermandad.getHermandadesDia(widget.idDia);
    setState(() {
      listaHermandades = hermandades.map((hdad) => (hdad.nombre)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(25, 52, 89, 1),
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Hermandades - ${widget.nombreDia}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: listaHermandades.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            final nombre = listaHermandades[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  backgroundColor: const Color.fromARGB(255, 26, 19, 92),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}