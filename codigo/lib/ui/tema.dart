import 'package:flutter/material.dart';

import '../modelos/cuota.dart';
import 'espaciado.dart';

// Paleta de estados. Son tonos oscuros a proposito: la app se usa de pie, en
// la calle y con sol directo, donde los colores claros se lavan en la pantalla.
const _rojoVencida = Color(0xFFB3261E);
const _naranjaHoy = Color(0xFFB35400);
const _grisPorVencer = Color(0xFF49454F);
const _verdePagada = Color(0xFF1B6B2F);

Color colorDeEstado(EstadoCuota estado) {
  switch (estado) {
    case EstadoCuota.vencida:
      return _rojoVencida;
    case EstadoCuota.venceHoy:
      return _naranjaHoy;
    case EstadoCuota.porVencer:
      return _grisPorVencer;
    case EstadoCuota.pagada:
      return _verdePagada;
  }
}

// Cada estado lleva ademas un icono: si alguien no distingue rojo de naranja,
// la forma se lo dice igual. El color nunca es el unico aviso.
IconData iconoDeEstado(EstadoCuota estado) {
  switch (estado) {
    case EstadoCuota.vencida:
      return Icons.error_outline;
    case EstadoCuota.venceHoy:
      return Icons.today_outlined;
    case EstadoCuota.porVencer:
      return Icons.schedule_outlined;
    case EstadoCuota.pagada:
      return Icons.check_circle_outline;
  }
}

ThemeData temaDeLaApp() {
  final base = ThemeData(
    colorSchemeSeed: Colors.teal,
    useMaterial3: true,
    brightness: Brightness.light,
  );

  return base.copyWith(
    // Los montos se leen de un vistazo, asi que los tamanos suben respecto
    // del tamano por defecto de Material.
    textTheme: base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1.1,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 15),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontSize: 14,
        letterSpacing: 0.2,
      ),
    ),

    // 48 px es el minimo para que un dedo acierte sin mirar. Todos los
    // botones lo cumplen, no solo los que uno se acuerda de estirar.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: Espaciado.l),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
    ),

    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),

    listTileTheme: const ListTileThemeData(
      minVerticalPadding: Espaciado.s,
    ),
  );
}
