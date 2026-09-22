import 'package:flutter/material.dart';

// Tres tamanos de pantalla, siguiendo los cortes que recomienda Material 3.
// Compacto  = celular de pie en la calle (el caso principal).
// Mediano   = tablet o ventana angosta en la PC.
// Amplio    = monitor o laptop a pantalla completa.
enum Tamano { compacto, mediano, amplio }

const double _corteMediano = 600;
const double _corteAmplio = 1024;

Tamano tamanoDe(double ancho) {
  if (ancho < _corteMediano) return Tamano.compacto;
  if (ancho < _corteAmplio) return Tamano.mediano;
  return Tamano.amplio;
}

// Atajo para usarlo dentro de un build sin escribir MediaQuery cada vez.
Tamano tamanoDePantalla(BuildContext context) {
  return tamanoDe(MediaQuery.sizeOf(context).width);
}

bool esCompacto(BuildContext context) =>
    tamanoDePantalla(context) == Tamano.compacto;

// Cuantas columnas de tarjetas entran comodas en cada tamano.
int columnasPara(Tamano tamano) {
  switch (tamano) {
    case Tamano.compacto:
      return 1;
    case Tamano.mediano:
      return 2;
    case Tamano.amplio:
      return 3;
  }
}

// En un monitor ancho el texto no debe estirarse de borde a borde: se vuelve
// incomodo de leer. Este widget centra el contenido y le pone un techo.
class ContenidoCentrado extends StatelessWidget {
  const ContenidoCentrado({
    super.key,
    required this.child,
    this.anchoMaximo = 840,
  });

  final Widget child;
  final double anchoMaximo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoMaximo),
        child: child,
      ),
    );
  }
}
