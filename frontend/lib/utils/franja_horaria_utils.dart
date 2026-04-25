import 'hora_utils.dart';

class FranjaHoraria {

  final List<String> horas;

  final List<int> minutosAjustados;

  final int horaInicio;

  FranjaHoraria({
    required this.horas,
    required this.minutosAjustados,
    required this.horaInicio,
  });

  static FranjaHoraria calcularFranjas(List<int> todasHorasEnMinutos) {
    if (todasHorasEnMinutos.isEmpty) {
      return FranjaHoraria(
        horas: [],
        minutosAjustados: [],
        horaInicio: 0,
      );
    }

    final horaInicio = calcularHoraInicio(todasHorasEnMinutos);
    final horasAjustadas = todasHorasEnMinutos
        .map((r) => (r - horaInicio + 1440) % 1440)
        .toSet()
        .toList();

    if (horasAjustadas.isEmpty) {
      return FranjaHoraria(
        horas: [],
        minutosAjustados: [],
        horaInicio: horaInicio,
      );
    }

    final primeraHora = horasAjustadas.reduce((a, b) => a < b ? a : b);
    final ultimaHora = horasAjustadas.reduce((a, b) => a > b ? a : b);

    final franjasHoras = <String>[];
    final franjasHorasEnMinutos = <int>[];

    for (int t = primeraHora; t <= ultimaHora; t += 30) {
      franjasHoras.add(minutosAHora((t + horaInicio) % 1440));
      franjasHorasEnMinutos.add(t);
    }

    return FranjaHoraria(
      horas: franjasHoras,
      minutosAjustados: franjasHorasEnMinutos,
      horaInicio: horaInicio,
    );
  }

  static FranjaHoraria calcularFranjasDesdeUnicas(List<int> minutosAjustadosOrdenados, int horaInicio) {
    final franjasHoras = minutosAjustadosOrdenados
        .map((adj) => minutosAHora((adj + horaInicio) % 1440))
        .toList();

    return FranjaHoraria(
      horas: franjasHoras,
      minutosAjustados: minutosAjustadosOrdenados,
      horaInicio: horaInicio,
    );
  }

  int ajustarHora(int minutos) {
    return (minutos - horaInicio + 1440) % 1440;
  }
}
