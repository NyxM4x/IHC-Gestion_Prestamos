
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------
// VARIABLES GLOBALES

String perfilNombre = '';
String perfilApellido = '';
String perfilRegistro = '';
String perfilCarrera = '';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Trámites Internos',
      // screen perfill
      home: const PantallaPerfil(),
    );
  }
}


// scren 1: DATOS PERSONALES
class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  // Los controladores sirven para leer el texto que escribe el usuario.
  final TextEditingController controlNombre = TextEditingController();
  final TextEditingController controlApellido = TextEditingController();
  final TextEditingController controlRegistro = TextEditingController();
  final TextEditingController controlCarrera = TextEditingController();

  void guardarYContinuar() {
    perfilNombre = controlNombre.text;
    perfilApellido = controlApellido.text;
    perfilRegistro = controlRegistro.text;
    perfilCarrera = controlCarrera.text;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaTramite()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Datos Personales'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Complete sus datos de estudiante:'),
          const SizedBox(height: 20),

          //Nombre
          TextField(
            controller: controlNombre,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 15),

          //Apellido
          TextField(
            controller: controlApellido,
            decoration: const InputDecoration(labelText: 'Apellido'),
          ),
          const SizedBox(height: 15),

          //Registro
          TextField(
            controller: controlRegistro,
            decoration: const InputDecoration(
              labelText: 'Registro universitario',
            ),
          ),
          const SizedBox(height: 15),

          //Carrera
          TextField(
            controller: controlCarrera,
            decoration: const InputDecoration(labelText: 'Carrera'),
          ),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: guardarYContinuar,
            child: const Text('Guardar y continuar'),
          ),
        ],
      ),
    );
  }
}

// screen 2: nuevo tramite

class PantallaTramite extends StatefulWidget {
  const PantallaTramite({super.key});

  @override
  State<PantallaTramite> createState() => _PantallaTramiteState();
}

class _PantallaTramiteState extends State<PantallaTramite> {
  final TextEditingController controlTipo = TextEditingController();
  final TextEditingController controlDescripcion = TextEditingController();
  final TextEditingController controlFecha = TextEditingController();

  void guardarTramite() {
    print('--- TRAMITE REGISTRADO ---');
    print('Nombre: $perfilNombre $perfilApellido');
    print('Registro: $perfilRegistro');
    print('Carrera: $perfilCarrera');
    print('Tipo de tramite: ${controlTipo.text}');
    print('Descripcion: ${controlDescripcion.text}');
    print('Fecha: ${controlFecha.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trámite registrado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nuevo Trámite'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Datos del solicitante:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Nombre: $perfilNombre'),
          Text('Apellido: $perfilApellido'),
          Text('Registro: $perfilRegistro'),
          Text('Carrera: $perfilCarrera'),
          const SizedBox(height: 10),
          // dividir pantalla
          const Divider(),
          const SizedBox(height: 10),

          const Text(
            'Datos del trámite:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          //tipo_tramite
          TextField(
            controller: controlTipo,
            decoration: const InputDecoration(
              labelText: 'Tipo de trámite',
              hintText: 'Ej: Homologación de materias',
            ),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: controlDescripcion,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Descripción / motivo',
            ),
          ),
          const SizedBox(height: 15),

          //fecha
          TextField(
            controller: controlFecha,
            decoration: const InputDecoration(
              labelText: 'Fecha',
              hintText: 'dd/mm/aaaa',
            ),
          ),
          const SizedBox(height: 30),

          //guardar
          ElevatedButton(
            onPressed: guardarTramite,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
