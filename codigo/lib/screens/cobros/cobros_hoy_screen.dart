import 'package:flutter/material.dart';

import '../../estado/cartera.dart';
import '../../logica/fechas.dart';
import '../../modelos/cuota.dart';
import '../../ui/breakpoints.dart';
import '../../ui/espaciado.dart';
import '../../ui/formato.dart';
import '../../ui/tema.dart';
import '../../ui/vista_cartera.dart';
import '../prestamos/detalle_prestamo_screen.dart';

// La agenda del dia: las cuotas ordenadas por vencimiento, de la mas atrasada
// a la que todavia no vence. Es el orden en que se cobra en la calle, distinto
// del listado de Prestamos que va por cliente.
class CobrosHoyScreen extends StatelessWidget {
  const CobrosHoyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cobros de hoy')),
      body: VistaCartera(
        builder: (context) {
          final hoy = DateTime.now();
          final cobros = cartera.cobrosDelDia(hoy: hoy);

          if (cobros.isEmpty) {
            return const SinDatos(
              icono: Icons.beach_access_outlined,
              titulo: 'No tenés nada que cobrar',
              explicacion: 'Todas tus cuotas están al día.',
            );
          }

          final monedas = cartera.monedasEnUso
              .where((m) => cartera.exigibleHoy(m, hoy: hoy) > 0)
              .toList();

          return ContenidoCentrado(
            child: RefreshIndicator(
              onRefresh: cartera.cargarTodo,
              child: ListView(
                padding: const EdgeInsets.all(Espaciado.m),
                children: [
                  _TotalExigible(monedas: monedas, hoy: hoy),

                  const SizedBox(height: Espaciado.xl),

                  Text(
                    'Cuotas por vencimiento',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Espaciado.s),

                  Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < cobros.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          _FilaCobro(cobro: cobros[i], hoy: hoy),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: Espaciado.l),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TotalExigible extends StatelessWidget {
  const _TotalExigible({required this.monedas, required this.hoy});

  final List<String> monedas;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cantidad = cartera.cantidadExigibleHoy(hoy: hoy);

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ya podés cobrar', style: textos.labelLarge),
            const SizedBox(height: Espaciado.s),
            if (monedas.isEmpty)
              Text(
                'Nada vencido todavía',
                style: textos.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              )
            else
              for (final moneda in monedas)
                Text(
                  formatearMonto(cartera.exigibleHoy(moneda, hoy: hoy), moneda),
                  style: textos.displaySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
            const SizedBox(height: Espaciado.s),
            Text(
              cantidad == 1
                  ? '1 cuota vencida o que vence hoy'
                  : '$cantidad cuotas vencidas o que vencen hoy',
              style: textos.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaCobro extends StatelessWidget {
  const _FilaCobro({required this.cobro, required this.hoy});

  final CobroDelDia cobro;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final estado = cobro.cuota.estado(hoy);
    final color = colorDeEstado(estado);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Espaciado.m,
        vertical: Espaciado.s,
      ),
      leading: Icon(iconoDeEstado(estado), color: color),
      title: Text(
        cobro.cliente.nombre,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      // Cuando se le juntaron varias cuotas se dice cuántas, para que el monto
      // grande no parezca un error.
      subtitle: Text(
        cobro.tieneVarias
            ? '${cobro.cantidadVencidas} cuotas · desde '
                '${fechaCorta(cobro.cuota.vence)}'
            : 'Cuota ${cobro.cuota.numero} · vence '
                '${fechaCorta(cobro.cuota.vence)}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // El monto ya trae las moras sumadas: no hay que hacer ninguna cuenta.
          Text(
            formatearMonto(
              cobro.cantidadVencidas > 0
                  ? cobro.totalExigible
                  : cobro.montoACobrar,
              cobro.moneda,
            ),
            style: textos.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            nombreEstado(estado),
            style: textos.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DetallePrestamoScreen(prestamoId: cobro.prestamo.id),
        ),
      ),
    );
  }
}
