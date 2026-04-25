String displayTipoPaso(String tipo) {
    switch (tipo) {
      case 'CRUZGUIA':
        return 'Cruz de Guía';
      case 'PALIO':
        return 'Palio';
      case 'DUELO':
        return 'Duelo';
      case 'PASO':
        return 'Paso';
      default:
        return tipo;
    }
  }