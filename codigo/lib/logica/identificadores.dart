// Contador para que dos ids creados en el mismo microsegundo no choquen.
int _contador = 0;

// Id simple y unico para clientes, prestamos, cuotas y pagos.
String nuevoId(String prefijo) {
  _contador++;
  final marca = DateTime.now().microsecondsSinceEpoch;
  return '$prefijo-$marca-$_contador';
}
