# Registro de decisiones — Jerarquía, layout y espaciado

Pantalla intervenida: **Detalle del préstamo** (`codigo/lib/screens/prestamos/detalle_prestamo_screen.dart`).
El cambio se aplicó solo a este flujo, no a toda la app.

---

## Decisión 1 — El monto a cobrar hoy pasa a ser el elemento principal

**Antes:** la pantalla mostraba una tarjeta con tres líneas del mismo tamaño
(plantilla, monto total, estado) y debajo el plan de cuotas completo. El dato que el
prestamista realmente necesita frente al cliente —cuánto cobrar hoy— no existía en la
pantalla: había que buscar la cuota "Por vencer" en la lista y sumar la mora de cabeza.
Sin jerarquía, todo tenía el mismo peso visual.

**Cambio:**
- *Figma:* se rehízo el wireframe y se subió el monto exigible a una tarjeta de énfasis.
- *Flutter:* una boleta genérica se reemplazó por un encabezado de texto y una tarjeta primaryContainer reflejado:
  "A cobrar hoy" negrita, y un el desglose cuota + mora debajo.
  El plan de cuotas se movió al final, bajo un separador de 32 px.
