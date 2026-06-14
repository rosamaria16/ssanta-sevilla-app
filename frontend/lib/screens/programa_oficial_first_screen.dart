import 'package:flutter/material.dart';
import '../services/dia_service.dart';
import '../utils/app_theme.dart';
import '../utils/hora_utils.dart';
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: listaDias.length,
      itemBuilder: (context, index) {
        final dia = listaDias[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgramaSecondScreen(
                      idDia: dia.id,
                      nombreDia: dia.nombre,
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
                      width: 62,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${dia.fecha.day}',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            mesesDelAnyo[dia.fecha.month],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Text(
                          dia.nombre,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}