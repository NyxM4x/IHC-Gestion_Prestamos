import '../modelos/cuota.dart';
import '../modelos/prestamo.dart';

// Recargo acumulado por los dias de atraso de una cuota.
// Si la cuota esta pagada o todavia no vence, no hay mora.
double calcularMora(Cuota cuota, double moraPorDia, DateTime hoy) {
  if (cuota.pagada || moraPorDia <= 0) return 0;
  final dias = cuota.diasAtraso(hoy);
  if (dias <= 0) return 0;
  return dias * moraPorDia;
}

// Lo que hay que cobrar hoy por esta cuota: lo que falta mas la mora.
// Este es el numero que el prestamista dice en voz alta frente al cliente.
double montoACobrar(Cuota cuota, Prestamo prestamo, DateTime hoy) {
  return cuota.saldo + calcularMora(cuota, prestamo.moraPorDia, hoy);
}

// Explicacion del monto en palabras, para que el prestamista confie en el
// numero en vez de rehacerlo en la calculadora.
String desgloseDelCobro(Cuota cuota, Prestamo prestamo, DateTime hoy) {
  final mora = calcularMora(cuota, prestamo.moraPorDia, hoy);
  if (mora <= 0) return 'Cuota completa, sin mora';

  final dias = cuota.diasAtraso(hoy);
  final plural = dias == 1 ? 'día' : 'días';
  return 'Cuota ${cuota.saldo.toStringAsFixed(2)} + mora '
      '${mora.toStringAsFixed(2)} por $dias $plural de atraso';
}
