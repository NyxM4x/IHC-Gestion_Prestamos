import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_prestamos/datos/autenticacion.dart';
import 'package:gestion_prestamos/logica/control_acceso.dart';

void main() {
  group('escalones de acceso', () {
    test('empieza pidiendo la cara y sin alarmar', () {
      final control = ControlDeAcceso();
      expect(control.paso, PasoDeAcceso.cara);
      expect(control.intentosRestantes, 3);
      expect(control.aviso, isEmpty);
    });

    test('a los 3 fallos de cara pasa a la contrasena', () {
      final control = ControlDeAcceso();
      control.falloLaCara();
      expect(control.paso, PasoDeAcceso.cara);
      expect(control.intentosRestantes, 2);

      control.falloLaCara();
      control.falloLaCara();
      expect(control.paso, PasoDeAcceso.contrasena);
    });

    test('a los 3 fallos de contrasena pasa a recuperacion', () {
      final control = ControlDeAcceso()..saltarALaContrasena();
      expect(control.paso, PasoDeAcceso.contrasena);

      control.falloLaContrasena();
      control.falloLaContrasena();
      expect(control.paso, PasoDeAcceso.contrasena);

      control.falloLaContrasena();
      expect(control.paso, PasoDeAcceso.recuperacion);
      expect(control.intentosRestantes, 0);
    });

    test('se puede saltar a la contrasena sin fallar tres veces', () {
      final control = ControlDeAcceso()..saltarALaContrasena();
      expect(control.paso, PasoDeAcceso.contrasena);
      expect(control.intentosRestantes, 3);
    });

    test('entrar bien borra los intentos anteriores', () {
      final control = ControlDeAcceso()
        ..falloLaCara()
        ..falloLaCara()
        ..reiniciar();
      expect(control.paso, PasoDeAcceso.cara);
      expect(control.intentosRestantes, 3);
    });

    test('el aviso siempre dice cuantos intentos quedan', () {
      final control = ControlDeAcceso()..falloLaCara();
      expect(control.aviso, contains('2 intentos'));
    });

    test('fallar de mas no rompe la cuenta', () {
      final control = ControlDeAcceso();
      for (var i = 0; i < 10; i++) {
        control.falloLaCara();
      }
      expect(control.paso, PasoDeAcceso.contrasena);
      expect(control.intentosRestantes, 3);
    });
  });

  group('respuesta secreta', () {
    test('no se guarda tal cual: se guarda su hash', () {
      final hash = Autenticacion.hashDeRespuesta('Fido', 'adalid');
      expect(hash, isNot(contains('Fido')));
      expect(hash.length, 64); // sha256 en hexadecimal
    });

    test('no importa como la escriba: mayusculas y espacios dan igual', () {
      final a = Autenticacion.hashDeRespuesta('Mi Perro Fido', 'adalid');
      final b = Autenticacion.hashDeRespuesta('  mi perro fido  ', 'adalid');
      expect(a, b);
    });

    test('la misma respuesta de dos usuarios da hashes distintos', () {
      final a = Autenticacion.hashDeRespuesta('Fido', 'adalid');
      final b = Autenticacion.hashDeRespuesta('Fido', 'maria');
      expect(a, isNot(b));
    });

    test('una respuesta equivocada no coincide', () {
      final correcta = Autenticacion.hashDeRespuesta('Fido', 'adalid');
      final errada = Autenticacion.hashDeRespuesta('Firulais', 'adalid');
      expect(correcta, isNot(errada));
    });
  });
}
