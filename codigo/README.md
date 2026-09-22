# Gestión de Préstamos — aplicación en Flutter

Proyecto para la materia **Interacción Hombre-Computador (IHC)** — UAGRM.

Aplicación de gestión de préstamos para prestamistas informales, pensada para usarse
**en campo**: de pie, en la calle, con el cliente esperando. Corre con el mismo código
en **celular Android** y en **navegador de escritorio**.

## Estado actual

| Aspecto | Cómo está |
|---|---|
| Datos | Base de datos PostgreSQL en Supabase, con seguridad a nivel de fila |
| Cuentas | Registro con correo, código de verificación y recuperación por pregunta secreta |
| Plataformas | Android y web, con la interfaz adaptada a cada tamaño de pantalla |
| Monedas | Bolivianos y dólares, sin mezclarse entre sí |
| Pruebas | 41 pruebas automáticas sobre los cálculos y la navegación |

## Cómo está organizado el código

```
lib/
├── modelos/      Cliente, Prestamo, Cuota, Pago — los datos y cómo se guardan
├── logica/       Los cálculos: plan de cuotas, mora, fechas, control de acceso
├── datos/        Conexión con Supabase, consultas y autenticación
├── estado/       Cartera: la única fuente de datos que leen todas las pantallas
├── ui/           Espaciado, tema, avisos, breakpoints y piezas compartidas
└── screens/      Las pantallas, agrupadas por tema
    ├── acceso/     Bienvenida, registro, código, ingreso y recuperación
    ├── dashboard/  Resumen del día
    ├── cobros/     Agenda ordenada por vencimiento
    ├── clientes/   Lista, alta, edición y detalle
    └── prestamos/  Lista, alta, detalle y registro de pago
```

La regla que ordena todo: **las pantallas nunca arman listas propias**. Todas leen de
`estado/cartera.dart`. Antes cada pantalla tenía su propia lista y pasaba que una mostraba
un cliente que otra no conocía.

## Cómo ejecutarlo

### 1. Configurar las claves

El proyecto lee sus claves de un archivo `.env.local` que **no se sube al repositorio**.
Se parte de la plantilla:

```
cp .env.ejemplo .env.local
```

Y se completan desde el panel de Supabase, en *Project Settings → API*:

| Variable | De dónde sale | Obligatoria |
|---|---|---|
| `SUPABASE_URL` | Project URL (`https://xxxxx.supabase.co`) | Sí |
| `SUPABASE_ANON_KEY` | anon public key | Sí |
| `MONEDA_POR_DEFECTO` | `BOB` o `USD` | No (por defecto `BOB`) |

La clave `service_role` **no va acá**: quedaría dentro del programa compilado. Los datos
de los clientes se protegen con las políticas definidas en
[`supabase/esquema.sql`](supabase/esquema.sql).

### 2. Crear las tablas

Pegar `supabase/esquema.sql` en el SQL Editor de Supabase y ejecutarlo. Crea las cinco
tablas con sus índices, la seguridad a nivel de fila y las funciones de recuperación.

Para cargar datos de prueba, `supabase/datos_ejemplo.sql` crea cuatro clientes con
préstamos en distintos estados. Se puede correr las veces que haga falta: borra lo
anterior antes de insertar.

### 3. Configurar los correos

En el panel de Supabase, en *Authentication → Email Templates*, hay que reemplazar
`{{ .ConfirmationURL }}` por `{{ .Token }}` en dos plantillas:

- **Confirm signup** — el código para confirmar la cuenta
- **Reset Password** — el código para recuperar la contraseña

Sin este cambio llega un enlace en vez de un código, y el enlace apunta a una página web
que esta aplicación no tiene.

### 4. Levantar la aplicación

```
flutter run -d chrome --dart-define-from-file=.env.local    # en la computadora
flutter run --dart-define-from-file=.env.local              # en el celular
```

Desde VS Code no hace falta escribirlo: las dos configuraciones de `.vscode/launch.json`
ya lo incluyen.

### 5. Pruebas

```
flutter test        # 41 pruebas
flutter analyze     # revisión de código
```

## Adaptación a cada pantalla

Los cortes están en `lib/ui/breakpoints.dart`:

| Tamaño | Ancho | Navegación |
|---|---|---|
| Compacto | menos de 600 px | Barra inferior, al alcance del pulgar |
| Mediano | 600 a 1024 px | Barra lateral con iconos |
| Amplio | más de 1024 px | Barra lateral extendida, con texto |

En pantallas anchas el contenido se centra con un ancho máximo, para que las líneas de
texto no queden incómodas de leer de borde a borde.

## Decisiones que conviene conocer antes de tocar el código

- **La mora no es parte de la cuota.** Es un recargo aparte. Un pago puede ser mayor que
  la cuota porque incluye la mora, pero lo abonado de la cuota solo sube hasta saldarla.
- **De un préstamo solo se puede editar el recargo por atraso.** El monto, el plazo y las
  cuotas no se tocan: ya hay pagos registrados contra ese plan y cambiarlo dejaría el
  historial sin sentido.
- **Después de cada cambio se recarga toda la cartera.** Con 7 a 20 préstamos es
  instantáneo, y evita que quede un dato viejo dando vueltas.
- **El estado nunca se comunica solo con color.** Cada estado lleva color, icono y texto,
  para que se entienda también sin distinguir los colores.
