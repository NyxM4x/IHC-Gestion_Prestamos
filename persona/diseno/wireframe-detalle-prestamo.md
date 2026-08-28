# Wireframe — Detalle del préstamo

Es la pantalla que se abre al tocar a un cliente, para ver cuánto cobrarle hoy y registrar
el pago. Es la única que cambié.

## Antes

Arriba había una tarjeta con la plantilla, el monto total y el estado, los tres del mismo
tamaño, y debajo la lista de cuotas. Como todo pesaba igual, el ojo no sabía dónde parar.
Y el número que de verdad hace falta —cuánto cobrar hoy— no estaba: había que buscar la
cuota por vencer en la lista y sumarle la mora de cabeza. Además la pantalla solo se leía,
no tenía ningún botón.

## Después

Ahora la pantalla se lee de arriba abajo como una frase. Primero el nombre del cliente,
para saber dónde estoy, con la plantilla y el monto total abajo en gris y más chico.
Después, lo más grande de la pantalla, dentro de una tarjeta de color: **cuánto se cobra
hoy**, con el desglose de cuota y mora en letra chica para que se entienda de dónde sale.
Justo debajo, un solo botón de *Registrar pago*, ancho completo y sin necesidad de hacer
scroll. Y al final la lista de cuotas, que sigue estando por si se quiere revisar, pero ya
no compite con el monto.

## Espacios

Antes ponía cualquier número y quedaba desordenado. Ahora todos los espacios salen de una
misma escala de 4, 8, 16, 24 y 32 px que está en

espaciod.dart

cosas que van juntas llevan poco espacio y cosas que no tienen relación llevan mucho, así
el espacio en blanco agrupa solo, sin líneas ni recuadros. La única medida fuera de la
escala es el alto del botón, 48 px, que es el mínimo para tocarlo cómodo con el dedo.
