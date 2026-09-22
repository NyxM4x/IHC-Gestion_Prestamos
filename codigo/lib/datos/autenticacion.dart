import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'conexion.dart';

// Respuesta de cualquier operacion de cuenta. Si algo sale mal, el mensaje
// esta escrito para que lo lea el prestamista, no para un programador.
class ResultadoAuth {
  const ResultadoAuth.bien([this.mensaje = '']) : exito = true;
  const ResultadoAuth.mal(this.mensaje) : exito = false;

  final bool exito;
  final String mensaje;
}

class Autenticacion {
  // La respuesta secreta nunca viaja ni se guarda tal cual.
  //
  // Se normaliza primero (sin espacios de sobra y todo en minusculas) para que
  // "Mi Perro Fido" y "mi perro fido" cuenten como la misma respuesta: el
  // usuario no tiene por que acordarse de como la escribio.
  //
  // El nombre de usuario se mezcla en el hash a proposito: asi dos personas
  // con la misma respuesta terminan con hashes distintos.
  static String hashDeRespuesta(String respuesta, String nombreUsuario) {
    final limpia = respuesta.trim().toLowerCase();
    final semilla = nombreUsuario.trim().toLowerCase();
    return sha256.convert(utf8.encode('$limpia:$semilla')).toString();
  }

  bool get haySesion => supabase.auth.currentSession != null;

  // Correo de quien ya entro alguna vez en este dispositivo. Sirve para que
  // el acceso diario no vuelva a preguntarlo.
  String? get correoRecordado => supabase.auth.currentUser?.email;

  // --- Crear la cuenta -----------------------------------------------------

  Future<bool> usuarioDisponible(String nombreUsuario) async {
    final libre = await supabase.rpc(
      'usuario_disponible',
      params: {'p_usuario': nombreUsuario},
    );
    return libre == true;
  }

  // Manda el codigo al correo. La cuenta queda creada pero sin confirmar
  // hasta que el codigo se verifique.
  Future<ResultadoAuth> registrar(String correo, String contrasena) async {
    try {
      await supabase.auth.signUp(email: correo, password: contrasena);
      return const ResultadoAuth.bien('Te mandamos un código a tu correo');
    } on AuthException catch (e) {
      return ResultadoAuth.mal(_mensajeClaro(e));
    }
  }

  // Manda otro codigo al mismo correo, sin volver a crear la cuenta.
  Future<ResultadoAuth> reenviarCodigo(String correo) async {
    try {
      await supabase.auth.resend(type: OtpType.signup, email: correo);
      return const ResultadoAuth.bien('Te mandamos un código nuevo');
    } on AuthException catch (e) {
      return ResultadoAuth.mal(_mensajeClaro(e));
    }
  }

  Future<ResultadoAuth> verificarCodigo(String correo, String codigo) async {
    try {
      await supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: correo,
        token: codigo.trim(),
      );
      return const ResultadoAuth.bien();
    } on AuthException catch (e) {
      return ResultadoAuth.mal(_mensajeClaro(e));
    }
  }

  // Se guarda una vez confirmado el correo, con la sesion ya abierta.
  Future<ResultadoAuth> crearPerfil({
    required String nombreUsuario,
    required String preguntaSecreta,
    required String respuestaSecreta,
  }) async {
    final usuario = supabase.auth.currentUser;
    if (usuario == null) {
      return const ResultadoAuth.mal('La sesión se cerró, volvé a empezar');
    }

    try {
      await supabase.from('perfiles').insert({
        'usuario_id': usuario.id,
        'nombre_usuario': nombreUsuario.trim(),
        'pregunta_secreta': preguntaSecreta,
        'respuesta_hash': hashDeRespuesta(respuestaSecreta, nombreUsuario),
      });
      return const ResultadoAuth.bien();
    } on PostgrestException catch (e) {
      // 23505 es el codigo de Postgres para "ese valor ya existe".
      if (e.code == '23505') {
        return const ResultadoAuth.mal('Ese nombre de usuario ya está ocupado');
      }
      return const ResultadoAuth.mal('No se pudo guardar tu perfil');
    }
  }

  // --- Entrar --------------------------------------------------------------

  Future<ResultadoAuth> iniciarSesion(String correo, String contrasena) async {
    try {
      await supabase.auth.signInWithPassword(
        email: correo,
        password: contrasena,
      );
      return const ResultadoAuth.bien();
    } on AuthException catch (e) {
      return ResultadoAuth.mal(_mensajeClaro(e));
    }
  }

  Future<void> cerrarSesion() => supabase.auth.signOut();

  // --- Recuperar la cuenta -------------------------------------------------

  // Pregunta secreta que le toca a ese usuario. Null si no existe.
  Future<String?> preguntaDe(String nombreUsuario) async {
    final pregunta = await supabase.rpc(
      'pregunta_de',
      params: {'p_usuario': nombreUsuario},
    );
    return pregunta as String?;
  }

  // Si la respuesta secreta coincide, devuelve el correo de esa cuenta.
  // Si no, devuelve null sin decir que parte fallo.
  Future<String?> correoSiCoincide({
    required String nombreUsuario,
    required String respuestaSecreta,
  }) async {
    final correo = await supabase.rpc(
      'correo_para_recuperar',
      params: {
        'p_usuario': nombreUsuario,
        'p_respuesta_hash': hashDeRespuesta(respuestaSecreta, nombreUsuario),
      },
    );
    return correo as String?;
  }

  // Manda el codigo para recuperar la cuenta.
  //
  // Se usa codigo y no el enlace del correo: el enlace lleva a una pagina web
  // y esta app no es una pagina, asi que el usuario terminaba en cualquier
  // lado. Con el codigo el recorrido se completa dentro de la app, igual que
  // al crear la cuenta.
  Future<ResultadoAuth> enviarCodigoRecuperacion(String correo) async {
    try {
      await supabase.auth.resetPasswordForEmail(correo);
      return ResultadoAuth.bien(
        'Te mandamos un código a ${_taparCorreo(correo)}',
      );
    } on AuthException catch (e) {
      return ResultadoAuth.mal(_mensajeClaro(e));
    }
  }

  // Verifica el codigo de recuperacion. Si es correcto queda abierta la
  // sesion, que es lo que permite cambiar la contrasena enseguida.
  Future<ResultadoAuth> verificarCodigoRecuperacion(
    String correo,
    String codigo,
  ) async {
    try {
      await supabase.auth.verifyOTP(
        type: OtpType.recovery,
        email: correo,
        token: codigo.trim(),
      );
      return const ResultadoAuth.bien();
    } on AuthException catch (e) {
      return ResultadoAuth.mal(_mensajeClaro(e));
    }
  }

  // Cambia la contrasena de la sesion abierta.
  Future<ResultadoAuth> cambiarContrasena(String nueva) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: nueva));
      return const ResultadoAuth.bien('Tu contraseña quedó cambiada');
    } on AuthException catch (e) {
      return ResultadoAuth.mal(_mensajeClaro(e));
    }
  }

  // --- Ayudas --------------------------------------------------------------

  // Los errores de Supabase vienen en ingles y en tono tecnico. Aca se
  // cambian por frases que digan que hacer.
  String _mensajeClaro(AuthException e) {
    final texto = e.message.toLowerCase();
    if (texto.contains('invalid login')) {
      return 'Esa contraseña no es la correcta';
    }
    if (texto.contains('already registered')) {
      return 'Ese correo ya tiene una cuenta';
    }
    // Supabase manda un solo mensaje para las dos causas ("expired or is
    // invalid"), asi que no se puede afirmar cual fue: se nombran ambas.
    if (texto.contains('expired') || texto.contains('token')) {
      return 'Ese código no coincide o ya venció. Revisá que lo hayas '
          'copiado completo, o pedí uno nuevo';
    }
    if (texto.contains('password')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    // El servidor de correo puede fallar aunque la cuenta se haya creado bien.
    // Si se dijera "revisá tu conexión" se buscaria el problema donde no esta.
    if (texto.contains('sending') || texto.contains('email')) {
      return 'Tu cuenta se creó, pero no pudimos mandarte el código. '
          'Probá con "mandar otro" en un momento';
    }
    if (texto.contains('rate limit') || texto.contains('too many')) {
      return 'Demasiados intentos seguidos. Esperá un minuto y probá de nuevo';
    }
    // Ultimo recurso: se muestra lo que dijo el servidor en vez de inventar
    // una causa. Un mensaje raro es mejor que uno que apunta al lado equivocado.
    return 'No se pudo completar: ${e.message}';
  }

  // juan@gmail.com se muestra como j***@gmail.com
  String _taparCorreo(String correo) {
    final partes = correo.split('@');
    if (partes.length != 2 || partes[0].isEmpty) return correo;
    return '${partes[0][0]}***@${partes[1]}';
  }
}
