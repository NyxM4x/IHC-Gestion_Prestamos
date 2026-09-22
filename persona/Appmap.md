# Mapa de la Aplicación

Estructura de navegación y pantallas.

## Estructura de archivos

```
lib/
|_ main.dart                     arranque y portero de entrada
|_ modelos/
|  |_ cliente.dart
|  |_ prestamo.dart
|  |_ cuota.dart
|  |_ pago.dart
|_ logica/
|  |_ plan_cuotas.dart           genera el plan de pagos
|  |_ mora.dart                  recargo por atraso y monto a cobrar
|  |_ fechas.dart                vencimientos y formato de fecha
|  |_ control_acceso.dart        los escalones de ingreso
|  |_ identificadores.dart
|_ datos/
|  |_ configuracion.dart         lee las claves del archivo .env.local
|  |_ conexion.dart              arranca Supabase
|  |_ autenticacion.dart         cuentas, códigos y recuperación
|  |_ repositorio.dart           consultas a la base de datos
|_ estado/
|  |_ cartera.dart               única fuente de datos de la aplicación
|_ ui/
|  |_ espaciado.dart             escala de 8 px
|  |_ tema.dart                  colores de estado, tipografía, tamaños táctiles
|  |_ breakpoints.dart           cortes de pantalla y ancho máximo de lectura
|  |_ avisos.dart                los cuatro tonos de alerta
|  |_ confirmar.dart             confirmación antes de borrar
|  |_ formato.dart               montos y monedas
|  |_ vista_cartera.dart         carga, error y estados vacíos
|_ screens/
   |_ home_shell.dart            navegación que cambia según el ancho
   |_ acceso/
   |  |_ acceso_screen.dart      bienvenida e ingreso
   |  |_ registro_screen.dart
   |  |_ codigo_screen.dart
   |  |_ recuperar_screen.dart
   |_ dashboard/
   |  |_ dashboard_screen.dart
   |_ cobros/
   |  |_ cobros_hoy_screen.dart
   |_ clientes/
   |  |_ clientes_screen.dart
   |  |_ nuevo_cliente_screen.dart
   |  |_ detalle_cliente_screen.dart
   |_ prestamos/
      |_ prestamos_screen.dart
      |_ nuevo_prestamo_screen.dart
      |_ detalle_prestamo_screen.dart
      |_ registro_pago_dialog.dart
```

## Entrada a la aplicación

Al abrir, el portero decide por dónde entra según si este dispositivo ya tiene una sesión
guardada:

```
                    ¿hay sesión guardada acá?
                       /                  \
                     sí                    no
                     |                      |
              Reconocimiento          Bienvenida
                 facial                 /      \
                    |            Crear cuenta   Ya tengo cuenta
              3 fallos                |              |
                    |             Registro      Contraseña
              Contraseña              |              |
                    |              Código          (entra)
              3 fallos                |
                    |              (entra)
              Recuperación
```

La cara solo aparece cuando hay una sesión guardada que desbloquear. La primera vez en un
dispositivo se pide la contraseña, porque no hay nada que desbloquear todavía.

## Navegación principal

Tres secciones, siempre accesibles. En celular van en una barra inferior; en pantalla
ancha, en una barra lateral.

| Sección | Para qué |
|---|---|
| **Hoy** | Cuánto hay que cobrar, cuánto se cobró y los últimos pagos |
| **Clientes** | Quiénes son, cuánto debe cada uno, con buscador |
| **Préstamos** | Todos los préstamos, filtrables por estado |

## Recorridos

**Principal — cobrar en la calle**
```
Hoy -> Cobros de hoy -> Detalle del préstamo -> Registrar pago
```

**Alta de préstamo**
```
Préstamos -> Nuevo préstamo -> (cliente, monto, interés, frecuencia, cuotas, fecha, mora)
          -> resumen del trato -> Guardar
```

**Consulta rápida en campo**
```
Clientes -> buscar por nombre o teléfono -> Detalle del cliente -> saldo y préstamos
```

**Respaldo ante un reclamo**
```
Detalle del préstamo -> Pagos registrados -> historial y total entregado
```

**Pago parcial**
```
Registrar pago -> "Una parte" -> monto recibido -> queda el saldo de esa cuota
```

**Perdonar el recargo**
```
Registrar pago -> marcar "Perdonarle el recargo" -> el monto baja a la cuota sola
```

**Corregir un error**
```
Detalle del cliente  -> Editar datos / Borrar cliente
Detalle del préstamo -> Cambiar recargo por atraso / Borrar préstamo
```
