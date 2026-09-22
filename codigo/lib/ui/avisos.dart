import 'package:flutter/material.dart';

import 'espaciado.dart';

// Los cuatro tonos con los que la app le habla al prestamista.
//
// guia        = te explico que hacer (no pasa nada malo)
// advertencia = ojo con esto, pero podes seguir
// bloqueo     = esto no se puede guardar asi
// exito       = salio bien
//
// Cada nivel lleva color e icono propios. El color nunca va solo: si alguien
// no distingue rojo de naranja, la forma del icono se lo dice igual.
enum NivelAviso { guia, advertencia, bloqueo, exito }

class _EstiloAviso {
  const _EstiloAviso(this.color, this.fondo, this.icono);
  final Color color;
  final Color fondo;
  final IconData icono;
}

_EstiloAviso _estiloDe(NivelAviso nivel) {
  switch (nivel) {
    case NivelAviso.guia:
      return const _EstiloAviso(
        Color(0xFF1B4F72), Color(0xFFE8F0FE), Icons.info_outline);
    case NivelAviso.advertencia:
      return const _EstiloAviso(
        Color(0xFF8A5100), Color(0xFFFFF3E0), Icons.warning_amber_outlined);
    case NivelAviso.bloqueo:
      return const _EstiloAviso(
        Color(0xFFB3261E), Color(0xFFFDECEA), Icons.error_outline);
    case NivelAviso.exito:
      return const _EstiloAviso(
        Color(0xFF1B6B2F), Color(0xFFE6F4EA), Icons.check_circle_outline);
  }
}

// Cartel de aviso dentro de una pantalla. Si el texto viene vacio no ocupa
// lugar, asi se puede dejar puesto sin que moleste cuando no hay nada que decir.
class Aviso extends StatelessWidget {
  const Aviso(this.texto, {super.key, this.nivel = NivelAviso.guia});

  final String texto;
  final NivelAviso nivel;

  @override
  Widget build(BuildContext context) {
    if (texto.isEmpty) return const SizedBox.shrink();

    final estilo = _estiloDe(nivel);
    return Container(
      padding: const EdgeInsets.all(Espaciado.m),
      decoration: BoxDecoration(
        color: estilo.fondo,
        borderRadius: BorderRadius.circular(Espaciado.s),
        border: Border.all(color: estilo.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Espaciado.s,
        children: [
          Icon(estilo.icono, color: estilo.color, size: 22),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(color: estilo.color, fontSize: 15, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

// Aviso pasajero abajo de la pantalla, para confirmar algo que ya ocurrio.
void mostrarAviso(
  BuildContext context,
  String texto, {
  NivelAviso nivel = NivelAviso.exito,
}) {
  final estilo = _estiloDe(nivel);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: estilo.color,
        duration: const Duration(seconds: 4),
        content: Row(
          spacing: Espaciado.s,
          children: [
            Icon(estilo.icono, color: Colors.white, size: 20),
            Expanded(child: Text(texto, style: const TextStyle(fontSize: 15))),
          ],
        ),
      ),
    );
}
