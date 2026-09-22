import 'package:flutter/material.dart';

import '../../datos/autenticacion.dart';
import '../../ui/avisos.dart';
import '../../ui/breakpoints.dart';
import '../../ui/espaciado.dart';
import 'codigo_screen.dart';

// Preguntas armadas de antemano: es mas facil elegir una de una lista que
// inventarla, y evita que alguien escriba una pregunta que despues no recuerde.
const preguntasSecretas = [
  '¿Cómo se llamaba tu primera mascota?',
  '¿En qué barrio creciste?',
  '¿Cuál fue tu primer trabajo?',
  '¿Cómo se llama tu mejor amigo de la infancia?',
  '¿Cuál es tu comida favorita?',
];

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _auth = Autenticacion();

  final _usuarioCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  final _respuestaCtrl = TextEditingController();
  final _usuarioFoco = FocusNode();

  String _pregunta = preguntasSecretas.first;
  bool _verContrasena = false;
  bool _ocupado = false;
  String _avisoUsuario = '';
  NivelAviso _nivelUsuario = NivelAviso.guia;
  String _error = '';

  @override
  void initState() {
    super.initState();
    // Al salir del campo se consulta si ese nombre esta libre, asi el usuario
    // se entera antes de llenar todo lo demas.
    _usuarioFoco.addListener(() {
      if (!_usuarioFoco.hasFocus) _revisarDisponibilidad();
    });
  }

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    _respuestaCtrl.dispose();
    _usuarioFoco.dispose();
    super.dispose();
  }

  // --- Validaciones que se muestran mientras escribe -----------------------

  String? get _problemaUsuario {
    final valor = _usuarioCtrl.text.trim();
    if (valor.isEmpty) return null; // todavia no escribio nada
    if (valor.length < 3) return 'Tiene que tener al menos 3 letras';
    if (valor.contains(' ')) return 'No puede llevar espacios';
    return null;
  }

  String? get _problemaCorreo {
    final valor = _correoCtrl.text.trim();
    if (valor.isEmpty) return null;
    if (!valor.contains('@') || !valor.contains('.')) {
      return 'Escribí un correo completo, como juan@gmail.com';
    }
    return null;
  }

  String? get _problemaContrasena {
    final valor = _contrasenaCtrl.text;
    if (valor.isEmpty) return null;
    if (valor.length < 6) return 'Le faltan ${6 - valor.length} caracteres';
    return null;
  }

  bool get _puedeCrear {
    return _usuarioCtrl.text.trim().length >= 3 &&
        _problemaUsuario == null &&
        _correoCtrl.text.trim().isNotEmpty &&
        _problemaCorreo == null &&
        _contrasenaCtrl.text.length >= 6 &&
        _respuestaCtrl.text.trim().isNotEmpty &&
        _nivelUsuario != NivelAviso.bloqueo;
  }

  Future<void> _revisarDisponibilidad() async {
    final nombre = _usuarioCtrl.text.trim();
    if (nombre.length < 3 || _problemaUsuario != null) return;

    try {
      final libre = await _auth.usuarioDisponible(nombre);
      if (!mounted) return;
      setState(() {
        _avisoUsuario = libre
            ? 'El nombre "$nombre" está libre'
            : 'Ese nombre ya está ocupado, probá con otro';
        _nivelUsuario = libre ? NivelAviso.exito : NivelAviso.bloqueo;
      });
    } catch (_) {
      // Si no hay internet no se bloquea el registro: se revisa al guardar.
      if (!mounted) return;
      setState(() => _avisoUsuario = '');
    }
  }

  Future<void> _crearCuenta() async {
    setState(() {
      _ocupado = true;
      _error = '';
    });

    final correo = _correoCtrl.text.trim();
    final resultado = await _auth.registrar(correo, _contrasenaCtrl.text);
    if (!mounted) return;

    setState(() => _ocupado = false);

    if (!resultado.exito) {
      setState(() => _error = resultado.mensaje);
      return;
    }

    // Los datos del perfil se guardan recien despues de verificar el codigo,
    // porque hasta entonces todavia no hay sesion abierta.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CodigoScreen(
          correo: correo,
          nombreUsuario: _usuarioCtrl.text.trim(),
          pregunta: _pregunta,
          respuesta: _respuestaCtrl.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear mi cuenta')),
      body: ContenidoCentrado(
        anchoMaximo: 480,
        child: ListView(
          padding: const EdgeInsets.all(Espaciado.m),
          children: [
            const Aviso(
              'Esta cuenta guarda tu cartera. Si perdés el celular, entrás '
              'desde otro y tus préstamos siguen ahí.',
            ),
            const SizedBox(height: Espaciado.l),

            Text('Tu nombre de usuario', style: textos.titleMedium),
            const SizedBox(height: Espaciado.s),
            TextField(
              controller: _usuarioCtrl,
              focusNode: _usuarioFoco,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'Por ejemplo: adalid',
                errorText: _problemaUsuario,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              onChanged: (_) => setState(() {
                _avisoUsuario = '';
                _nivelUsuario = NivelAviso.guia;
              }),
            ),
            if (_avisoUsuario.isNotEmpty) ...[
              const SizedBox(height: Espaciado.s),
              Aviso(_avisoUsuario, nivel: _nivelUsuario),
            ],

            const SizedBox(height: Espaciado.l),

            Text('Tu correo', style: textos.titleMedium),
            const SizedBox(height: Espaciado.xs),
            Text(
              'Te vamos a mandar un código para confirmar que es tuyo',
              style: textos.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: Espaciado.s),
            TextField(
              controller: _correoCtrl,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'juan@gmail.com',
                errorText: _problemaCorreo,
                prefixIcon: const Icon(Icons.mail_outline),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: Espaciado.l),

            Text('Tu contraseña', style: textos.titleMedium),
            const SizedBox(height: Espaciado.s),
            TextField(
              controller: _contrasenaCtrl,
              obscureText: !_verContrasena,
              decoration: InputDecoration(
                hintText: 'Al menos 6 caracteres',
                errorText: _problemaContrasena,
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
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: Espaciado.l),

            Text('Por si olvidás la contraseña', style: textos.titleMedium),
            const SizedBox(height: Espaciado.s),
            DropdownButtonFormField<String>(
              initialValue: _pregunta,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.help_outline),
              ),
              items: preguntasSecretas.map((p) {
                return DropdownMenuItem(value: p, child: Text(p));
              }).toList(),
              onChanged: (valor) => setState(() => _pregunta = valor!),
            ),
            const SizedBox(height: Espaciado.s),
            TextField(
              controller: _respuestaCtrl,
              decoration: const InputDecoration(
                hintText: 'Tu respuesta',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Espaciado.s),
            const Aviso(
              'No importan las mayúsculas ni los espacios. Guardá una respuesta '
              'que no cambie con el tiempo.',
            ),

            if (_error.isNotEmpty) ...[
              const SizedBox(height: Espaciado.m),
              Aviso(_error, nivel: NivelAviso.bloqueo),
            ],

            const SizedBox(height: Espaciado.xl),

            FilledButton(
              onPressed: _puedeCrear && !_ocupado ? _crearCuenta : null,
              child: _ocupado
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear mi cuenta'),
            ),
            const SizedBox(height: Espaciado.l),
          ],
        ),
      ),
    );
  }
}
