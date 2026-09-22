// Por donde va el prestamista al entrar a la app.
// Siempre arranca por la cara y solo baja de escalon cuando algo falla.
enum PasoDeAcceso { cara, contrasena, recuperacion }

// Lleva la cuenta de los intentos fallidos y decide que mostrar.
//
// Se reinicia al cerrar la app: es una ayuda para el que se equivoca, no un
// candado de seguridad. Quien de verdad frena los intentos repetidos es
// Supabase, que limita cuantas veces seguidas se puede probar una contrasena.
class ControlDeAcceso {
  static const maxIntentos = 3;

  int _fallosCara = 0;
  int _fallosContrasena = 0;

  PasoDeAcceso get paso {
    if (_fallosContrasena >= maxIntentos) return PasoDeAcceso.recuperacion;
    if (_fallosCara >= maxIntentos) return PasoDeAcceso.contrasena;
    return PasoDeAcceso.cara;
  }

  // Cuantos intentos le quedan en el paso actual, para poder avisarselo.
  int get intentosRestantes {
    switch (paso) {
      case PasoDeAcceso.cara:
        return maxIntentos - _fallosCara;
      case PasoDeAcceso.contrasena:
        return maxIntentos - _fallosContrasena;
      case PasoDeAcceso.recuperacion:
        return 0;
    }
  }

  // Aviso para mostrar debajo del formulario. Vacio cuando todavia no fallo,
  // porque no tiene sentido alarmar a quien recien llega.
  String get aviso {
    switch (paso) {
      case PasoDeAcceso.cara:
        if (_fallosCara == 0) return '';
        return 'No te reconocimos. Te quedan $intentosRestantes intentos, '
            'después vas a poder entrar con tu contraseña';
      case PasoDeAcceso.contrasena:
        if (_fallosContrasena == 0) {
          return 'No pudimos reconocerte. Entrá con tu contraseña';
        }
        return 'Contraseña incorrecta. Te quedan $intentosRestantes intentos';
      case PasoDeAcceso.recuperacion:
        return 'Vamos a recuperar tu cuenta con tu pregunta secreta';
    }
  }

  void falloLaCara() {
    if (_fallosCara < maxIntentos) _fallosCara++;
  }

  void falloLaContrasena() {
    if (_fallosContrasena < maxIntentos) _fallosContrasena++;
  }

  // Al entrar bien se borra todo, asi el proximo tropiezo empieza de cero.
  void reiniciar() {
    _fallosCara = 0;
    _fallosContrasena = 0;
  }

  // Si el usuario no quiere esperar a fallar tres veces, puede saltar solo.
  void saltarALaContrasena() => _fallosCara = maxIntentos;
}
