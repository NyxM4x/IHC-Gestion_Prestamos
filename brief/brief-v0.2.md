# Brief v0.2.0 — Control de cobros para prestamistas informales

## Problema revisado
Después de investigar, la dificultad que se mantiene no es la falta de un sistema, sino
que el prestamista **no puede saber rápidamente a quién cobrar ni cuánto**, sobre todo
en el momento en que más lo necesita: en campo, con el cliente presente. El registro en
papel está organizado por cliente y no por vencimiento, así que cada consulta obliga a
recorrer el cuaderno y rehacer la suma a mano. De ahí se derivan los cobros vencidos que
pasan inadvertidos, la mora que no se aplica por el costo de calcularla, y los errores de
suma frente al cliente.

## Usuario y contexto
Prestamista informal que opera por cuenta propia con comerciantes y vecinos en Santa
Cruz de la Sierra. Cartera de 7 a 20 préstamos activos. Registro en cuaderno de papel,
una hoja por cliente, con cálculo de intereses en calculadora.

Contexto de uso: consulta y cobro en campo, de pie, en exteriores y con luz solar
directa, sin superficie de apoyo y con el cliente esperando respuesta inmediata.

Limitaciones: uso del dispositivo acotado a mensajería y calculadora, sin experiencia
previa con software de gestión; baja tolerancia al error de interfaz; y un objetivo
declarado de reducir el tiempo operativo del ciclo de cobro.

## Evidencia
Ver `research/evidencias.md`. Las cuatro observaciones que sostienen el problema:

1. Se le pasó un cobro y lo notó una semana después; para entonces la clienta ya había
   gastado el dinero de la cuota.
2. En un préstamo con dos semanas de atraso se confundió calculando la mora y terminó
   cobrando la cuota normal. Reconoce que a veces perdona el atraso solo por no calcular.
3. Sumó mal y cobró de más a un cliente; el cliente reclamó y tuvo que descontárselo.
4. Ante la consulta de un cliente en campo debe extraer el cuaderno y reconstruir el
   saldo sumando los registros previos, con el cliente esperando.

## Insight
Antes de administrar la cartera, el prestamista necesita **el estado exigible de cada
deuda disponible como dato consultable**, no como cálculo a rehacer. Ante la pérdida
hipotética del cuaderno, lo primero que intentaría reconstruir es exactamente eso:
deudores y montos. El historial, los reportes y la planificación son secundarios.

## Hipótesis revisada
Si presentamos las cuotas ordenadas por vencimiento, con estado codificado visualmente
(pagada / por vencer / vencida) y el monto exigible ya calculado con la mora incluida,
el prestamista podrá identificar a quién cobrar y enunciar el monto exacto en menos de
15 segundos, sin recurrir a la calculadora.

Falta comprobar: si la jerarquía visual propuesta resulta legible en condiciones de campo,
y si el usuario confía en el monto calculado lo suficiente como para cobrarlo sin
verificarlo manualmente.

## Flujo principal
1. Abre la aplicación y ve la lista de cuotas ordenadas por fecha, con su estado.
2. Identifica una cuota vencida por su codificación visual.
3. Abre el detalle y ve el saldo y el monto exigible hoy, con la mora ya incluida.
4. Cobra y registra el pago.
5. El sistema recalcula el saldo y cambia el estado de la cuota.
6. Vuelve a la lista, donde ese cliente ya no aparece en rojo.

## Alcance de la primera versión

**Entra:**
- Registro de clientes y de préstamos (monto, tasa, plazo).
- Generación automática del plan de cuotas.
- Lista de cuotas ordenada por vencimiento, con estado codificado visualmente y
  jerarquía tipográfica orientada a lectura en campo.
- Cálculo automático de la mora por días de atraso, visible junto al monto.
- Registro de pago de una cuota, con confirmación antes de guardar.

**Queda fuera:**
- Simulador de préstamos con sliders (se evalúa para v2).
- Refinanciamiento y renegociación.
- Notificaciones y mensajería al cliente.
- Reportes, exportación y multiusuario.
- Integración con medios de pago.

## Primer requerimiento
Generar el plan de cuotas de un préstamo y mostrar cada cuota con su estado y su monto
a cobrar hoy, con la mora ya calculada a partir de los días de atraso.

## Criterios de éxito
1. El usuario identifica una cuota vencida y enuncia el monto exigible en menos de
   15 segundos, sin usar la calculadora.
2. El usuario extrae los datos clave de la pantalla principal en una sola mirada, sin
   navegar ni ampliar la vista.
3. El usuario completa el registro de un pago sin asistencia y sin manifestar duda sobre
   si la operación alteró otros datos.

## Preguntas abiertas
- ¿Qué jerarquía tipográfica y qué nivel de contraste se requieren para lectura en
  exteriores? Debe medirse con el usuario, no asumirse.
- ¿Aceptará el monto de mora calculado por el sistema, o requiere poder ajustarlo caso a
  caso, como hace hoy al condonar el recargo?
- ¿Qué evidencia de persistencia del dato necesita ver para confiar en el sistema ante la
  pérdida del dispositivo?
- ¿El criterio de ordenamiento de la pantalla principal debe ser fecha de vencimiento o
  cliente?