import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_prestamos/logica/plan_cuotas.dart';
import 'package:gestion_prestamos/modelos/prestamo.dart';

Prestamo prestamoDePrueba({
  double capital = 1000,
  double totalADevolver = 1200,
  Frecuencia frecuencia = Frecuencia.semanal,
  int cantidadCuotas = 10,
  DateTime? fechaInicio,
}) {
  return Prestamo(
    id: 'p1',
    clienteId: 'c1',
    capital: capital,
    totalADevolver: totalADevolver,
    moneda: 'BOB',
    frecuencia: frecuencia,
    cantidadCuotas: cantidadCuotas,
    fechaInicio: fechaInicio ?? DateTime(2026, 9, 28),
  );
}

void main() {
  test('genera la cantidad de cuotas pedida', () {
    final cuotas = generarPlan(prestamoDePrueba(cantidadCuotas: 10));
    expect(cuotas.length, 10);
    expect(cuotas.first.numero, 1);
    expect(cuotas.last.numero, 10);
  });

  test('reparte el total en cuotas iguales cuando la division es exacta', () {
    final cuotas = generarPlan(
      prestamoDePrueba(totalADevolver: 1200, cantidadCuotas: 10),
    );
    for (final cuota in cuotas) {
      expect(cuota.monto, 120);
    }
  });

  test('el sobrante de la division cae en la ultima cuota', () {
    // 100 entre 3 no da exacto: 33,33 + 33,33 + 33,34
    final cuotas = generarPlan(
      prestamoDePrueba(totalADevolver: 100, cantidadCuotas: 3),
    );
    expect(cuotas[0].monto, 33.33);
    expect(cuotas[1].monto, 33.33);
    expect(cuotas[2].monto, 33.34);
  });

  test('la suma de las cuotas da exactamente el total pactado', () {
    final casos = [
      [100.0, 3],
      [1000.0, 7],
      [2500.0, 30],
      [777.77, 11],
    ];
    for (final caso in casos) {
      final total = caso[0] as double;
      final cantidad = caso[1] as int;
      final cuotas = generarPlan(
        prestamoDePrueba(totalADevolver: total, cantidadCuotas: cantidad),
      );
      var suma = 0.0;
      for (final cuota in cuotas) {
        suma += cuota.monto;
      }
      expect(suma.toStringAsFixed(2), total.toStringAsFixed(2),
          reason: 'fallo con $total en $cantidad cuotas');
    }
  });

  test('la primera cuota vence en la fecha de inicio', () {
    final inicio = DateTime(2026, 9, 28);
    final cuotas = generarPlan(prestamoDePrueba(fechaInicio: inicio));
    expect(cuotas.first.vence, inicio);
  });

  test('las cuotas semanales caen cada 7 dias', () {
    final cuotas = generarPlan(
      prestamoDePrueba(
        frecuencia: Frecuencia.semanal,
        fechaInicio: DateTime(2026, 9, 28),
      ),
    );
    expect(cuotas[1].vence, DateTime(2026, 10, 5));
    expect(cuotas[2].vence, DateTime(2026, 10, 12));
  });

  test('las cuotas mensuales no inventan un 31 de febrero', () {
    final cuotas = generarPlan(
      prestamoDePrueba(
        frecuencia: Frecuencia.mensual,
        cantidadCuotas: 3,
        fechaInicio: DateTime(2026, 12, 31),
      ),
    );
    expect(cuotas[0].vence, DateTime(2026, 12, 31));
    expect(cuotas[1].vence, DateTime(2027, 1, 31));
    expect(cuotas[2].vence, DateTime(2027, 2, 28));
  });

  test('un prestamo sin cuotas devuelve un plan vacio', () {
    expect(generarPlan(prestamoDePrueba(cantidadCuotas: 0)), isEmpty);
  });

  test('la ganancia y el porcentaje salen del capital y el total', () {
    final prestamo = prestamoDePrueba(capital: 1000, totalADevolver: 1200);
    expect(prestamo.ganancia, 200);
    expect(prestamo.porcentajeInteres, 20);
  });
}
