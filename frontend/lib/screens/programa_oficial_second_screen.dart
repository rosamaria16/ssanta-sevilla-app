import 'package:flutter/material.dart';
import '../services/hermandad_service.dart';
import '../utils/app_theme.dart';
import 'programa_oficial_third_screen.dart';
import 'programa_oficial_all_screen.dart';

class ProgramaSecondScreen extends StatefulWidget {
  final int idDia;
  final String nombreDia;
  const ProgramaSecondScreen({super.key, required this.idDia, required this.nombreDia});

  @override
  State<ProgramaSecondScreen> createState() => _ProgramaSecondScreenState();
}

class _ProgramaSecondScreenState extends State<ProgramaSecondScreen> {
  late List<Hermandad> listaHermandades = [];

  @override
  void initState() {
    super.initState();
    _cargarHermandades();
  }

  Future<void> _cargarHermandades() async {
    final hermandades = await Hermandad.getHermandadesDia(widget.idDia);
    setState(() {
      listaHermandades = hermandades;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(widget.nombreDia),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: listaHermandades.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgramaAllScreen(
                          idDia: widget.idDia,
                          nombreDia: widget.nombreDia,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grid_view_rounded, color: AppColors.accent, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Ver todas las hermandades',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final hermandad = listaHermandades[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProgramaThirdScreen(
                        idHermandad: hermandad.id,
                        nombreHermandad: hermandad.nombre,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          child: Text(
                            hermandad.nombre,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}