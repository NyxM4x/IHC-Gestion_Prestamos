# Gestión de Trámites Internos

Maqueta académica para la materia **Interacción Hombre-Computador (IHC)** — UAGRM.

Proyecto Flutter puro (sin paquetes externos), pensado para correr en **modo web con Chrome**.

## Flujo de la maqueta

```
Pantalla 1: Mis Datos Personales  (se llena una sola vez)
        |
        v
Pantalla 2: Registrar Nuevo Trámite  (reutiliza los datos del perfil)
        |
        v
Confirmación (SnackBar "Trámite registrado" + datos en consola)
```

## Requisitos

- Flutter SDK (ver instalación abajo)
- Google Chrome
- Git

### Estado en esta máquina (ya configurado)

| Componente | Versión |
|---|---|
| Flutter | 3.47.1 (stable) en `C:\Users\adali\flutter` |
| Dart | 3.13.1 |
| Extensiones VS Code | Flutter + Dart v3.140.0 |
| Chrome | 151.0.7922.138 |
| Soporte web | Habilitado |

## Instalación de Flutter en Windows

> Nota: **winget NO distribuye el SDK de Flutter** (`Google.Flutter` no existe).
> Chocolatey sí lo tiene (`choco install flutter`) pero exige permisos de
> administrador. El método de abajo no requiere admin.

### Instalación con el ZIP oficial (sin permisos de administrador)

1. Descargar el ZIP estable desde https://docs.flutter.dev/get-started/install/windows
2. Descomprimir en `C:\Users\<tu-usuario>\flutter`
   (NO usar carpetas con espacios ni `C:\Program Files`)
3. Agregar `C:\Users\<tu-usuario>\flutter\bin` al PATH:
   - Tecla Windows → buscar "Editar las variables de entorno de esta cuenta"
   - Seleccionar `Path` → Editar → Nuevo → pegar la ruta
   - Aceptar en todas las ventanas
4. Cerrar y volver a abrir la terminal (y VS Code) para que el PATH se actualice.

En esta máquina ya quedó instalado en `C:\Users\adali\flutter`.

### Verificar la instalación

```powershell
flutter --version
flutter doctor
```

> `flutter doctor` mostrará errores de Android Studio / toolchain de Android.
> **Se pueden ignorar**: este proyecto solo corre en web.

## Extensiones de VS Code

Instalar la extensión **Flutter** (publicada por Dart Code), que instala Dart automáticamente:

```powershell
code --install-extension Dart-Code.flutter --force
```

O desde VS Code: `Ctrl+Shift+X` → buscar "Flutter" → Install.

## Habilitar soporte web

```powershell
flutter config --enable-web
flutter devices
```

En la lista de dispositivos debe aparecer **Chrome (web)**.

## Ejecutar el proyecto

Desde la carpeta `gestion_tramites`:

```powershell
flutter pub get
flutter run -d chrome
```

### Atajos útiles mientras corre

| Tecla | Acción |
|-------|--------|
| `r`   | Hot reload (recargar cambios) |
| `R`   | Hot restart (reiniciar la app) |
| `q`   | Salir |

Los `print(...)` del botón "Guardar" aparecen en la terminal donde corre
`flutter run` y también en la consola de Chrome (`F12` → Console).

## Estructura del proyecto

```
gestion_tramites/
├── lib/
│   └── main.dart        <- todo el código está aquí (2 pantallas)
├── web/
│   ├── index.html
│   └── manifest.json
├── pubspec.yaml         <- configuración, sin paquetes externos
└── README.md
```

## Notas sobre el código

- Todo está en un solo archivo: [lib/main.dart](lib/main.dart)
- Los datos del perfil se guardan en **variables globales simples**
  (`perfilNombre`, `perfilApellido`, `perfilRegistro`, `perfilCarrera`).
- No hay base de datos, ni login, ni validaciones: es solo la maqueta
  del flujo de navegación.
