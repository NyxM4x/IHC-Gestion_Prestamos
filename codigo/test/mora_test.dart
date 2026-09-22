import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_prestamos/logica/mora.dart';
import 'package:gestion_prestamos/modelos/cuota.dart';
import 'package:gestion_prestamos/modelos/prestamo.dart';

final hoy = DateTime(2026, 9, 21);

Cuota cuotaQueVence(DateTime vence, {double monto = 100, double abonado = 0}) {
  return Cuota(
    id: 'q1',
    prestamoId: 'p1',
    numero: 1,
    vence: vence,
    monto: monto,
    abonado: abonado,
  );
}

Prestamo prestamoConMora(double moraPorDia) {
  return Prestamo(
    id: 'p1',
    clienteId: 'c1',
    capital: 1000,
    totalADevolver: 1200,
    moneda: 'BOB',
    frecuencia: Frecuencia.semanal,
    cantidadCuotas: 10,
    fechaInicio: DateTime(2026, 9, 1),
    moraPorDia: moraPorDia,
  );
}

void main() {
  test('una cuota que todavia no vence no tiene mora', () {
    final cuota = cuotaQueVence(DateTime(2026, 9, 25));
    expect(calcularMora(cuota, 5, hoy), 0);
    expect(cuota.estado(hoy), EstadoCuota.porVencer);
  });

  test('la cuota que vence hoy es exigible pero sin mora', () {
    final cuota = cuotaQueVence(hoy);
    expect(calcularMora(cuota, 5, hoy), 0);
    expect(cuota.estado(hoy), EstadoCuota.venceHoy);
    expect(cuota.esExigible(hoy), isTrue);
  });

  test('la mora se cobra por cada dia de atraso', () {
    final cuota = cuotaQueVence(DateTime(2026, 9, 16)); // 5 dias atras
    expect(cuota.diasAtraso(hoy), 5);
    expect(calcularMora(cuota, 5, hoy), 25);
    expect(cuota.estado(hoy), EstadoCuota.vencida);
  });

  test('una cuota pagada no genera mora aunque este atrasada', () {
    final cuota = cuotaQueVence(DateTime(2026, 9, 1), abonado: 100);
    expect(cuota.pagada, isTrue);
    expect(calcularMora(cuota, 5, hoy), 0);
    expect(cuota.estado(hoy), EstadoCuota.pagada);
    expect(cuota.esExigible(hoy), isFalse);
  });

  test('sin mora configurada el atraso no suma nada', () {
    final cuota = cuotaQueVence(DateTime(2026, 9, 1));
    expect(calcularMora(cuota, 0, hoy), 0);
  });

  test('el monto a cobrar suma el saldo y la mora', () {
    final cuota = cuotaQueVence(DateTime(2026, 9, 16), abonado: 40);
    expect(cuota.saldo, 60);
    expect(montoACobrar(cuota, prestamoConMora(5), hoy), 85); // 60 + 25
  });

  test('el abono parcial baja el saldo sin dar la cuota por pagada', () {
    final cuota = cuotaQueVence(hoy).conAbono(30);
    expect(cuota.saldo, 70);
    expect(cuota.pagada, isFalse);
  });

  test('la hora del dia no cuenta como atraso', () {
    final cuota = cuotaQueVence(DateTime(2026, 9, 21, 8, 0));
    final hoyDeNoche = DateTime(2026, 9, 21, 23, 59);
    expect(cuota.diasAtraso(hoyDeNoche), 0);
  });

  test('el desglose explica la mora en palabras', () {
    final cuota = cuotaQueVence(DateTime(2026, 9, 20)); // 1 dia
    final texto = desgloseDelCobro(cuota, prestamoConMora(5), hoy);
    expect(texto, contains('1 día de atraso'));
  });
}
