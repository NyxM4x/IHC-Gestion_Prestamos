# Flujo de Usuario (Happy Path)

Flujo principal de la aplicación centrado en la consulta rápida y el cobro en campo.

1. **Apertura y Resumen (Dashboard)**
   |_ Inicia la app y visualiza la pantalla principal.
   |_ Identifica el total de capital prestado y el total recuperado.
   |_ Ve la lista de los últimos 5 pagos realizados.

2. **Revisión de Cobros del Día (Préstamos)**
   |_ Navega a la pestaña de Préstamos.
   |_ Revisa la lista general de cuotas ordenadas por vencimiento.
   |_ Identifica visualmente las cuotas "Por vencer" o "En mora" gracias a la codificación de colores.

3. **Consulta de Monto Exigible en Campo (Detalle)**
   |_ Selecciona una cuota vencida específica desde la lista.
   |_ Visualiza el detalle del préstamo con el saldo actual.
   |_ Verifica el monto exacto a cobrar hoy (cuota + mora ya calculada).

4. **Registro de Cobro**
   |_ El cliente entrega el dinero.
   |_ Presiona el botón "Registrar Pago" en el detalle de la cuota.
   |_ Confirma el monto recibido en la ventana emergente y guarda.

5. **Actualización Automática**
   |_ El sistema actualiza el saldo del cliente.
   |_ La cuota cambia su estado a "Pagada" (y desaparece de las alertas rojas).
   |_ El monto recaudado se suma al total del Dashboard.