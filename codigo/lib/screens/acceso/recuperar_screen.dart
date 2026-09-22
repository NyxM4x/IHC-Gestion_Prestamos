import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/autenticacion.dart';
import '../../ui/avisos.dart';
import '../../ui/breakpoints.dart';
import '../../ui/espaciado.dart';
import '../home_shell.dart';

// Los cuatro momentos de recuperar la cuenta. Se avanza de a uno para no
// pedirle todo junto a alguien que ya esta nervioso porque no puede entrar.
enum PasoRecuperar { usuario, pregunta, codigo, nuevaContrasena }

class RecuperarScreen extends StatefulWidget {
  const RecuperarScreen({super.key});

  @override
  State<RecuperarScreen> createState() => _RecuperarScreenState();
}

class _RecuperarScreenState extends State<RecuperarScreen> {
  final _auth = Autenticacion();

  final _usuarioCtrl = TextEditingController();
  final _respuestaCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();

  PasoRecuperar _paso = PasoRecuperar.usuario;
  String _pregunta = '';
  String _correo = '';
  bool _ocupado = false;
  bool _verContrasena = false;
  String _error = '';
  String _aviso = '';

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _respuestaCtrl.dispose();
    _codigoCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  void _ocupar(bool valor) => setState(() {
        _ocupado = valor;
        if (valor) _error = '';
      });

  // --- Paso 1: encontrar la cuenta ----------------------------------------

  Future<void> _buscarUsuario() async {
    _ocupar(true);
    try {
      final pregunta = await _auth.preguntaDe(_usuarioCtrl.text.trim());
      if (!mounted) return;

      setState(() {
        _ocupado = false;
        if (pregunta == null) {
          _error = 'No encontramos ese nombre de usuario';
        } else {
          _pregunta = pregunta;
          _paso = PasoRecuperar.pregunta;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ocupado = false;
        _error = 'No se pudo consultar. Revisá tu conexión';
      });
    }
  }

  // --- Paso 2: responder la pregunta secreta ------------------------------

  Future<void> _comprobarRespuesta() async {
    _ocupar(true);
    try {
      final correo = await _auth.correoSiCoincide(
        nombreUsuario: _usuarioCtrl.text.trim(),
        respuestaSecreta: _respuestaCtrl.text,
      );
      if (!mounted) return;

      if (correo == null) {
        setState(() {
          _ocupado = false;
          _error = 'Esa no es la respuesta que guardaste';
        });
        return;
      }

      _correo = correo;
      final enviado = await _auth.enviarCodigoRecuperacion(correo);
      if (!mounted) return;

      setState(() {
        _ocupado = false;
        if (enviado.exito) {
          _paso = PasoRecuperar.codigo;
          _aviso = enviado.mensaje;
        } else {
          _error = enviado.mensaje;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ocupado = false;
        _error = 'No se pudo consultar. Revisá tu conexión';
      });
    }
  }

  // --- Paso 3: el codigo del correo ---------------------------------------

  Future<void> _verificarCodigo() async {
    _ocupar(true);
    final resultado = await _auth.verificarCodigoRecuperacion(
      _correo,
      _codigoCtrl.text,
    );
    if (!mounted) return;

    setState(() {
      _ocupado = false;
      if (resultado.exito) {
        _paso = PasoRecuperar.nuevaContrasena;
        _aviso = '';
      } else {
        _error = resultado.mensaje;
      }
    });
  }

  // --- Paso 4: contrasena nueva -------------------------------------------

  Future<void> _guardarContrasena() async {
    _ocupar(true);
    final resultado = await _auth.cambiarContrasena(_contrasenaCtrl.text);
    if (!mounted) return;

    if (!resultado.exito) {
      setState(() {
        _ocupado = false;
        _error = resultado.mensaje;
      });
      return;
    }

    // El codigo ya dejo la sesion abierta, asi que entra directo.
    mostrarAviso(context, 'Listo, tu contraseña quedó cambiada');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (_) => false,
    );
  }

  // --- Dibujo --------------------------------------------------------------

  bool get _puedeSeguir {
    switch (_paso) {
      case PasoRecuperar.usuario:
        return _usuarioCtrl.text.trim().isNotEmpty;
      case PasoRecuperar.pregunta:
        return _respuestaCtrl.text.trim().isNotEmpty;
      case PasoRecuperar.codigo:
        return _codigoCtrl.text.trim().length >= 6;
      case PasoRecuperar.nuevaContrasena:
        return _contrasenaCtrl.text.length >= 6;
    }
  }

  VoidCallback? get _accion {
    if (_ocupado || !_puedeSeguir) return null;
    switch (_paso) {
      case PasoRecuperar.usuario:
        return _buscarUsuario;
      case PasoRecuperar.pregunta:
        return _comprobarRespuesta;
      case PasoRecuperar.codigo:
        return _verificarCodigo;
      case PasoRecuperar.nuevaContrasena:
        return _guardarContrasena;
    }
  }

  String get _textoBoton {
    switch (_paso) {
      case PasoRecuperar.usuario:
        return 'Buscar mi cuenta';
      case PasoRecuperar.pregunta:
        return 'Continuar';
      case PasoRecuperar.codigo:
        return 'Confirmar código';
      case PasoRecuperar.nuevaContrasena:
        return 'Guardar contraseña';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar mi cuenta')),
      body: ContenidoCentrado(
        anchoMaximo: 420,
        child: ListView(
          padding: const EdgeInsets.all(Espaciado.m),
          children: [
            _Progreso(paso: _paso),
            const SizedBox(height: Espaciado.l),

            // Paso 1
            if (_paso == PasoRecuperar.usuario) ...[
              const Aviso(
                'Escribí tu nombre de usuario y te hacemos la pregunta secreta '
                'que elegiste al crear la cuenta.',
              ),
              const SizedBox(height: Espaciado.l),
              Text('Tu nombre de usuario', style: textos.titleMedium),
              const SizedBox(height: Espaciado.s),
              TextField(
                controller: _usuarioCtrl,
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onChanged: (_) => setState(() => _error = ''),
                onSubmitted: (_) => _accion?.call(),
              ),
            ],

            // Paso 2
            if (_paso == PasoRecuperar.pregunta) ...[
              Text(_pregunta, style: textos.titleMedium),
              const SizedBox(height: Espaciado.s),
              TextField(
                controller: _respuestaCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tu respuesta',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                onChanged: (_) => setState(() => _error = ''),
                onSubmitted: (_) => _accion?.call(),
              ),
              const SizedBox(height: Espaciado.s),
              const Aviso('No importan las mayúsculas ni los espacios.'),
            ],

            // Paso 3
            if (_paso == PasoRecuperar.codigo) ...[
              if (_aviso.isNotEmpty) ...[
                Aviso(_aviso, nivel: NivelAviso.exito),
                const SizedBox(height: Espaciado.l),
              ],
              Text('Escribí el código', style: textos.titleMedium),
              const SizedBox(height: Espaciado.s),
              TextField(
                controller: _codigoCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofocus: true,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
                decoration: const InputDecoration(counterText: ''),
                onChanged: (_) => setState(() => _error = ''),
              ),
              const SizedBox(height: Espaciado.s),
              const Aviso('Si no lo ves, revisá el correo no deseado.'),
            ],

            // Paso 4
            if (_paso == PasoRecuperar.nuevaContrasena) ...[
              const Aviso(
                'Listo, ya comprobamos que sos vos. Elegí una contraseña nueva.',
                nivel: NivelAviso.exito,
              ),
              const SizedBox(height: Espaciado.l),
              Text('Tu contraseña nueva', style: textos.titleMedium),
              const SizedBox(height: Espaciado.s),
              TextField(
                controller: _contrasenaCtrl,
                obscureText: !_verContrasena,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Al menos 6 caracteres',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_verContrasena
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    tooltip: _verContrasena ? 'Ocultar' : 'Ver lo que escribí',
                    onPressed: () =>
                        setState(() => _verContrasena = !_verContrasena),
                  ),
                ),
                onChanged: (_) => setState(() => _error = ''),
                onSubmitted: (_) => _accion?.call(),
              ),
            ],

            if (_error.isNotEmpty) ...[
              const SizedBox(height: Espaciado.m),
              Aviso(_error, nivel: NivelAviso.bloqueo),
            ],

            const SizedBox(height: Espaciado.xl),

            FilledButton(
              onPressed: _accion,
              child: _ocupado
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_textoBoton),
            ),
          ],
        ),
      ),
    );
  }
}

// Cuatro puntitos que muestran en que parte del recorrido va. Sirve para que
// no se sienta un tramite sin final.
class _Progreso extends StatelessWidget {
  const _Progreso({required this.paso});

  final PasoRecuperar paso;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final actual = PasoRecuperar.values.indexOf(paso);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: Espaciado.s,
      children: [
        for (var i = 0; i < PasoRecuperar.values.length; i++)
          Container(
            height: 8,
            width: i == actual ? 28 : 8,
            decoration: BoxDecoration(
              color: i <= actual ? colores.primary : colores.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
