import '../modelos/prestamo.dart';

// Ultimo dia que tiene ese mes (para no inventar un 31 de febrero).
int _ultimoDiaDelMes(int anio, int mes) {
  return DateTime(anio, mes + 1, 0).day;
}

// Suma "veces" periodos a la fecha base segun la frecuencia del prestamo.
// Ejemplo: mensual + 3 veces sobre el 31/01 cae el 30/04, no el 01/05.
DateTime sumarPeriodos(DateTime base, Frecuencia frecuencia, int veces) {
  switch (frecuencia) {
    case Frecuencia.diario:
      return base.add(Duration(days: veces));
    case Frecuencia.semanal:
      return base.add(Duration(days: 7 * veces));
    case Frecuencia.quincenal:
      return base.add(Duration(days: 15 * veces));
    case Frecuencia.mensual:
      final totalMeses = base.month + veces;
      // Los meses van de 1 a 12, por eso se resta y se suma 1 al acomodarlos.
      final anio = base.year + ((totalMeses - 1) ~/ 12);
      final mes = ((totalMeses - 1) % 12) + 1;
      final dia = base.day > _ultimoDiaDelMes(anio, mes)
          ? _ultimoDiaDelMes(anio, mes)
          : base.day;
      return DateTime(anio, mes, dia);
  }
}

// Fecha en el formato que se lee en Bolivia: 20/11/2026.
String fechaCorta(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}

// Diferencia en dias entre dos fechas, ignorando la hora.
int diasEntre(DateTime desde, DateTime hasta) {
  final a = DateTime(desde.year, desde.month, desde.day);
  final b = DateTime(hasta.year, hasta.month, hasta.day);
  return b.difference(a).inDays;
}
