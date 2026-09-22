import 'package:flutter/material.dart';

import '../../estado/cartera.dart';
import '../../logica/fechas.dart';
import '../../modelos/cliente.dart';
import '../../modelos/prestamo.dart';
import '../../ui/avisos.dart';
import '../../ui/breakpoints.dart';
import '../../ui/confirmar.dart';
import '../../ui/espaciado.dart';
import '../../ui/formato.dart';
import '../../ui/vista_cartera.dart';
import '../prestamos/detalle_prestamo_screen.dart';
import 'nuevo_cliente_screen.dart';

// La billetera del cliente: lo que debe y todos sus prestamos.
class DetalleClienteScreen extends StatelessWidget {
  const DetalleClienteScreen({super.key, required this.cliente});

  final Cliente cliente;

  Future<void> _borrar(BuildContext context) async {
    final cuantos = cartera.prestamosQuePerderia(cliente.id);

    final confirmado = await confirmarBorrado(
      context,
      titulo: '¿Borrar a ${cliente.nombre}?',
      mensaje: 'Se va a borrar esta persona de tu lista de clientes.',
      advertencia: cuantos > 0
          ? 'Ojo: también se borran sus $cuantos préstamo'
              '${cuantos == 1 ? '' : 's'} con todas las cuotas y los cobros '
              'que ya registraste. No se puede recuperar.'
          : null,
      textoBoton: 'Sí, borrar',
    );

    if (!confirmado || !context.mounted) return;

    try {
      await cartera.borrarCliente(cliente.id);
      if (!context.mounted) return;
      mostrarAviso(context, '${cliente.nombre} fue borrado');
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      mostrarAviso(
        context,
        'No se pudo borrar. Revisá tu conexión',
        nivel: NivelAviso.bloqueo,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cliente.nombre),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            onSelected: (opcion) {
              if (opcion == 'borrar') _borrar(context);
              if (opcion == 'editar') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        NuevoClienteScreen(clienteAEditar: cliente),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'editar',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar datos'),
                ),
              ),
              PopupMenuItem(
                value: 'borrar',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline, color: Color(0xFFB3261E)),
                  title: Text('Borrar cliente'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: VistaCartera(
        builder: (context) {
          final prestamos = cartera.prestamosDe(cliente.id);

          return ContenidoCentrado(
            child: ListView(
              padding: const EdgeInsets.all(Espaciado.m),
              children: [
                _Ficha(cliente: cliente),
                const SizedBox(height: Espaciado.l),

                Text(
                  'Préstamos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Espaciado.s),

                if (prestamos.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(Espaciado.m),
                      child: Text('Todavía no le prestaste nada'),
                    ),
                  )
                else
                  for (final prestamo in prestamos) ...[
                    _TarjetaPrestamo(prestamo: prestamo),
                    const SizedBox(height: Espaciado.s),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Ficha extends StatelessWidget {
  const _Ficha({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Espaciado.s,
          children: [
            Row(
              spacing: Espaciado.s,
              children: [
                const Icon(Icons.phone_outlined, size: 20),
                Text(
                  cliente.telefono.isEmpty ? 'Sin teléfono' : cliente.telefono,
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Espaciado.s,
              children: [
                const Icon(Icons.place_outlined, size: 20),
                Expanded(
                  child: Text(
                    cliente.direccion.isEmpty
                        ? 'Sin dirección'
                        : cliente.direccion,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaPrestamo extends StatelessWidget {
  const _TarjetaPrestamo({required this.prestamo});

  final Prestamo prestamo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cuotas = cartera.cuotasDe(prestamo.id);

    var saldo = 0.0;
    var pagadas = 0;
    for (final cuota in cuotas) {
      saldo += cuota.saldo;
      if (cuota.pagada) pagadas++;
    }

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetallePrestamoScreen(prestamoId: prestamo.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Espaciado.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Le prestaste '
                      '${formatearMonto(prestamo.capital, prestamo.moneda)}',
                      style: textos.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: Espaciado.xs),
              Text(
                '${nombreFrecuencia(prestamo.frecuencia)} · '
                'desde ${fechaCorta(prestamo.fechaInicio)}',
                style: textos.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: Espaciado.s),
              Text(
                saldo <= 0
                    ? 'Préstamo terminado'
                    : 'Debe ${formatearMonto(saldo, prestamo.moneda)}',
                style: textos.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Espaciado.xs),
              Text(
                '$pagadas de ${cuotas.length} cuotas pagadas',
                style: textos.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
