# Flujos de usuario

El recorrido principal y los secundarios, cada uno con la evidencia que lo justifica.

---

# Flujo principal — cobrar en la calle

Es el recorrido que la aplicación tiene que resolver bien: el prestamista de pie, con el
cliente enfrente esperando que le diga cuánto debe.

1. **Abre la aplicación**
   - Mira la cámara y entra. Si no lo reconoce, después de tres intentos le pide la
     contraseña.

2. **Ve cuánto tiene que cobrar hoy (Hoy)**
   - La primera tarjeta dice el total exigible y cuántas cuotas son.
   - Bolivianos y dólares van en líneas separadas: sumarlos sería inventar un tipo de
     cambio que él no puso.

3. **Abre la agenda del día (Cobros de hoy)**
   - Las cuotas aparecen ordenadas de la más atrasada a la que todavía no vence.
   - El estado se distingue por icono, color y texto: *Vencida*, *Vence hoy*, *Por vencer*.
   - Cada fila ya trae el monto con la mora sumada.

4. **Consulta el monto exacto (Detalle del préstamo)**
   - Lo primero y más grande de la pantalla es cuánto cobrar hoy.
   - Debajo, en letra chica, de dónde sale: *"Cuota 120 + mora 56 por 7 días de atraso"*.

5. **Registra el cobro**
   - Un botón único: *Registrar pago*.
   - El diálogo abre en *Todo* con el monto ya puesto.
   - Antes de confirmar dice cómo queda: *"Con esto la cuota queda saldada"*.

6. **Todo se actualiza solo**
   - El total del día baja, la cuota pasa a pagada y aparece en *Cobrado hoy*.

---

# Flujos secundarios

## Flujo A — Cobros de hoy (agenda por vencimiento)

**Responde a:** evidencia 1 (se le pasó un cobro y lo notó una semana después) y
evidencia 4 (tiene que reconstruir el saldo con el cliente esperando).

El listado de Préstamos está ordenado por cliente. Esta pantalla ordena por **fecha de
vencimiento**, que es como se cobra en la calle.

```
Hoy -> tocar "Cobros de hoy" -> cuotas por vencimiento -> elegir a quién cobrar
```

## Flujo B — Pago parcial (abono)

**Responde a:** lo que pasa cuando el cliente no junta la cuota completa. Hoy lo anota al
margen del cuaderno y vuelve a sumar después.

1. En el diálogo de cobro toca *Una parte* y escribe lo que recibió.
2. Mientras escribe, el diálogo le dice cuánto queda debiendo.
3. No lo deja pasarse del monto ni registrar cero.
4. El botón cambia a *Registrar otro abono* hasta que la cuota se salda.

## Flujo C — Perdonar el recargo

**Responde a:** evidencia 2 (*"a veces perdona el atraso solo por no calcularlo"*) y a la
pregunta que el brief dejó abierta sobre si aceptaría la mora calculada por el sistema.

Al cobrar una cuota atrasada aparece una casilla: *"Perdonarle los Bs 56 de recargo"*. Al
marcarla, el monto a cobrar baja a la cuota sola.

Si la aplicación no lo permitiera, el prestamista terminaría cobrando un monto y anotando
otro, que es exactamente lo que se quiere evitar.

## Flujo D — Historial de pagos

**Responde a:** evidencia 3 (sumó mal, cobró de más, el cliente reclamó y tuvo que
descontárselo).

En el detalle del préstamo, debajo del plan de cuotas, está todo lo que esa persona
entregó, con fecha y monto, y el total abajo. Es el comprobante que antes no tenía.

## Flujo E — Consulta rápida de un cliente

**Responde a:** evidencia 4, el cliente esperando mientras él busca en el cuaderno.

```
Clientes -> buscar por nombre o teléfono -> ve cuánto debe, sin abrir nada más
```

El buscador aparece recién cuando hay cinco clientes o más: antes de eso, recorrer la
lista con el dedo es más rápido que escribir.

## Flujo F — Cierre del día

Cuando vuelve del recorrido, la pantalla de inicio le muestra cuánto entró hoy y en
cuántos cobros. Solo aparece si ya cobró algo: antes del primer cobro, un "Bs 0" no aporta
nada y desanima.

## Flujo G — Corregir un error

Un préstamo mal cargado se puede borrar, y los datos de un cliente se pueden editar. Antes
de borrar, la aplicación dice exactamente qué se lleva por delante: *"también se borran
sus 2 préstamos con todas las cuotas y los cobros que ya registraste"*.

Del préstamo solo se puede cambiar el recargo por atraso. El monto, el plazo y las cuotas
quedan fijos: ya hay pagos registrados contra ese plan y cambiarlo dejaría el historial
sin sentido.

## Flujo H — Avisarle al cliente por WhatsApp

**Responde a:** evidencia 1 (se le pasó un cobro y lo notó una semana después). Avisar a
tiempo es más barato que perseguir un atraso.

Desde el detalle del préstamo, el botón *Mandarle el recordatorio* abre el chat del cliente
con el mensaje ya escrito:

> Hola Juan, ¿cómo estás?
>
> Te paso el detalle de tu préstamo: tenés 6 cuotas pendientes, que suman Bs 150.
>
> A eso se suma Bs 30 de recargo por 6 días de atraso.
>
> Total a pagar: Bs 180.
>
> Cualquier cosa avisame. ¡Gracias!

El prestamista solo revisa el texto y envía. Antes tenía que buscar el contacto, acordarse
de cuánto debía y escribirlo a mano, que es justamente donde aparecen los errores de monto.

Si el cliente todavía no vencía, el mensaje cambia de tono: en vez de reclamar, recuerda la
fecha. Si no tiene teléfono cargado, el botón queda apagado y dice por qué.

## Flujo I — Recuperar la cuenta

**Responde a:** la pregunta del brief sobre qué evidencia de persistencia necesita ver
para confiar en el sistema ante la pérdida del dispositivo.

```
Nombre de usuario -> pregunta secreta -> código al correo -> contraseña nueva
```

Cuatro pasos, uno por pantalla, con un indicador de avance arriba. Se hace de a un paso
para no pedirle todo junto a alguien que ya está nervioso porque no puede entrar.
