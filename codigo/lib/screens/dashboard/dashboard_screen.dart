import 'package:flutter/material.dart';

import '../../datos/autenticacion.dart';
import '../../estado/cartera.dart';
import '../../logica/fechas.dart';
import '../../ui/breakpoints.dart';
import '../../ui/confirmar.dart';
import '../../ui/espaciado.dart';
import '../../ui/formato.dart';
import '../../ui/vista_cartera.dart';
import '../acceso/acceso_screen.dart';
import '../cobros/cobros_hoy_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirmado = await confirmarBorrado(
      context,
      titulo: '¿Cerrar sesión?',
      mensaje: 'Tus datos quedan guardados. Para volver a entrar vas a '
          'necesitar tu contraseña.',
      textoBoton: 'Cerrar sesión',
    );
    if (!confirmado || !context.mounted) return;

    await Autenticacion().cerrarSesion();
    if (!context.mounted) return;

    // Se limpia la cartera en memoria: sin esto los datos del anterior
    // quedarian a la vista mientras carga el siguiente.
    cartera.vaciar();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BienvenidaScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoy'),
        actions: [
          IconButton(
            onPressed: cartera.cargarTodo,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
          PopupMenuButton<String>(
            tooltip: 'Mi cuenta',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (opcion) {
              if (opcion == 'salir') _cerrarSesion(context);
            },
            itemBuilder: (_) => [
              // El correo se muestra apagado, solo para confirmar con que
              // cuenta se esta trabajando. No se puede tocar.
              PopupMenuItem(
                enabled: false,
                child: Text(
                  Autenticacion().correoRecordado ?? 'Mi cuenta',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'salir',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar sesión'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: VistaCartera(
        builder: (context) {
          if (cartera.prestamos.isEmpty) {
            return const SinDatos(
              icono: Icons.wallet_outlined,
              titulo: 'Todavía no tenés préstamos',
              explicacion: 'Cuando registres el primero, acá vas a ver cuánto '
                  'te toca cobrar cada día.',
            );
          }
          return const _Contenido();
        },
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final monedas = cartera.monedasEnUso;
    final cantidad = cartera.cantidadExigibleHoy();

    return ContenidoCentrado(
      child: RefreshIndicator(
        onRefresh: cartera.cargarTodo,
        child: ListView(
          padding: const EdgeInsets.all(Espaciado.m),
          children: [
            _TarjetaCobrosDeHoy(monedas: monedas, cantidad: cantidad),

            // Lo cobrado hoy solo aparece cuando ya cobro algo. Antes del
            // primer cobro del dia un "Bs 0" no aporta nada y desanima.
            if (cartera.cantidadCobradaHoy() > 0) ...[
              const SizedBox(height: Espaciado.m),
              const _CierreDelDia(),
            ],

            const SizedBox(height: Espaciado.l),

            // Las tarjetas se acomodan solas: una debajo de otra en el
            // celular, en fila cuando hay ancho de sobra.
            LayoutBuilder(
              builder: (context, restricciones) {
                final columnas = columnasPara(tamanoDe(restricciones.maxWidth));
                final ancho = columnas == 1
                    ? restricciones.maxWidth
                    : (restricciones.maxWidth - Espaciado.m * (columnas - 1)) /
                        columnas;

                return Wrap(
                  spacing: Espaciado.m,
                  runSpacing: Espaciado.m,
                  children: [
                    for (final moneda in monedas) ...[
                      SizedBox(
                        width: ancho,
                        child: _TarjetaResumen(
                          titulo: 'Prestado en ${nombreMoneda(moneda)}',
                          valor: formatearMonto(
                              cartera.capitalPrestado(moneda), moneda),
                          icono: Icons.account_balance_wallet_outlined,
                        ),
                      ),
                      SizedBox(
                        width: ancho,
                        child: _TarjetaResumen(
                          titulo: 'Recuperado en ${nombreMoneda(moneda)}',
                          valor: formatearMonto(
                              cartera.totalRecuperado(moneda), moneda),
                          icono: Icons.trending_up,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: Espaciado.l),

            Text('Últimos pagos', style: textos.titleMedium),
            const SizedBox(height: Espaciado.s),
            const _UltimosPagos(),
            const SizedBox(height: Espaciado.l),
          ],
        ),
      ),
    );
  }
}

// Lo primero que se busca al abrir la app: cuanto hay que cobrar hoy.
class _TarjetaCobrosDeHoy extends StatelessWidget {
  const _TarjetaCobrosDeHoy({required this.monedas, required this.cantidad});

  final List<String> monedas;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    // Solo las monedas que realmente tienen algo por cobrar hoy.
    final conSaldo =
        monedas.where((m) => cartera.exigibleHoy(m) > 0).toList();

    return Card(
      color: colores.primaryContainer,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CobrosHoyScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Espaciado.m),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cobros de hoy', style: textos.labelLarge),
                    const SizedBox(height: Espaciado.s),
                    if (conSaldo.isEmpty)
                      Text(
                        'Nada por cobrar hoy',
                        style: textos.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      )
                    else
                      // Cada moneda va en su linea: sumarlas seria inventar
                      // un tipo de cambio que el prestamista no puso.
                      for (final moneda in conSaldo)
                        Text(
                          formatearMonto(cartera.exigibleHoy(moneda), moneda),
                          style: textos.displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                    const SizedBox(height: Espaciado.s),
                    Text(
                      cantidad == 1
                          ? '1 cuota por cobrar'
                          : '$cantidad cuotas por cobrar',
                      style: textos.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  final String titulo;
  final String valor;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: Espaciado.s),
            Text(titulo, style: textos.bodyMedium),
            const SizedBox(height: Espaciado.xs),
            Text(
              valor,
              style: textos.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _UltimosPagos extends StatelessWidget {
  const _UltimosPagos();

  @override
  Widget build(BuildContext context) {
    // Los pagos ya vienen del mas nuevo al mas viejo; se muestran los 5.
    final ultimos = cartera.pagos.take(5).toList();

    if (ultimos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(Espaciado.m),
          child: Text('Todavía no registraste ningún cobro'),
        ),
      );
    }

    return Card(
      child: Column(
        children: ultimos.map((pago) {
          final prestamo = cartera.prestamoPorId(pago.prestamoId);
          final cliente = prestamo == null
              ? null
              : cartera.clientePorId(prestamo.clienteId);

          return ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: Text(cliente?.nombre ?? 'Cliente'),
            subtitle: Text(fechaCorta(pago.fecha)),
            trailing: Text(
              formatearMonto(pago.monto, prestamo?.moneda ?? monedaBoliviano),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Cuanto entro hoy. Cierra el ciclo del dia: el prestamista sale a cobrar,
// vuelve, y ve de una si le fue bien sin tener que sumar los recibos.
class _CierreDelDia extends StatelessWidget {
  const _CierreDelDia();

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cuantos = cartera.cantidadCobradaHoy();

    final conCobros = cartera.monedasEnUso
        .where((m) => cartera.cobradoHoy(m) > 0)
        .toList();

    return Card(
      color: const Color(0xFFE6F4EA),
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: Espaciado.xs,
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 18, color: Color(0xFF1B6B2F)),
                Text(
                  'Cobrado hoy',
                  style: textos.labelLarge?.copyWith(
                    color: const Color(0xFF1B6B2F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Espaciado.s),
            for (final moneda in conCobros)
              Text(
                formatearMonto(cartera.cobradoHoy(moneda), moneda),
                style: textos.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B6B2F),
                ),
              ),
            const SizedBox(height: Espaciado.xs),
            Text(
              cuantos == 1 ? 'en 1 cobro' : 'en $cuantos cobros',
              style: textos.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
