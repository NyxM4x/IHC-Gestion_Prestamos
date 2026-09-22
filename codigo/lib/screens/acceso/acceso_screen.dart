import 'package:flutter/material.dart';

import '../../datos/autenticacion.dart';
import '../../logica/control_acceso.dart';
import '../../ui/avisos.dart';
import '../../ui/breakpoints.dart';
import '../../ui/espaciado.dart';
import '../home_shell.dart';
import 'recuperar_screen.dart';
import 'registro_screen.dart';

// Pantalla de entrada diaria. Arranca por la cara y va bajando de escalon
// sola: a los 3 fallos pide la contrasena, y a los 3 fallos de contrasena
// ofrece recuperar la cuenta. Quien decide en que escalon esta es
// ControlDeAcceso, aca solo se dibuja el paso que toca.
class AccesoScreen extends StatefulWidget {
  const AccesoScreen({super.key});

  @override
  State<AccesoScreen> createState() => _AccesoScreenState();
}

class _AccesoScreenState extends State<AccesoScreen> {
  final _auth = Autenticacion();
  final _control = ControlDeAcceso();
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();

  bool _escaneando = false;
  bool _ocupado = false;
  bool _verContrasena = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    // Si ya entro antes en este celular, el correo no se vuelve a pedir.
    _correoCtrl.text = _auth.correoRecordado ?? '';

    // La cara solo sirve para desbloquear una sesion que ya esta guardada en
    // este dispositivo. Si no hay ninguna (primera vez en este celular o en
    // esta computadora), no hay nada que desbloquear: se pide la contrasena
    // directamente. Sin esto se entraria a la app sin sesion y las pantallas
    // apareceran vacias, porque la base no devuelve datos de un desconocido.
    if (!_auth.haySesion) _control.saltarALaContrasena();
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  void _entrar() {
    // Nunca se entra sin sesion: sin ella la base no devuelve nada y la app
    // se veria vacia, como si se hubieran perdido los datos.
    if (!_auth.haySesion) {
      setState(() {
        _control.saltarALaContrasena();
        _error = 'Necesitamos que entres con tu contraseña la primera vez '
            'en este dispositivo';
      });
      return;
    }

    _control.reiniciar();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (_) => false,
    );
  }

  // --- Reconocimiento facial (simulado en esta version) --------------------
  //
  // Todavia no se usa la camara: se imita el tiempo que tarda el escaneo para
  // poder probar el recorrido completo con usuarios reales. Cuando se conecte
  // la biometria de verdad, lo unico que cambia es el cuerpo de este metodo.

  Future<void> _escanearCara({required bool reconoce}) async {
    setState(() {
      _escaneando = true;
      _error = '';
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    setState(() => _escaneando = false);

    if (reconoce) {
      _entrar();
    } else {
      setState(() => _control.falloLaCara());
    }
  }

  Future<void> _entrarConContrasena() async {
    setState(() {
      _ocupado = true;
      _error = '';
    });

    final resultado = await _auth.iniciarSesion(
      _correoCtrl.text.trim(),
      _contrasenaCtrl.text,
    );
    if (!mounted) return;

    setState(() => _ocupado = false);

    if (resultado.exito) {
      _entrar();
      return;
    }

    setState(() {
      _control.falloLaContrasena();
      _contrasenaCtrl.clear();
      // Cuando se acabaron los intentos manda el aviso del control, que ya
      // explica que sigue; si todavia quedan, se muestra el error puntual.
      _error = _control.paso == PasoDeAcceso.recuperacion
          ? ''
          : resultado.mensaje;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ContenidoCentrado(
          anchoMaximo: 420,
          child: ListView(
            padding: const EdgeInsets.all(Espaciado.m),
            children: [
              const SizedBox(height: Espaciado.xl),
              _Encabezado(paso: _control.paso),
              const SizedBox(height: Espaciado.xl),
              if (_control.paso == PasoDeAcceso.cara) ..._pasoCara(),
              if (_control.paso == PasoDeAcceso.contrasena)
                ..._pasoContrasena(),
              if (_control.paso == PasoDeAcceso.recuperacion)
                ..._pasoRecuperacion(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Los tres pasos ------------------------------------------------------

  List<Widget> _pasoCara() {
    return [
      Center(
        child: _CirculoDeEscaneo(
          escaneando: _escaneando,
          // Un toque largo simula que la camara no reconoce: sirve para
          // ensayar el camino de error durante las pruebas con usuarios.
          onTap: _escaneando ? null : () => _escanearCara(reconoce: true),
          onLongPress:
              _escaneando ? null : () => _escanearCara(reconoce: false),
        ),
      ),
      const SizedBox(height: Espaciado.l),
      Text(
        _escaneando ? 'Reconociéndote...' : 'Tocá el círculo para entrar',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      if (_control.aviso.isNotEmpty) ...[
        const SizedBox(height: Espaciado.l),
        Aviso(_control.aviso, nivel: NivelAviso.advertencia),
      ],
      const SizedBox(height: Espaciado.xl),
      TextButton(
        onPressed: _escaneando
            ? null
            : () => setState(() => _control.saltarALaContrasena()),
        child: const Text('Prefiero entrar con mi contraseña'),
      ),
    ];
  }

  List<Widget> _pasoContrasena() {
    final sabeElCorreo = _auth.correoRecordado != null;

    return [
      if (_control.aviso.isNotEmpty) ...[
        Aviso(_control.aviso, nivel: NivelAviso.advertencia),
        const SizedBox(height: Espaciado.l),
      ],

      // Si ya entro antes, el correo se muestra pero no se pide de nuevo.
      if (sabeElCorreo)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: Text(_auth.correoRecordado!),
          subtitle: const Text('Tu cuenta'),
        )
      else
        TextField(
          controller: _correoCtrl,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Tu correo',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),

      const SizedBox(height: Espaciado.m),

      TextField(
        controller: _contrasenaCtrl,
        obscureText: !_verContrasena,
        autofocus: sabeElCorreo,
        decoration: InputDecoration(
          labelText: 'Tu contraseña',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_verContrasena
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            tooltip: _verContrasena ? 'Ocultar' : 'Ver lo que escribí',
            onPressed: () => setState(() => _verContrasena = !_verContrasena),
          ),
        ),
        onChanged: (_) => setState(() => _error = ''),
        onSubmitted: (_) => _entrarConContrasena(),
      ),

      if (_error.isNotEmpty) ...[
        const SizedBox(height: Espaciado.m),
        Aviso(_error, nivel: NivelAviso.bloqueo),
      ],

      const SizedBox(height: Espaciado.l),

      FilledButton(
        onPressed: _contrasenaCtrl.text.isEmpty || _ocupado
            ? null
            : _entrarConContrasena,
        child: _ocupado
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Entrar'),
      ),

      const SizedBox(height: Espaciado.s),

      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecuperarScreen()),
        ),
        child: const Text('Olvidé mi contraseña'),
      ),
    ];
  }

  List<Widget> _pasoRecuperacion() {
    return [
      Aviso(_control.aviso, nivel: NivelAviso.advertencia),
      const SizedBox(height: Espaciado.l),
      const Aviso(
        'Te vamos a pedir tu nombre de usuario y la respuesta de tu pregunta '
        'secreta. Con eso te mandamos un enlace para poner una contraseña nueva.',
      ),
      const SizedBox(height: Espaciado.xl),
      FilledButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecuperarScreen()),
        ),
        icon: const Icon(Icons.help_outline),
        label: const Text('Recuperar mi cuenta'),
      ),
      const SizedBox(height: Espaciado.m),
      TextButton(
        onPressed: () => setState(() => _control.reiniciar()),
        child: const Text('Volver a intentar'),
      ),
    ];
  }
}

// --- Piezas de la pantalla -------------------------------------------------

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.paso});

  final PasoDeAcceso paso;

  String get _titulo {
    switch (paso) {
      case PasoDeAcceso.cara:
        return 'Hola de nuevo';
      case PasoDeAcceso.contrasena:
        return 'Entrá con tu contraseña';
      case PasoDeAcceso.recuperacion:
        return 'Recuperemos tu cuenta';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _titulo,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Espaciado.xs),
        Text(
          'Gestión de Préstamos',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[700]),
        ),
      ],
    );
  }
}

// Circulo grande que hace de camara. Es el blanco mas facil de acertar con
// el celular en una mano, que es como se abre la app en la calle.
class _CirculoDeEscaneo extends StatelessWidget {
  const _CirculoDeEscaneo({
    required this.escaneando,
    this.onTap,
    this.onLongPress,
  });

  final bool escaneando;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(110),
      child: Container(
        height: 180,
        width: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colores.primaryContainer,
          border: Border.all(
            color: escaneando ? colores.primary : colores.outlineVariant,
            width: escaneando ? 4 : 2,
          ),
        ),
        child: escaneando
            ? const Padding(
                padding: EdgeInsets.all(Espaciado.xl),
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            : Icon(Icons.face_outlined, size: 88, color: colores.primary),
      ),
    );
  }
}

// Pantalla de bienvenida para quien todavia no tiene cuenta.
class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ContenidoCentrado(
          anchoMaximo: 420,
          child: ListView(
            padding: const EdgeInsets.all(Espaciado.m),
            children: [
              const SizedBox(height: Espaciado.xl),
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: Espaciado.l),
              Text(
                'Gestión de Préstamos',
                style: textos.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Espaciado.s),
              Text(
                'Tu cartera ordenada: a quién cobrar hoy y cuánto, sin sacar '
                'la calculadora.',
                style: textos.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Espaciado.xl),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistroScreen()),
                ),
                child: const Text('Crear mi cuenta'),
              ),
              const SizedBox(height: Espaciado.s),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccesoScreen()),
                ),
                child: const Text('Ya tengo cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
