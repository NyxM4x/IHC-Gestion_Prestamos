# Gestión de Préstamos Privados y Billetera de Clientes

## Integrantes
* **Adalid Grageda Rojas** — 221044574

## Contexto Académico
* **Materia:** Interacción Hombre-Computador (IHC)

## Tipo de proyecto
Aplicación móvil y de escritorio desarrollada en Flutter / Dart, con base de datos
PostgreSQL en Supabase. Corre con el mismo código en Android y en navegador.

## Modalidad de implementación
Sin IA / sin agentes de inteligencia artificial.

## Problema
Los prestamistas independientes gestionan su cartera de clientes, préstamos y cobros de
forma manual: cuadernos, hojas sueltas o memoria. El registro en papel está organizado
por cliente y no por fecha de vencimiento, así que responder *"¿a quién le cobro hoy y
cuánto?"* obliga a recorrer el cuaderno y rehacer las sumas a mano, muchas veces con el
cliente esperando enfrente.

De ahí salen los tres problemas que se observaron: cobros vencidos que pasan inadvertidos,
mora que no se aplica porque calcularla cuesta, y errores de suma frente al cliente.

## Solución

**1. La agenda del día, no el listado de clientes.**
La aplicación abre mostrando cuánto hay que cobrar hoy y a quiénes, ordenado por
vencimiento. El monto ya viene con la mora calculada: no hay nada que sumar.

**2. Préstamos sin modalidades impuestas.**
El prestamista define sus propios términos: cuánto presta, cuánto le devuelven —como
porcentaje o como monto fijo—, cada cuánto se paga, en cuántas cuotas y desde cuándo. La
aplicación genera el plan de pagos y muestra el trato resumido en una frase antes de
guardarlo.

**3. Acompañamiento en cada paso.**
Las advertencias aparecen mientras se escribe, no al final: si el nombre de usuario ya
está ocupado, si la fecha de inicio ya pasó, si con esos números no se gana nada, si esa
persona ya tiene un préstamo sin terminar de pagar.

**4. La billetera del cliente.**
Cuánto debe cada persona, en qué préstamos, y el historial completo de lo que entregó,
para poder mostrarlo si alguna vez discute un cobro.

## Estructura del repositorio

```
brief/      El problema, la evidencia y el alcance, versionados
persona/    Usuario objetivo, mapa de pantallas, flujos y decisiones de diseño
research/   Las observaciones que sostienen el problema
codigo/     La aplicación en Flutter
```

Para ejecutar el proyecto, ver [`codigo/README.md`](codigo/README.md).
