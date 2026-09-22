// Estado de una cuota visto desde hoy. El orden importa: asi se ordena la agenda.
enum EstadoCuota { vencida, venceHoy, porVencer, pagada }

String nombreEstado(EstadoCuota estado) {
  switch (estado) {
    case EstadoCuota.vencida:
      return 'Vencida';
    case EstadoCuota.venceHoy:
      return 'Vence hoy';
    case EstadoCuota.porVencer:
      return 'Por vencer';
    case EstadoCuota.pagada:
      return 'Pagada';
  }
}

// Una cuota del plan de pagos de un prestamo.
class Cuota {
  Cuota({
    required this.id,
    required this.prestamoId,
    required this.numero,
    required this.vence,
    required this.monto,
    this.abonado = 0,
  });

  final String id;
  final String prestamoId;
  final int numero;
  final DateTime vence;
  final double monto; // lo que se pacto para esta cuota
  final double abonado; // lo que el cliente ya entrego

  // Lo que todavia falta de la cuota, sin contar mora.
  double get saldo {
    final resto = monto - abonado;
    return resto < 0 ? 0 : resto;
  }

  bool get pagada => saldo <= 0;

  // Dias pasados desde el vencimiento. Negativo = todavia no vence.
  // Se comparan solo las fechas, sin la hora, para no contar medio dia de atraso.
  int diasAtraso(DateTime hoy) {
    final soloVence = DateTime(vence.year, vence.month, vence.day);
    final soloHoy = DateTime(hoy.year, hoy.month, hoy.day);
    return soloHoy.difference(soloVence).inDays;
  }

  EstadoCuota estado(DateTime hoy) {
    if (pagada) return EstadoCuota.pagada;
    final dias = diasAtraso(hoy);
    if (dias > 0) return EstadoCuota.vencida;
    if (dias == 0) return EstadoCuota.venceHoy;
    return EstadoCuota.porVencer;
  }

  // Ya se puede cobrar: vencio o vence hoy.
  bool esExigible(DateTime hoy) {
    if (pagada) return false;
    return diasAtraso(hoy) >= 0;
  }

  // Copia con otro monto abonado. Se usa al registrar un pago.
  Cuota conAbono(double nuevoAbonado) {
    return Cuota(
      id: id,
      prestamoId: prestamoId,
      numero: numero,
      vence: vence,
      monto: monto,
      abonado: nuevoAbonado,
    );
  }

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'prestamo_id': prestamoId,
      'numero': numero,
      'vence': vence.toIso8601String(),
      'monto': monto,
      'abonado': abonado,
    };
  }

  static Cuota desdeMapa(Map<String, dynamic> mapa) {
    return Cuota(
      id: mapa['id'] as String,
      prestamoId: mapa['prestamo_id'] as String,
      numero: (mapa['numero'] as num).toInt(),
      vence: DateTime.parse(mapa['vence'] as String),
      monto: (mapa['monto'] as num).toDouble(),
      abonado: ((mapa['abonado'] ?? 0) as num).toDouble(),
    );
  }
}
