// Cada vez que el cliente entrega plata se guarda un pago. Nunca se borra:
// asi el prestamista puede mostrar el historial si el cliente reclama.
class Pago {
  Pago({
    required this.id,
    required this.cuotaId,
    required this.prestamoId,
    required this.monto,
    required this.fecha,
  });

  final String id;
  final String cuotaId;
  final String prestamoId;
  final double monto;
  final DateTime fecha;

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'cuota_id': cuotaId,
      'prestamo_id': prestamoId,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
    };
  }

  static Pago desdeMapa(Map<String, dynamic> mapa) {
    return Pago(
      id: mapa['id'] as String,
      cuotaId: mapa['cuota_id'] as String,
      prestamoId: mapa['prestamo_id'] as String,
      monto: (mapa['monto'] as num).toDouble(),
      fecha: DateTime.parse(mapa['fecha'] as String),
    );
  }
}
