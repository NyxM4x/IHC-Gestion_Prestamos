import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_prestamos/datos/configuracion.dart';

void main() {
  test('avisa exactamente cual variable falta', () {
    // La prueba vale con o sin .env.local: lo que se comprueba es que la
    // lista de faltantes concuerde con lo que efectivamente se leyo.
    if (Configuracion.supabaseUrl.isEmpty) {
      expect(Configuracion.faltantes, contains('SUPABASE_URL'));
    } else {
      expect(Configuracion.faltantes, isNot(contains('SUPABASE_URL')));
    }
  });

  test('esta completa solo si las dos variables tienen valor', () {
    expect(Configuracion.estaCompleta, Configuracion.faltantes.isEmpty);
  });

  test('la moneda por defecto nunca queda vacia', () {
    expect(Configuracion.monedaPorDefecto, isNotEmpty);
  });
}
