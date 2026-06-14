import 'package:flutter/material.dart';
import '../services/dia_service.dart';
import 'programa_oficial_second_screen.dart';

class ProgramaFirstScreen extends StatefulWidget {
  const ProgramaFirstScreen({super.key});

  @override
  State<ProgramaFirstScreen> createState() => _ProgramaFirstScreenState();
}

class _ProgramaFirstScreenState extends State<ProgramaFirstScreen> {
  List<Dia> listaDias = [];

  @override
  void initState() {
    super.initState();
    _cargarDias();
  }

  Future<void> _cargarDias() async {
    final dias = await Dia.getDiasSemanaSanta();
    setState(() {
      listaDias = dias;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: listaDias.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final dia = listaDias[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProgramaSecondScreen(idDia: dia.id, nombreDia: dia.nombre),
                        ),
                      );
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
                      dia.nombre,
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
        ],
      ),
    );
  }
}