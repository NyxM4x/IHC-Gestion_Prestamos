// Monedas que maneja la app. El prestamista elige una al crear el prestamo.
const monedaBoliviano = 'BOB';
const monedaDolar = 'USD';
const monedasDisponibles = [monedaBoliviano, monedaDolar];

String simboloMoneda(String moneda) {
  return moneda == monedaDolar ? '\$' : 'Bs';
}

String nombreMoneda(String moneda) {
  return moneda == monedaDolar ? 'Dólares' : 'Bolivianos';
}

// Separa los miles con punto, como se escribe aca: 1.200
String _conSeparadorDeMiles(String entero) {
  final resultado = StringBuffer();
  for (var i = 0; i < entero.length; i++) {
    // Se pone un punto cada tres digitos contando desde la derecha.
    final faltan = entero.length - i;
    if (i > 0 && faltan % 3 == 0) resultado.write('.');
    resultado.write(entero[i]);
  }
  return resultado.toString();
}

// Numero listo para mostrar: 1.200 si es redondo, 1.200,50 si tiene centavos.
String formatearNumero(double monto) {
  final centavos = (monto.abs() * 100).round();
  final entero = (centavos ~/ 100).toString();
  final resto = centavos % 100;
  final signo = monto < 0 ? '-' : '';

  if (resto == 0) return '$signo${_conSeparadorDeMiles(entero)}';
  return '$signo${_conSeparadorDeMiles(entero)},'
      '${resto.toString().padLeft(2, '0')}';
}

// Lo que se ve en pantalla: "Bs 1.200" o "$ 350,50".
String formatearMonto(double monto, String moneda) {
  return '${simboloMoneda(moneda)} ${formatearNumero(monto)}';
}
