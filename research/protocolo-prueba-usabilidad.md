# Protocolo de prueba de usabilidad

Prueba de la aplicación de gestión de préstamos con un usuario real.
Duración estimada: **20 a 25 minutos**.

---

## Objetivo

Comprobar los cuatro criterios de éxito del `brief-v0.3.md`, observando a una persona usar
la aplicación sin ayuda.

No se busca que el usuario "apruebe" la aplicación. Se busca encontrar dónde se traba. Un
participante que no logra una tarea es el resultado más valioso de la prueba.

## Antes de empezar

**Preparar:**

- [ ] La aplicación instalada en el celular, con sesión iniciada
- [ ] Los datos de ejemplo cargados (`codigo/supabase/datos_ejemplo.sql`)
- [ ] Cronómetro a mano (el del celular propio, no el del que se está probando)
- [ ] Esta planilla impresa o en una hoja aparte
- [ ] Conexión a internet verificada

**Perfil buscado:** una persona que preste dinero por su cuenta, o que lleve cuentas de
cobros a mano. Si no se consigue, sirve cualquier adulto con poca experiencia en
aplicaciones de gestión. Lo que no sirve es probar con alguien que programa.

## Qué decir al empezar

> "Estoy probando una aplicación para llevar préstamos. **No te estoy evaluando a vos, estoy
> evaluando la aplicación.** Si algo no se entiende, es culpa del diseño, no tuya.
>
> Te voy a pedir que hagas algunas cosas. Contame en voz alta lo que vas pensando: qué
> estás buscando, qué esperás que pase. Si te trabás, decímelo, pero no te voy a ayudar
> enseguida porque justamente eso es lo que necesito ver.
>
> ¿Puedo tomar notas mientras usás la aplicación?"

**Regla durante la prueba:** no ayudar, no señalar la pantalla, no decir "está ahí". Si el
participante se traba más de dos minutos, anotarlo como tarea no lograda y pasar a la
siguiente.

---

## Tarea 1 — Identificar a quién cobrar y cuánto

*Criterio de éxito 1 y 2 del brief.*

**Consigna:**
> "Acabás de salir a cobrar. Decime a quién le tenés que cobrar hoy y cuánto exactamente."

**Medir:** tiempo desde que toca la pantalla hasta que dice un nombre y un monto.

**Se logra si:** dice un nombre y el monto correcto en **menos de 15 segundos**, sin usar
calculadora.

**Observar además:**
- ¿Mira la tarjeta de arriba o se va directo al listado?
- ¿Pregunta si el monto incluye la mora, o lo da por hecho?
- ¿Entiende los estados (Vencida / Vence hoy / Por vencer) sin preguntar?

---

## Tarea 2 — Registrar un cobro completo

*Criterio de éxito 3.*

**Consigna:**
> "Ese cliente te acaba de pagar todo lo que debía de esa cuota. Registralo."

**Medir:** si lo completa sin ayuda, y si al terminar duda de que algo más haya cambiado.

**Se logra si:** llega a confirmar el pago sin asistencia.

**Observar además:**
- ¿Lee el mensaje que dice cómo queda la cuota antes de confirmar?
- Al volver, ¿nota que el total del día bajó?
- ¿Manifiesta alguna duda sobre si se alteró otro dato?

---

## Tarea 3 — Registrar un pago parcial y perdonar el recargo

*Pregunta abierta sobre la mora.*

**Consigna:**
> "Otro cliente está atrasado. Te trae menos de lo que debe, y como es conocido tuyo no le
> querés cobrar el recargo por los días de atraso. Registralo."

**Medir:** si encuentra las dos cosas —perdonar el recargo y cargar un monto parcial— y en
qué orden.

**Se logra si:** completa el registro con el recargo perdonado y un monto menor al total.

**Observar además:**
- ¿Encuentra la casilla de perdonar el recargo, o busca otra forma?
- ¿Entiende que perdonar es una decisión suya y no un error del sistema?
- ¿Ve cuánto queda debiendo antes de confirmar?

---

## Tarea 4 — Registrar un préstamo nuevo

*Criterio de éxito 4.*

**Consigna:**
> "Vas a prestarle a alguien nuevo. Le das 1.500 y te tiene que devolver 1.800 en seis
> cuotas, una por mes. Cargalo."

**Medir:** cuántas veces pide aclaración sobre qué significa un campo.

**Se logra si:** lo registra sin preguntar qué quiere decir ningún campo.

**Observar además:**
- ¿Elige "porcentaje" o "monto fijo"? Esta es la pregunta más interesante de toda la prueba.
- ¿Lee el resumen del final o va directo a guardar?
- ¿Crea al cliente desde dentro del formulario o sale a la pestaña de Clientes?

---

## Preguntas al terminar

1. ¿Qué fue lo más confuso de todo lo que hiciste?
2. Si perdieras el celular ahora mismo, ¿qué creés que pasaría con esta información?
3. ¿Confiarías en el monto que te muestra la aplicación, o lo verificarías con la
   calculadora antes de cobrarle a alguien?
4. ¿Hay algo que hacés con tu cuaderno que acá no encontraste?
5. ¿Usarías esto en la calle, o te parece más para sentarte en tu casa?

---
---

# Planilla de resultados

**Fecha:** ______________  **Duración total:** ______________

**Participante:** ________________________________________________
*(edad aproximada, a qué se dedica, si presta dinero, qué usa hoy para llevar las cuentas)*

**Dispositivo usado:** ☐ Celular propio ☐ Celular del evaluador ☐ Computadora

---

### Resultados por tarea

| # | Tarea | Tiempo | ¿Logró? | ¿Pidió ayuda? |
|---|---|---|---|---|
| 1 | Identificar a quién cobrar y cuánto | ______ s | ☐ Sí ☐ No | ☐ Sí ☐ No |
| 2 | Registrar cobro completo | ______ | ☐ Sí ☐ No | ☐ Sí ☐ No |
| 3 | Pago parcial + perdonar recargo | ______ | ☐ Sí ☐ No | ☐ Sí ☐ No |
| 4 | Registrar préstamo nuevo | ______ | ☐ Sí ☐ No | ☐ Sí ☐ No |

**Tarea 1 — ¿menos de 15 segundos?** ☐ Sí ☐ No
**Tarea 4 — ¿eligió porcentaje o monto fijo?** ☐ Porcentaje ☐ Monto fijo

---

### Dónde se trabó

*Anotar el momento exacto y qué estaba buscando. Una línea por tropiezo.*

| Pantalla | Qué intentaba hacer | Qué pasó |
|---|---|---|
| | | |
| | | |
| | | |
| | | |

---

### Frases textuales

*Lo que dijo en voz alta, con sus palabras. No resumir: las palabras exactas sirven después.*

- "
- "
- "
- "

---

### Respuestas a las preguntas finales

**1. Lo más confuso:**

**2. Si perdiera el celular:**

**3. ¿Confía en el monto?:**

**4. Algo del cuaderno que falta:**

**5. ¿Lo usaría en la calle?:**

---

### Conclusiones del evaluador

**Lo que funcionó:**

**Lo que hay que cambiar, en orden de importancia:**

1.
2.
3.

**Preguntas nuevas que abrió esta prueba:**
