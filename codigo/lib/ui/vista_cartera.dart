import 'package:flutter/material.dart';

import '../estado/cartera.dart';
import 'avisos.dart';
import 'espaciado.dart';

// Envoltorio para las pantallas que muestran datos de la cartera.
//
// Se encarga de los tres momentos que tiene cualquier pantalla con datos:
// mientras carga, si algo fallo, y cuando ya hay datos. Asi ninguna pantalla
// tiene que repetir esa logica, y todas avisan igual cuando algo sale mal.
class VistaCartera extends StatelessWidget {
  const VistaCartera({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cartera,
      builder: (context, _) {
        if (cartera.cargando) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartera.error.isNotEmpty) {
          return ListView(
            padding: const EdgeInsets.all(Espaciado.m),
            children: [
              Aviso(cartera.error, nivel: NivelAviso.bloqueo),
              const SizedBox(height: Espaciado.m),
              FilledButton.icon(
                onPressed: cartera.cargarTodo,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          );
        }

        return builder(context);
      },
    );
  }
}

// Mensaje para cuando todavia no hay nada cargado. En vez de una pantalla
// vacia que no dice nada, explica que falta y ofrece el boton para hacerlo.
class SinDatos extends StatelessWidget {
  const SinDatos({
    super.key,
    required this.icono,
    required this.titulo,
    required this.explicacion,
    this.textoBoton,
    this.onBoton,
  });

  final IconData icono;
  final String titulo;
  final String explicacion;
  final String? textoBoton;
  final VoidCallback? onBoton;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: Colors.grey[400]),
            const SizedBox(height: Espaciado.m),
            Text(titulo, style: textos.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: Espaciado.s),
            Text(
              explicacion,
              style: textos.bodyMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            if (textoBoton != null && onBoton != null) ...[
              const SizedBox(height: Espaciado.l),
              FilledButton.icon(
                onPressed: onBoton,
                icon: const Icon(Icons.add),
                label: Text(textoBoton!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
