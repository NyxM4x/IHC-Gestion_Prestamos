import 'package:flutter/material.dart';

import 'datos/conexion.dart';
import 'datos/configuracion.dart';
import 'screens/acceso/acceso_screen.dart';
import 'ui/avisos.dart';
import 'ui/breakpoints.dart';
import 'ui/espaciado.dart';
import 'ui/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final conectado = await iniciarSupabase();
  runApp(GestionPrestamosApp(conectado: conectado));
}

class GestionPrestamosApp extends StatelessWidget {
  const GestionPrestamosApp({super.key, this.conectado = true});

  final bool conectado;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Préstamos',
      debugShowCheckedModeBanner: false,
      theme: temaDeLaApp(),
      home: conectado ? const Portero() : const FaltaConfiguracionScreen(),
    );
  }
}

// Decide por donde entra el prestamista al abrir la app.
//
// Si ya habia entrado antes en este dispositivo, la sesion sigue guardada y
// se le pide la cara. Si nunca entro, se le muestra la bienvenida.
class Portero extends StatelessWidget {
  const Portero({super.key});

  @override
  Widget build(BuildContext context) {
    final yaEntroAntes = supabase.auth.currentSession != null;
    return yaEntroAntes ? const AccesoScreen() : const BienvenidaScreen();
  }
}

// Si faltan las variables del archivo .env.local, la app no puede hablar con
// la base. En vez de reventar con un error tecnico, dice exactamente que falta.
class FaltaConfiguracionScreen extends StatelessWidget {
  const FaltaConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faltantes = Configuracion.faltantes.join(', ');

    return Scaffold(
      body: SafeArea(
        child: ContenidoCentrado(
          anchoMaximo: 480,
          child: ListView(
            padding: const EdgeInsets.all(Espaciado.m),
            children: [
              const SizedBox(height: Espaciado.xl),
              Aviso(
                'Falta configurar: $faltantes',
                nivel: NivelAviso.bloqueo,
              ),
              const SizedBox(height: Espaciado.m),
              const Aviso(
                'Copiá el archivo .env.ejemplo como .env.local, completá los '
                'valores desde el panel de Supabase y volvé a levantar la app '
                'con:\n\n'
                'flutter run --dart-define-from-file=.env.local',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
