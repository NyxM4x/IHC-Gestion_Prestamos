// Cada cuanto paga el cliente. No hay tipos de prestamo fijos: el prestamista
// arma los terminos que quiera y esto solo dice cada cuantos dias toca pagar.
enum Frecuencia { diario, semanal, quincenal, mensual }

String nombreFrecuencia(Frecuencia f) {
  switch (f) {
    case Frecuencia.diario:
      return 'Diario';
    case Frecuencia.semanal:
      return 'Semanal';
    case Frecuencia.quincenal:
      return 'Quincenal';
    case Frecuencia.mensual:
      return 'Mensual';
  }
}

// Como se dice "cada cuanto" en una frase normal.
String cadaCuanto(Frecuencia f) {
  switch (f) {
    case Frecuencia.diario:
      return 'cada día';
    case Frecuencia.semanal:
      return 'cada semana';
    case Frecuencia.quincenal:
      return 'cada quincena';
    case Frecuencia.mensual:
      return 'cada mes';
  }
}

Frecuencia frecuenciaDesdeTexto(String texto) {
  return Frecuencia.values.firstWhere(
    (f) => f.name == texto,
    orElse: () => Frecuencia.mensual,
  );
}

class Prestamo {
  Prestamo({
    required this.id,
    required this.clienteId,
    required this.capital,
    required this.totalADevolver,
    required this.moneda,
    required this.frecuencia,
    required this.cantidadCuotas,
    required this.fechaInicio,
    this.moraPorDia = 0,
  });

  final String id;
  final String clienteId;
  final double capital; // lo que entrego en mano
  final double totalADevolver; // capital + interes, como lo pacta el prestamista
  final String moneda; // 'BOB' o 'USD'
  final Frecuencia frecuencia;
  final int cantidadCuotas;
  final DateTime fechaInicio; // vencimiento de la primera cuota
  final double moraPorDia; // recargo por cada dia de atraso; 0 = sin mora

  // Lo que gana el prestamista con este prestamo.
  double get ganancia => totalADevolver - capital;

  // Interes expresado en porcentaje, solo para mostrarlo.
  double get porcentajeInteres {
    if (capital <= 0) return 0;
    return (ganancia / capital) * 100;
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'capital': capital,
      'total_a_devolver': totalADevolver,
      'moneda': moneda,
      'frecuencia': frecuencia.name,
      'cantidad_cuotas': cantidadCuotas,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'mora_por_dia': moraPorDia,
    };
  }

  static Prestamo desdeMapa(Map<String, dynamic> mapa) {
    return Prestamo(
      id: mapa['id'] as String,
      clienteId: mapa['cliente_id'] as String,
      capital: (mapa['capital'] as num).toDouble(),
      totalADevolver: (mapa['total_a_devolver'] as num).toDouble(),
      moneda: mapa['moneda'] as String,
      frecuencia: frecuenciaDesdeTexto(mapa['frecuencia'] as String),
      cantidadCuotas: (mapa['cantidad_cuotas'] as num).toInt(),
      fechaInicio: DateTime.parse(mapa['fecha_inicio'] as String),
      moraPorDia: ((mapa['mora_por_dia'] ?? 0) as num).toDouble(),
    );
  }
}
