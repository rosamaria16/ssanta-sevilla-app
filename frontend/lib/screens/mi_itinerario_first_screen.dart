import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'mi_itinerario_second_screen.dart';

class ItinerarioFirstScreen extends StatefulWidget {
  const ItinerarioFirstScreen({super.key});

  @override
  State<ItinerarioFirstScreen> createState() => _ItinerarioFirstScreenState();
}

class _ItinerarioFirstScreenState extends State<ItinerarioFirstScreen> {
  late List<Dia> listaDias = [];

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
                          builder: (context) => ItinerarioSecondScreen(idDia: dia.id, nombreDia: dia.nombre),
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