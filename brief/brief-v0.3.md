# Brief v0.3.0 — Control de cobros para prestamistas informales

Esta versión no reemplaza al `brief-v0.2.md`: lo continúa. El problema y la evidencia se
mantienen; lo que cambió es el alcance, y hay preguntas que la v0.2 dejó abiertas y esta
versión ya puede contestar.

## Problema

La dificultad no es la falta de un sistema, sino que el prestamista **no puede saber
rápidamente a quién cobrar ni cuánto**, justo en el momento en que más lo necesita: en
campo, con el cliente presente. El registro en papel está organizado por cliente y no por
vencimiento, así que cada consulta obliga a recorrer el cuaderno y rehacer la suma a mano.

De ahí se derivan los cobros vencidos que pasan inadvertidos, la mora que no se aplica por
el costo de calcularla, y los errores de suma frente al cliente.

## Usuario y contexto

Prestamista informal que opera por cuenta propia con comerciantes y vecinos en Santa Cruz
de la Sierra. Cartera de 7 a 20 préstamos activos. Registro en cuaderno de papel, una hoja
por cliente, con cálculo de intereses en calculadora.

Contexto de uso: consulta y cobro en campo, de pie, en exteriores y con luz solar directa,
sin superficie de apoyo y con el cliente esperando respuesta inmediata.

Limitaciones: uso del dispositivo acotado a mensajería y calculadora, sin experiencia
previa con software de gestión; baja tolerancia al error de interfaz.

## Evidencia

Ver `research/evidencias.md`. Las cuatro observaciones que sostienen el problema:

1. Se le pasó un cobro y lo notó una semana después; para entonces la clienta ya había
   gastado el dinero de la cuota.
2. En un préstamo con dos semanas de atraso se confundió calculando la mora y terminó
   cobrando la cuota normal. Reconoce que a veces perdona el atraso solo por no calcular.
3. Sumó mal y cobró de más a un cliente; el cliente reclamó y tuvo que descontárselo.
4. Ante la consulta de un cliente en campo debe extraer el cuaderno y reconstruir el saldo
   sumando los registros previos, con el cliente esperando.

## Insight

Antes de administrar la cartera, el prestamista necesita **el estado exigible de cada
deuda disponible como dato consultable**, no como cálculo a rehacer.

## Qué cambió respecto de la v0.2

### Las plantillas de préstamo se eliminaron

La v0.2 proponía "modalidades predefinidas" para agilizar la creación de créditos. Al
construirlo quedó claro que era un error de encuadre: las modalidades son categorías de
banco, no de la calle. El prestamista no presta "a cuota fija mensual", presta 1.000 y le
devuelven 1.200 en diez semanas.

Ahora define cada término por separado, y el interés se puede expresar como porcentaje o
como monto final, que es la forma en que realmente lo dice.

### Se agregó la posibilidad de perdonar la mora

La v0.2 calculaba la mora y la presentaba como un dato fijo. La evidencia 2 decía que el
prestamista a veces perdona el atraso. Si el sistema no lo permitiera, él cobraría un monto
y anotaría otro.

### Se agregó cuenta de usuario y almacenamiento remoto

La v0.2 trabajaba con datos en memoria. Esta versión guarda en una base remota con cuenta
propia, lo que responde directamente a la pregunta sobre la pérdida del dispositivo.

## Preguntas de la v0.2 que esta versión contesta

**¿Aceptará el monto de mora calculado, o requiere poder ajustarlo caso a caso?**
Requiere poder ajustarlo. Se resolvió con una casilla para perdonar el recargo al momento
de cobrar, y con la posibilidad de cambiar cuánto cobra por día de atraso en cada préstamo.

**¿Qué evidencia de persistencia necesita ver para confiar ante la pérdida del
dispositivo?**
Se resolvió con cuenta de usuario y datos en servidor remoto: pierde el celular, entra
desde otro y su cartera sigue ahí. Queda pendiente verificar con el usuario si eso le
resulta suficiente o si necesita además algo que pueda ver o imprimir.

**¿El ordenamiento de la pantalla principal debe ser por fecha o por cliente?**
Por fecha de vencimiento. Se resolvió teniendo las dos vistas: la agenda del día ordena por
vencimiento, y la pestaña de Préstamos permite buscar por cliente cuando la consulta nace
de una persona y no de una fecha.

## Alcance de esta versión

**Entra:**
- Cuenta de usuario con verificación por correo y recuperación por pregunta secreta.
- Registro y edición de clientes; registro y borrado de préstamos.
- Préstamos con términos libres, sin modalidades impuestas.
- Generación automática del plan de cuotas.
- Agenda del día ordenada por vencimiento, con estado codificado por color, icono y texto.
- Cálculo automático de la mora, con opción de perdonarla al cobrar.
- Registro de pagos completos y parciales, con confirmación antes de guardar.
- Historial de pagos por préstamo.
- Bolivianos y dólares, sin mezclarse entre sí.
- Interfaz adaptada a celular y a pantalla de escritorio.

**Queda fuera:**
- Funcionamiento sin conexión a internet.
- Simulador de préstamos con deslizadores.
- Refinanciamiento y renegociación.
- Notificaciones y mensajería al cliente.
- Reportes, exportación y multiusuario.
- Integración con medios de pago.

## Criterios de éxito

Se mantienen los tres de la v0.2, que son los que se van a medir en la prueba con usuario:

1. El usuario identifica una cuota vencida y enuncia el monto exigible en menos de
   15 segundos, sin usar la calculadora.
2. El usuario extrae los datos clave de la pantalla principal en una sola mirada, sin
   navegar ni ampliar la vista.
3. El usuario completa el registro de un pago sin asistencia y sin manifestar duda sobre
   si la operación alteró otros datos.

Se agrega uno nuevo, por el cambio en la creación de préstamos:

4. El usuario registra un préstamo con sus propias condiciones sin pedir aclaraciones sobre
   qué significa cada campo.

## Preguntas abiertas de esta versión

- **¿La falta de funcionamiento sin conexión es un impedimento real?** Hay que observarlo
  en campo. Si lo es, la solución sería guardar una copia local de la agenda del día.
- **¿El registro con cuenta y código por correo es una barrera de entrada?** Es un paso que
  se hace una sola vez, pero para alguien sin experiencia previa con software podría ser
  suficiente para abandonar.
- **¿Entiende que perdonar la mora es una decisión suya y no un error del sistema?** La
  casilla dice "Perdonarle los Bs 56 de recargo", pero falta comprobar que se lea así.
- **¿El resumen en lenguaje natural al crear un préstamo aumenta la confianza en el
  cálculo, o lo ignora y revisa los números igual?**
