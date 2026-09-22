import '../modelos/cuota.dart';
import '../modelos/prestamo.dart';
import 'fechas.dart';
import 'identificadores.dart';

// Arma el plan de pagos de un prestamo.
//
// Se trabaja en centavos (numeros enteros) para que no se pierdan decimales al
// dividir. Si la division no da exacta, el sobrante se le carga a la ultima
// cuota: asi la suma de todas las cuotas da justo el total pactado y el
// prestamista nunca termina cobrando un centavo de mas o de menos.
List<Cuota> generarPlan(Prestamo prestamo) {
  if (prestamo.cantidadCuotas <= 0) return [];

  final totalEnCentavos = (prestamo.totalADevolver * 100).round();
  final cuotaBase = totalEnCentavos ~/ prestamo.cantidadCuotas;
  final sobrante = totalEnCentavos - (cuotaBase * prestamo.cantidadCuotas);

  final cuotas = <Cuota>[];
  for (var i = 0; i < prestamo.cantidadCuotas; i++) {
    final esUltima = i == prestamo.cantidadCuotas - 1;
    final centavos = esUltima ? cuotaBase + sobrante : cuotaBase;

    cuotas.add(
      Cuota(
        id: nuevoId('cuota'),
        prestamoId: prestamo.id,
        numero: i + 1,
        // La cuota 1 vence en la fecha de inicio, por eso se suman i periodos.
        vence: sumarPeriodos(prestamo.fechaInicio, prestamo.frecuencia, i),
        monto: centavos / 100,
      ),
    );
  }
  return cuotas;
}

// Cuanto sumaria cada cuota, para mostrarlo en vivo mientras el prestamista
// llena el formulario y todavia no existe el prestamo.
double cuotaEstimada(double totalADevolver, int cantidadCuotas) {
  if (cantidadCuotas <= 0) return 0;
  final centavos = (totalADevolver * 100).round() ~/ cantidadCuotas;
  return centavos / 100;
}
