# Brief v0.1 — Gestión de Trámites Internos

## Problema
¿Qué situación queremos comprender?

En muchas oficinas (universidad, municipio, empresa) los trámites internos (solicitudes, permisos, certificados) se gestionan con papeles físicos o correos sueltos, por lo que nadie sabe con certeza en qué etapa está su trámite ni quién lo tiene pendiente de revisar.

## Usuario y tarea
¿Quién vive la situación y qué intenta hacer?

El solicitante (estudiante/empleado) intenta enviar un trámite y saber en qué estado está. El encargado/revisor intenta recibir trámites, revisarlos, pedir correcciones si algo falta, y aprobarlos o rechazarlos.

## Contexto
¿Cuándo, dónde y con qué limitaciones ocurre?

Ocurre en cualquier oficina administrativa, de forma continua. La limitación principal es que hoy no existe un lugar único donde ver el estado del trámite; depende de preguntar en persona o por WhatsApp.

## Alcance
¿Qué parte pequeña podemos abordar primero?

Registro de trámite + cambio de estado (Recibido → En revisión → Observado → Aprobado/Rechazado → Cerrado) + vista del solicitante para consultar su estado. Notificaciones push y reportes quedan para después.

## Hipótesis del proyecto
Si el solicitante puede registrar su trámite desde la app y consultar su estado en cualquier momento, y el revisor puede actualizar ese estado desde su propia pantalla, entonces se reducirán las consultas repetitivas ("¿cómo va mi trámite?") y la pérdida de solicitudes, porque toda la información quedará centralizada y visible para ambos.

## Preguntas abiertas para investigar al usuario
1. ¿Cómo haces seguimiento hoy a un trámite que enviaste? ¿Dónde anotas o revisas en qué va?
2. ¿Qué pasa cuando un trámite queda "observado" o incompleto? ¿Cómo te enteras y cómo lo corriges?
3. ¿Cuánto tiempo, en promedio, tarda un trámite en resolverse, y qué es lo que más lo demora?
4. Si eres quien revisa trámites: ¿cómo decides qué revisar primero cuando tienes varios pendientes?
5. ¿Qué información te gustaría ver de un trámite sin tener que preguntarle a nadie?

## Usuarios identificados
1. Estudiante de la facultad que solicita certificados, kardex, o trámites de inscripción/homologación en la UAGRM.
2. Secretaria/encargado administrativo de la carrera o de una oficina, que recibe y procesa esas solicitudes.

## Conversación breve / observación
