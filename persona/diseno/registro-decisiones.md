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
- *Flutter:* la tarjeta genérica se reemplazó por un encabezado de texto y una tarjeta
  destacada con el rótulo "A cobrar hoy", el monto en negrita y grande, y el desglose
  cuota + mora debajo. El plan de cuotas se movió al final, bajo un separador de 32 px.

---
---

# Registro de decisiones — Segunda etapa

Decisiones tomadas al llevar la maqueta a una aplicación con base de datos real. A
diferencia de la anterior, que trabajó una sola pantalla, estas atraviesan toda la
aplicación.

---

## Decisión 2 — Se eliminan las plantillas de préstamo

**Antes:** al crear un préstamo había que elegir entre cuatro modalidades fijas: *Gota a
Gota (Diario)*, *Comercial (Semanal)*, *Pago a Rédito (Mensual)* y *Cuota Fija (Mensual)*.
Cada una traía su forma de calcular el interés.

**Problema:** las plantillas son categorías de banco, no de la calle. El prestamista no
presta "a cuota fija mensual": presta 1.000 y le devuelven 1.200 en diez semanas. Si sus
condiciones no entraban en ninguna de las cuatro, no podía registrar el préstamo.

**Cambio:** se quitaron las modalidades. Ahora define cada término por separado: cuánto
presta, cuánto le devuelven, cada cuánto, en cuántas cuotas, desde cuándo, y si cobra
recargo por atraso.

El interés se puede expresar de dos maneras, porque hay dos formas de pensarlo:

- *como porcentaje* — "le cobro 20%"
- *como monto final* — "le presto 1.000 y me devuelve 1.200"

Las dos llegan al mismo número. La segunda es la que usa el prestamista cuando habla.

**Costo asumido:** la pantalla tiene más campos que antes. Se compensa con un resumen en
lenguaje natural que se rehace con cada tecla y traduce los números a una frase:
*"Juan te paga Bs 120 cada semana, 10 veces, desde el 28/09. Le entregás Bs 1.000 y te
devuelve Bs 1.200 en total. Ganás Bs 200."*

---

## Decisión 3 — Las advertencias aparecen mientras se escribe, no al guardar

**Antes:** los formularios validaban al apretar el botón. El usuario llenaba todo y recién
ahí se enteraba de que algo estaba mal.

**Cambio:** se definieron cuatro tonos de aviso (`codigo/lib/ui/avisos.dart`) y se usan
durante la carga, no al final:

| Tono | Cuándo aparece | Ejemplo |
|---|---|---|
| Guía | Explica qué hacer | "No importan las mayúsculas ni los espacios" |
| Advertencia | Se puede seguir igual | "Esta persona ya tiene 1 préstamo sin terminar" |
| Bloqueo | El dato hace imposible el cálculo | "No puede pasar de Bs 176" |
| Éxito | Confirma que algo salió bien | "El nombre está libre" |

El caso más claro es el nombre de usuario: se consulta si está libre **al salir del
campo**, no al final. Así se entera antes de llenar el correo, la contraseña y la pregunta
secreta.

---

## Decisión 4 — El color nunca comunica solo

**Antes:** el estado de una cuota se distinguía únicamente por color: rojo vencida,
naranja vence hoy, gris por vencer.

**Problema:** quien no distingue rojo de naranja no podía leer la pantalla. Y a pleno sol
la diferencia entre esos dos tonos se pierde incluso con visión normal, que es justamente
la condición de uso declarada en el brief.

**Cambio:** cada estado lleva **color, icono y texto** al mismo tiempo. El color quedó como
refuerzo, no como portador del mensaje.

Los tonos elegidos son oscuros a propósito: la aplicación se usa de pie, en exteriores y
con luz solar directa, donde los colores claros se lavan en la pantalla.

---

## Decisión 5 — Confirmar solo lo irreversible

**Cambio:** se pregunta antes de borrar un cliente o un préstamo, y antes de cerrar sesión.
Para todo lo demás se ejecuta la acción y se avisa con un mensaje al pie de la pantalla.

**Por qué:** preguntar por todo cansa y termina en que la gente aprieta "sí" sin leer. Si
la confirmación aparece pocas veces, se lee.

Además la confirmación dice **qué se pierde exactamente**, no una fórmula genérica:
*"también se borran sus 2 préstamos con todas las cuotas y los cobros que ya registraste"*.

---

## Decisión 6 — De un préstamo solo se puede editar el recargo

**Problema:** permitir editar todo parece más flexible, pero un préstamo con pagos ya
registrados no puede cambiar de monto ni de plazo sin que el historial pierda sentido.

**Cambio:** el monto, el plazo, la frecuencia y las cuotas quedan fijos una vez creado el
préstamo. Si está mal cargado, se borra y se hace de nuevo. Lo único editable es el recargo
por día de atraso, porque es una decisión que el prestamista revisa caso a caso.

---

## Decisión 7 — La mora se puede perdonar al momento de cobrar

**Evidencia que lo motiva:** *"reconoce que a veces perdona el atraso solo por no calcular
la mora"* (evidencia 2 del brief).

**Cambio:** al cobrar una cuota atrasada aparece una casilla para perdonar el recargo. Al
marcarla, el monto a cobrar baja a la cuota sola.

**Por qué:** el prestamista ya perdona la mora en el cuaderno. Si la aplicación no lo
permitiera, terminaría cobrando un monto y anotando otro, y el sistema dejaría de reflejar
la realidad.

Esto contesta la pregunta que el brief dejó abierta sobre si aceptaría el monto de mora
calculado por el sistema: lo acepta, siempre que pueda modificarlo.

**Consecuencia técnica:** la mora no es parte de la cuota, es un recargo aparte. El pago se
guarda completo —es lo que entró a la mano del prestamista— pero lo abonado de la cuota
solo sube hasta saldarla.

---

## Decisión 8 — Bolivianos y dólares nunca se suman

**Problema:** al agregar la posibilidad de prestar en dólares, los totales de la pantalla
de inicio dejaron de tener un único valor posible.

**Cambio:** cada moneda se muestra en su propia línea. La aplicación no convierte ni suma
entre monedas.

**Por qué:** sumarlas exigiría un tipo de cambio que el prestamista no ingresó. Un total
mezclado sería un número inventado, y el objetivo declarado del proyecto es que confíe en
los montos sin recalcularlos.

---

## Decisión 9 — El reconocimiento facial solo desbloquea, no autentica

**Hallazgo durante las pruebas:** apareció una falla que resultó más interesante que el
error en sí. La pantalla de reconocimiento facial se mostraba siempre, incluso en un
dispositivo donde nunca se había iniciado sesión. Al tocarla se entraba a la aplicación
**sin sesión**, y todas las pantallas aparecían vacías.

La base de datos hizo exactamente lo que debía —no devolver datos de un desconocido— pero
para el usuario el efecto era que **había perdido toda su cartera**.

**Cambio:** el reconocimiento facial solo aparece cuando ya hay una sesión guardada en ese
dispositivo. Su función es desbloquear una sesión existente, no crear una. La primera vez
en un celular o computadora se pide la contraseña.

**Aprendizaje que deja:** una aplicación que no distingue *"no tenés datos"* de *"no sé
quién sos"* le miente al usuario en el peor momento posible.

---

## Decisión 10 — Una sola fuente de datos para todas las pantallas

**Problema detectado en pruebas:** se creaba un cliente en la pantalla de Clientes y al ir
a registrar un préstamo, ese cliente no aparecía en la lista de selección. Eran dos listas
distintas en el código que nunca se comunicaban.

**Cambio:** existe una sola `Cartera` (`codigo/lib/estado/cartera.dart`) que carga todo
desde la base, y todas las pantallas leen de ahí. Ninguna pantalla arma listas propias.

**Por qué importa para el usuario:** no es una decisión técnica. Para el prestamista
significa que lo que ve en una pantalla es lo mismo que ve en otra, siempre. El problema
anterior no se corrigió caso por caso: se volvió imposible por construcción.

---

## Decisión 11 — La navegación cambia de forma según el ancho

**Cambio:** en celular el menú va en una barra inferior, al alcance del pulgar. En pantalla
ancha pasa a una barra lateral, extendida con texto cuando hay lugar de sobra. Los cortes
están definidos en `codigo/lib/ui/breakpoints.dart`.

En pantallas anchas el contenido además se centra con un ancho máximo, para que las líneas
de texto no crucen todo el monitor.

**Por qué:** el mismo código corre en el celular del prestamista y en la computadora donde
se presenta el proyecto. Un menú inferior en un monitor de escritorio desperdicia el ancho
y obliga a bajar la vista hasta el borde de la pantalla.

---

## Decisión 12 — Guardar en la nube sabiendo que se cobra en la calle

**La tensión:** el usuario trabaja en exteriores, donde la conexión puede fallar. Una
aplicación que guarda todo en un servidor remoto no abre sin internet.

**Cambio:** se eligió igualmente la base de datos remota.

**Por qué:** contesta la pregunta que el brief dejó abierta sobre qué evidencia de
persistencia necesita ver para confiar en el sistema ante la pérdida del dispositivo. Con
los datos en el servidor, pierde el celular, entra desde otro y su cartera sigue ahí. Con
una base guardada en el teléfono, perder el teléfono sería perder el cuaderno otra vez,
que es exactamente el miedo original.

**Limitación que se asume y queda registrada:** sin conexión la aplicación no muestra los
datos. La solución sería guardar una copia local de la agenda del día para consultarla sin
internet. Queda identificada como el siguiente paso, no resuelta en esta versión.

---

## Decisión 13 — Lo exigible son todas las cuotas vencidas, no solo la primera

**Problema detectado al revisar los flujos:** la agenda del día mostraba únicamente la
cuota más vieja sin pagar de cada préstamo. En un préstamo mensual la diferencia es
inexistente, pero en uno diario es grave: un cliente atrasado seis días acumula seis cuotas
vencidas, y la aplicación mostraba una sola.

El total del día quedaba **subestimado**, que es exactamente el error que el proyecto
existe para evitar.

**Cambio:** el cálculo ahora recorre préstamo por préstamo y suma todas las cuotas que ya
se pueden cobrar, cada una con su propia mora. La fila del cliente dice cuántas está
juntando: *"6 cuotas · desde 12/09"*.

El cobro se sigue registrando de a una cuota, empezando por la más vieja, porque así es
como se salda una deuda. Lo que cambió es lo que se **muestra**, no cómo se cobra.

**Por qué importa:** un monto que se queda corto es peor que no mostrar nada. El
prestamista habría cobrado Bs 25 creyendo que quedaba al día, cuando el cliente le debía
Bs 180.

---

## Decisión 14 — El recordatorio se arma solo, pero lo manda la persona

**Evidencia que lo motiva:** evidencia 1, el cobro que se le pasó y notó una semana
después, cuando la clienta ya había gastado el dinero.

**Cambio:** el detalle del préstamo tiene un botón que abre el chat de WhatsApp del cliente
con el mensaje ya redactado: cuántas cuotas debe, cuánto suman, cuánto es de recargo y por
cuántos días de atraso.

**La decisión de fondo:** la aplicación **no envía nada sola**. Abre el chat con el texto
escrito y el prestamista decide si lo manda, lo corrige o lo cierra.

**Por qué:** un mensaje de cobro automático puede llegar en mal momento o con un tono que
el prestamista no habría usado con un cliente de años. La relación con el deudor es suya,
no del sistema. La aplicación le ahorra el trabajo de calcular y escribir, que es donde se
equivocaba, pero no le saca la decisión de contactar.

El brief v0.2 dejaba "notificaciones y mensajería al cliente" fuera de alcance. Esto no las
contradice: no hay envío automático ni notificaciones. Es un texto preparado para que lo
mande una persona.

**Detalle que apareció al construirlo:** los teléfonos se anotan como en el cuaderno
(`70011223`), sin código de país. La aplicación lo agrega al armar el enlace, y también
tolera las otras formas en que la gente escribe un número: con `+591`, con guiones, con
paréntesis o con espacios.
