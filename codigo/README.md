# Gestión de Préstamos — MVP en Flutter

Maqueta académica para la materia **Interacción Hombre-Computador (IHC)** — UAGRM.
Proyecto Flutter puro (sin paquetes externos), pensado para correr en **web con Chrome**.

## Flujo de la maqueta

```
Dashboard  ->  Préstamos  ->  Detalle del préstamo  ->  Registrar pago
(resumen)      (lista con     (monto a cobrar hoy      (diálogo de
               filtros)        + plan de cuotas)        confirmación)
```

También hay pestaña de **Clientes** con alta y detalle.

## Requisitos

- Flutter SDK (canal stable) con soporte web habilitado
- Google Chrome

## Cómo ejecutar

Desde esta carpeta (`codigo/`):

```powershell
flutter pub get
flutter run -d chrome
```

Atajos mientras corre: `r` hot reload, `R` hot restart, `q` salir.

## Qué revisar en esta entrega

La pantalla intervenida es **Detalle del préstamo**: abrir la pestaña *Préstamos*,
tocar "María Gutiérrez" y observar el orden de lectura (cliente → monto a cobrar hoy →
botón *Registrar pago* → plan de cuotas).

## Estructura

```
codigo/
├── lib/
│   ├── main.dart
│   ├── ui/espaciado.dart
│   └── screens/
│       ├── home_shell.dart
│       ├── dashboard/
│       ├── clientes/
│       └── prestamos/
├── web/
└── pubspec.yaml
```

## Notas

Los datos son de ejemplo y viven en memoria: no hay base de datos, login ni backend.
