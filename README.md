# Gestión de Préstamos Privados y Billetera de Clientes

## Integrantes
* **Adalid Grageda Rojas** — 221044574
## Contexto Académico
* **Materia:** Interacción Hombre-Computador (IHC)

## Tipo de proyecto
Aplicación Móvil (Desarrollada en Flutter / Dart) — Fase actual: Prototipo Funcional (Mocked MVP).

## Modalidad de implementación
Sin IA / sin agentes de inteligencia artificial.

## Problema inicial
Los prestamistas independientes o informales gestionan su cartera de clientes, préstamos y cobros de forma manual (cuadernos, hojas de cálculo sueltas o memoria). Esto genera desorden, errores matemáticos al calcular cuotas o intereses, y una alta carga cognitiva al intentar revisar rápidamente el estado de la deuda de un prestatario.

## Solución Propuesta
La app busca optimizar la usabilidad y reducir la carga cognitiva del prestamista mediante una interfaz modesta y directa. Permite:
1. **Gestionar Clientes:** Registro rápido de prestatarios y visualización de su "Billetera" (saldo deudor vs. abonado).
2. **Plantillas de Préstamos:** Creación ágil de créditos usando modalidades predefinidas (ej. Cuota Fija mensual) para evitar cálculos manuales.
3. **Control de Cuotas:** Generación automática del plan de pagos, permitiendo al administrador visualizar de un vistazo las cuotas pendientes, pagadas o en mora.
## Entregable de hoy (jueves) — Jerarquía, layout y espaciado

**Qué se pedía:** elegir una pantalla del proyecto y mejorarla aplicando jerarquía visual
(que se note qué es lo más importante), layout (cómo se ordenan los bloques) y espaciado
(que las distancias sigan una regla y no sean números al azar). Además, dejar por escrito
las decisiones y probarlas con una persona real.

**Qué se hizo:** se trabajó la pantalla **Detalle del préstamo**.

* **Antes:** la pantalla mostraba una tarjeta con tres líneas del mismo tamaño y, debajo,
  la lista completa de cuotas. Todo pesaba igual, así que el prestamista tenía que buscar
  a mano la cuota por vencer y sumar la mora de cabeza. Tampoco había ningún botón: la
  pantalla solo se leía, no se podía registrar el cobro. Los espacios entre elementos eran
  números sueltos escritos uno por uno, así que cosas sin relación se veían igual de juntas
  que cosas relacionadas.
* **Después:** lo primero que se ve es **cuánto hay que cobrar hoy**, en grande y dentro de
  una tarjeta destacada, con el desglose de cuota más mora debajo. Justo abajo hay un único
  botón, *Registrar pago*, que pide confirmación mostrando el monto. La lista de cuotas pasó
  al final, porque es detalle y no lo primero que se necesita. Todas las separaciones salen
  ahora de una misma escala de 8 px: poco espacio dentro de un bloque, más espacio entre
  bloques y todavía más entre secciones.

**Archivos entregados:**
* [`diseno/wireframe-detalle-prestamo.md`](diseno/wireframe-detalle-prestamo.md) — el wireframe con el nuevo orden de la pantalla.
* [`diseno/registro-decisiones.md`](diseno/registro-decisiones.md) — las tres decisiones explicadas con antes / después.
* [`codigo/lib/ui/espaciado.dart`](codigo/lib/ui/espaciado.dart) — la escala de espaciado.
* [`codigo/lib/screens/prestamos/detalle_prestamo_screen.dart`](codigo/lib/screens/prestamos/detalle_prestamo_screen.dart) — la pantalla ya con la mejora aplicada.

