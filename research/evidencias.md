# Evidencias — Control de cobros para prestamistas

Cuatro dolores del prestamista informal, cada uno anclado en lo observado.
Fuente: entrevista a un prestamista informal con cartera de 15 a 25 préstamos activos,
registro en cuaderno de papel y cálculo manual de intereses.

---

## Dolor 1 — La cartera no tiene estado consultable: no se sabe a quién cobrar hoy
El registro en papel está organizado por cliente, no por vencimiento. Determinar quién
está atrasado exige recorrer secuencialmente todo el cuaderno cada mañana. El olvido de
un cobro no es descuido del usuario: es consecuencia directa de que el dato no existe
como consulta, sino como búsqueda manual.

**Observado:** un cobro se detectó una semana después de vencido; para entonces el
cliente ya había dispuesto del dinero de esa cuota.

**Costo:** cobros perdidos o recuperados tarde, con menor probabilidad de pago.

---

## Dolor 2 — El interés de mora no se cobra porque calcularlo cuesta más que perderlo
La mora depende de los días transcurridos, así que su valor cambia cada día y debe
recalcularse en cada cobro. El papel no sostiene ese cálculo. Ante la fricción, el
usuario opta por no aplicar el recargo. Es una fuga de ingresos sistemática, no una
decisión comercial.

**Observado:** en un préstamo con dos semanas de atraso el cálculo se abandonó a mitad
de camino y se cobró la cuota sin recargo. El usuario reconoce que repite esa decisión
con frecuencia.

**Costo:** ingresos no percibidos en cada atraso de la cartera.

---

## Dolor 3 — El cálculo manual introduce errores que erosionan la confianza
Cada consulta de saldo implica rehacer una suma sobre un registro con tachaduras y
correcciones acumuladas. La tasa de error es inevitable, y el error no se paga solo en
dinero: se paga en credibilidad frente a un cliente recurrente.

**Observado:** un error de suma derivó en un cobro superior al correspondiente; el
cliente lo detectó y hubo que compensarlo en la cuota siguiente.

**Costo:** relación dañada en un negocio que se sostiene enteramente sobre la confianza.

---

## Dolor 4 — La consulta ocurre en campo, donde el registro en papel es inoperable
El saldo no se consulta en un escritorio: se consulta de pie, en la vía pública, con el
cliente esperando una respuesta inmediata. En ese contexto el papel exige superficie de
apoyo, manipulación con ambas manos y varios minutos de cálculo. Es el momento de uso
más frecuente y el peor resuelto.

**Observado:** ante la consulta de un cliente en la calle, el usuario debe extraer el
cuaderno y reconstruir el saldo sumando los registros previos. Identifica esa tarea,
junto con el desplazamiento diario, como su mayor consumo de tiempo y esfuerzo.

**Costo:** tiempo operativo, desgaste del recorrido y respuesta lenta frente al cliente.

---

## Restricciones de adopción (requisitos de diseño, no dolores)
El usuario no rechaza la digitalización por falta de necesidad, sino por dos condiciones
que cualquier solución debe cumplir para ser usada:

1. **Legibilidad en condiciones de campo.** La pantalla se lee de pie, en exteriores y
   con luz solar directa. Requiere jerarquía tipográfica fuerte, contraste alto y datos
   clave legibles de un vistazo, sin zoom ni navegación.
2. **Tolerancia al error y persistencia del dato.** El usuario expresa desconfianza ante
   la posibilidad de eliminar información con una acción involuntaria o de perder el
   registro junto con el dispositivo. Exige confirmación explícita en acciones
   destructivas y almacenamiento remoto verificable.

**Observado:** el uso actual del dispositivo se limita a mensajería y calculadora; la
principal objeción declarada es la dificultad de lectura de la interfaz.

---

## Por qué esto justifica el producto
Los cuatro dolores comparten una única causa: **el estado de la cartera no existe como
dato, existe como cálculo que debe rehacerse en cada consulta**. Todo lo demás —el
olvido, la mora no cobrada, el error de suma, la lentitud en campo— se deriva de ahí.

La solución no es digitalizar el cuaderno. Es convertir ese cálculo recurrente en estado
persistente: cada cuota con su fecha, su estado y su monto exigible ya resueltos y
consultables en segundos, presentados con una jerarquía visual que permita decidir de
un vistazo en condiciones de campo.

## Lo que aprendimos que no sabíamos al escribir v0.1
1. La legibilidad en campo es una restricción de adopción, no una mejora estética.
2. La mora no se calcula mal: no se cobra. Automatizarla tiene retorno económico directo.
3. El contexto de uso crítico es la consulta en campo con el cliente presente, no la
   planificación previa.
4. La confianza en la persistencia del dato pesa tanto como cualquier funcionalidad.