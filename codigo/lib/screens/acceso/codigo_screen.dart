import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/autenticacion.dart';
import '../../ui/avisos.dart';
import '../../ui/breakpoints.dart';
import '../../ui/espaciado.dart';
import '../home_shell.dart';

// Segundo paso del registro: confirmar el correo con el codigo que llego.
// Recien cuando el codigo es correcto hay sesion abierta, y por eso es aca
// donde se guardan el nombre de usuario y la pregunta secreta.
class CodigoScreen extends StatefulWidget {
  const CodigoScreen({
    super.key,
    required this.correo,
    required this.nombreUsuario,
    required this.pregunta,
    required this.respuesta,
  });

  final String correo;
  final String nombreUsuario;
  final String pregunta;
  final String respuesta;

  @override
  State<CodigoScreen> createState() => _CodigoScreenState();
}

class _CodigoScreenState extends State<CodigoScreen> {
  final _auth = Autenticacion();
  final _codigoCtrl = TextEditingController();

  bool _ocupado = false;
  String _error = '';

  @override
  void dispose() {
    _codigoCtrl.dispose();
    super.dispose();
  }

  // Supabase deja elegir el largo del codigo (de 6 a 10 digitos) desde su
  // panel, asi que la app no lo da por sentado: acepta cualquiera de esos
  // largos y deja que el servidor diga si coincide.
  static const _largoMinimo = 6;
  static const _largoMaximo = 10;

  bool get _codigoCompleto => _codigoCtrl.text.trim().length >= _largoMinimo;

  // Ya empezo a escribir pero todavia no llega al minimo.
  bool get _faltanDigitos {
    final largo = _codigoCtrl.text.trim().length;
    return largo > 0 && largo < _largoMinimo;
  }

  Future<void> _confirmar() async {
    setState(() {
      _ocupado = true;
      _error = '';
    });

    // Primero el codigo: si esta mal, no tiene sentido seguir.
    final verificado =
        await _auth.verificarCodigo(widget.correo, _codigoCtrl.text);
    if (!mounted) return;

    if (!verificado.exito) {
      setState(() {
        _ocupado = false;
        _error = verificado.mensaje;
      });
      return;
    }

    // Ya hay sesion: se guarda el perfil con el nombre y la pregunta secreta.
    final perfil = await _auth.crearPerfil(
      nombreUsuario: widget.nombreUsuario,
      preguntaSecreta: widget.pregunta,
      respuestaSecreta: widget.respuesta,
    );
    if (!mounted) return;

    if (!perfil.exito) {
      setState(() {
        _ocupado = false;
        _error = perfil.mensaje;
      });
      return;
    }

    mostrarAviso(context, 'Tu cuenta quedó lista, ${widget.nombreUsuario}');
    // Se reemplaza toda la pila: no tiene sentido poder volver al registro.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (_) => false,
    );
  }

  Future<void> _reenviar() async {
    setState(() => _ocupado = true);
    final resultado = await _auth.reenviarCodigo(widget.correo);
    if (!mounted) return;

    setState(() => _ocupado = false);
    mostrarAviso(
      context,
      resultado.mensaje,
      nivel: resultado.exito ? NivelAviso.exito : NivelAviso.bloqueo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmá tu correo')),
      body: ContenidoCentrado(
        anchoMaximo: 420,
        child: ListView(
          padding: const EdgeInsets.all(Espaciado.m),
          children: [
            const SizedBox(height: Espaciado.l),
            Icon(
              Icons.mark_email_unread_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: Espaciado.l),

            Text(
              'Te mandamos un código a:',
              style: textos.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Espaciado.xs),
            Text(
              widget.correo,
              style: textos.titleMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Espaciado.xl),

            // Los digitos van grandes y separados: se leen del correo y se
            // copian a mano, muchas veces con el celular en la otra mano.
            TextField(
              controller: _codigoCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: true,
              maxLength: _largoMaximo,
              // Al copiar del correo se suelen arrastrar espacios: se filtran
              // para que el usuario no tenga que borrarlos a mano.
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
              ),
              decoration: const InputDecoration(counterText: ''),
              onChanged: (_) => setState(() => _error = ''),
            ),

            // Mientras le falten digitos se le dice, en vez de dejarlo
            // preguntandose por que el boton no se enciende.
            if (_faltanDigitos) ...[
              const SizedBox(height: Espaciado.s),
              const Aviso('Copialo completo, tal como llegó al correo'),
            ],

            if (_error.isNotEmpty) ...[
              const SizedBox(height: Espaciado.m),
              Aviso(_error, nivel: NivelAviso.bloqueo),
            ],

            const SizedBox(height: Espaciado.l),

            FilledButton(
              onPressed: _codigoCompleto && !_ocupado ? _confirmar : null,
              child: _ocupado
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirmar'),
            ),

            const SizedBox(height: Espaciado.m),

            TextButton.icon(
              onPressed: _ocupado ? null : _reenviar,
              icon: const Icon(Icons.refresh),
              label: const Text('No me llegó, mandar otro'),
            ),

            const SizedBox(height: Espaciado.m),
            const Aviso(
              'Si no lo ves, revisá la carpeta de correo no deseado.',
            ),
          ],
        ),
      ),
    );
  }
}
