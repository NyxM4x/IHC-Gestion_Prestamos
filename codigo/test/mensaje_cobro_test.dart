import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_prestamos/logica/mensaje_cobro.dart';

void main() {
  group('telefono para WhatsApp', () {
    test('a un numero suelto le pone el codigo de pais', () {
      expect(telefonoParaWhatsapp('70011223'), '59170011223');
    });

    test('respeta el numero que ya trae el codigo', () {
      expect(telefonoParaWhatsapp('59170011223'), '59170011223');
      expect(telefonoParaWhatsapp('+591 70011223'), '59170011223');
    });

    test('limpia espacios, guiones y parentesis', () {
      expect(telefonoParaWhatsapp('(591) 700-11223'), '59170011223');
      expect(telefonoParaWhatsapp('700 11 223'), '59170011223');
    });

    test('sin telefono devuelve vacio', () {
      expect(telefonoParaWhatsapp(''), '');
      expect(telefonoParaWhatsapp('   '), '');
      expect(telefonoParaWhatsapp('sin numero'), '');
    });

    test('un numero corto que empieza con 591 igual lleva codigo', () {
      // 5911234 son 7 digitos: es un numero local, no uno con codigo de pais.
      expect(telefonoParaWhatsapp('5911234'), '5915911234');
    });
  });
}
