//Normaliza una hora al formato HH:MM (recorta segundos si los tiene)
String normalizaHora(String hora) {
  return hora.length >= 5 ? hora.substring(0, 5) : hora;
}

//Convierte una hora "HH:MM" a minutos desde las 00:00
int horaAMinutos(String hora) {
  final partes = normalizaHora(hora).split(':');
  return int.parse(partes[0]) * 60 + int.parse(partes[1]);
}

//Convierte minutos totales a cadena tipo "HH:MM"
String minutosAHora(int totalMinutos) {
  final horas = (totalMinutos ~/ 60) % 24;
  final mins = totalMinutos % 60;
  return '${horas.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
}

//Encuentra el inicio de la ventana circular de horarios, 
//buscando el mayor hueco entre horas consecutivas para determinar
//dónde "comienza" el día (útil cuando los pasos cruzan las 00:00)
int calcularHoraInicio(List<int> listaMinutos) {
  if (listaMinutos.isEmpty) return 0;
  final ordenados = listaMinutos.toSet().toList()..sort();
  if (ordenados.length == 1) return ordenados[0];

  int maxHueco = ordenados[0] + 1440 - ordenados.last;
  int inicioTrasHueco = ordenados[0];
  for (int i = 1; i < ordenados.length; i++) {
    final hueco = ordenados[i] - ordenados[i - 1];
    if (hueco > maxHueco) {
      maxHueco = hueco;
      inicioTrasHueco = ordenados[i];
    }
  }
  return inicioTrasHueco;
}
