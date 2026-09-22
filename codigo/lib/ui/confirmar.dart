import 'package:flutter/material.dart';

import 'avisos.dart';
import 'espaciado.dart';

// Pregunta antes de borrar algo que no se puede recuperar.
//
// Se usa solo para lo irreversible. Para lo demas es mejor dejar hacer y
// ofrecer deshacer: preguntar por todo cansa y termina en que la gente
// aprieta "si" sin leer.
//
// Devuelve true si la persona confirmo.
Future<bool> confirmarBorrado(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String textoBoton,
  String? advertencia,
}) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mensaje),
          if (advertencia != null) ...[
            const SizedBox(height: Espaciado.m),
            Aviso(advertencia, nivel: NivelAviso.advertencia),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(contexto, false),
          child: const Text('Cancelar'),
        ),
        // El boton que borra va en rojo: tiene que costar apretarlo sin querer.
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFB3261E),
          ),
          onPressed: () => Navigator.pop(contexto, true),
          child: Text(textoBoton),
        ),
      ],
    ),
  );

  return respuesta ?? false;
}
