import 'package:flutter/material.dart';

import 'screens/home_shell.dart';

void main() {
  runApp(const GestionPrestamosApp());
}

class GestionPrestamosApp extends StatelessWidget {
  const GestionPrestamosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Préstamos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}
