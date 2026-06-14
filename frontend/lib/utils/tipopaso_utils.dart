const ordenTiposPaso = ['CRUZGUIA', 'PASO', 'PALIO', 'DUELO'];

const nombresTiposPaso = {
  'CRUZGUIA': 'Cruz de Guía',
  'PASO': 'Paso',
  'PALIO': 'Palio',
  'DUELO': 'Duelo',
};

String displayTipoPaso(String tipo) {
  return nombresTiposPaso[tipo] ?? tipo;
}

int prioridadTipoPaso(String tipo) {
  final indice = ordenTiposPaso.indexOf(tipo);
  return indice == -1 ? 999 : indice;
}