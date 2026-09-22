import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../estado/cartera.dart';
import '../../logica/fechas.dart';
import '../../logica/identificadores.dart';
import '../../logica/mensaje_cobro.dart';
import '../../logica/mora.dart';
import '../../modelos/cuota.dart';
import '../../modelos/prestamo.dart';
import '../../ui/avisos.dart';
import '../../ui/breakpoints.dart';
import '../../ui/confirmar.dart';
import '../../ui/espaciado.dart';
import '../../ui/formato.dart';
import '../../ui/tema.dart';
import '../../ui/vista_cartera.dart';
import 'registro_pago_dialog.dart';

// Detalle de un prestamo. Lo primero que se ve es cuanto hay que cobrar hoy,
// porque es el dato que el prestamista necesita decir en voz alta frente al
// cliente. El plan de cuotas queda mas abajo: es consulta, no lo urgente.
class DetallePrestamoScreen extends StatelessWidget {
  const DetallePrestamoScreen({super.key, required this.prestamoId});

  final String prestamoId;

  Future<void> _registrarPago(
    BuildContext context,
    Prestamo prestamo,
    Cuota cuota,
  ) async {
    final hoy = DateTime.now();
    final aCobrar = montoACobrar(cuota, prestamo, hoy);

    final monto = await showDialog<double>(
      context: context,
      builder: (_) => RegistroPagoDialog(
        montoACobrar: aCobrar,
        saldoCuota: cuota.saldo,
        mora: calcularMora(cuota, prestamo.moraPorDia, hoy),
        moneda: prestamo.moneda,
        detalleCuota: 'Cuota ${cuota.numero} · vence ${fechaCorta(cuota.vence)}',
        desglose: desgloseDelCobro(cuota, prestamo, hoy),
      ),
    );

    if (monto == null || !context.mounted) return;

    try {
      await cartera.registrarPago(cuota, monto, nuevoId('pag'));
      if (!context.mounted) return;

      final quedaDebiendo = cuota.saldo - monto;
      mostrarAviso(
        context,
        quedaDebiendo > 0
            ? 'Cobraste ${formatearMonto(monto, prestamo.moneda)} · queda '
                '${formatearMonto(quedaDebiendo, prestamo.moneda)}'
            : 'Cuota ${cuota.numero} pagada',
      );
    } catch (e) {
      if (!context.mounted) return;
      mostrarAviso(
        context,
        'No se pudo guardar el pago. Revisá tu conexión',
        nivel: NivelAviso.bloqueo,
      );
    }
  }

  // Cambiar cuanto se cobra por cada dia de atraso.
  //
  // Es lo unico editable del prestamo: el monto, el plazo y las cuotas no se
  // tocan porque ya hay pagos registrados contra ese plan. El recargo si,
  // porque es una decision que el prestamista revisa caso a caso.
  Future<void> _cambiarMora(BuildContext context) async {
    final prestamo = cartera.prestamoPorId(prestamoId);
    if (prestamo == null) return;

    final controlador = TextEditingController(
      text: prestamo.moraPorDia > 0
          ? prestamo.moraPorDia.toStringAsFixed(0)
          : '',
    );

    final nueva = await showDialog<double>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Recargo por atraso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Cuánto le cobrás por cada día que se atrasa?'),
            const SizedBox(height: Espaciado.m),
            TextField(
              controller: controlador,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Por día',
                prefixText: '${simboloMoneda(prestamo.moneda)} ',
              ),
            ),
            const SizedBox(height: Espaciado.m),
            const Aviso('Dejalo vacío o en cero si no querés cobrar mora.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final valor = double.tryParse(
                    controlador.text.trim().replaceAll(',', '.'),
                  ) ??
                  0;
              Navigator.pop(contexto, valor < 0 ? 0 : valor);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (nueva == null || !context.mounted) return;

    try {
      await cartera.actualizarMora(prestamoId, nueva);
      if (!context.mounted) return;
      mostrarAviso(
        context,
        nueva > 0
            ? 'Ahora cobra ${formatearMonto(nueva, prestamo.moneda)} por día '
                'de atraso'
            : 'Este préstamo ya no cobra mora',
      );
    } catch (e) {
      if (!context.mounted) return;
      mostrarAviso(
        context,
        'No se pudo guardar. Revisá tu conexión',
        nivel: NivelAviso.bloqueo,
      );
    }
  }

  Future<void> _borrar(BuildContext context) async {
    final prestamo = cartera.prestamoPorId(prestamoId);
    if (prestamo == null) return;

    final cliente = cartera.clientePorId(prestamo.clienteId);
    final pagados = cartera.cuotasDe(prestamoId).where((c) => c.pagada).length;

    final confirmado = await confirmarBorrado(
      context,
      titulo: '¿Borrar este préstamo?',
      mensaje: 'Se va a borrar el préstamo de '
          '${cliente?.nombre ?? 'este cliente'} por '
          '${formatearMonto(prestamo.capital, prestamo.moneda)}, con todas '
          'sus cuotas.',
      advertencia: pagados > 0
          ? 'Ojo: ya tiene $pagados cuota${pagados == 1 ? '' : 's'} pagada'
              '${pagados == 1 ? '' : 's'}. Ese historial de cobros también se '
              'borra y no se puede recuperar.'
          : null,
      textoBoton: 'Sí, borrar',
    );

    if (!confirmado || !context.mounted) return;

    try {
      await cartera.borrarPrestamo(prestamoId);
      if (!context.mounted) return;
      mostrarAviso(context, 'Préstamo borrado');
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
        title: const Text('Detalle del préstamo'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            onSelected: (opcion) {
              if (opcion == 'borrar') _borrar(context);
              if (opcion == 'mora') _cambiarMora(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'mora',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.tune),
                  title: Text('Cambiar recargo por atraso'),
                ),
              ),
              PopupMenuItem(
                value: 'borrar',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline, color: Color(0xFFB3261E)),
                  title: Text('Borrar préstamo'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: VistaCartera(
        builder: (context) {
          final prestamo = cartera.prestamoPorId(prestamoId);
          if (prestamo == null) {
            return const SinDatos(
              icono: Icons.search_off,
              titulo: 'Este préstamo ya no existe',
              explicacion: 'Puede que lo hayas borrado desde otro dispositivo.',
            );
          }

          final cliente = cartera.clientePorId(prestamo.clienteId);
          final cuotas = cartera.cuotasDe(prestamo.id);
          final proxima = cartera.proximaCuotaDe(prestamo.id);
          final hoy = DateTime.now();

          return ContenidoCentrado(
            child: ListView(
              padding: const EdgeInsets.all(Espaciado.m),
              children: [
                Text(
                  cliente?.nombre ?? 'Cliente',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: Espaciado.xs),
                Text(
                  'Le prestaste '
                  '${formatearMonto(prestamo.capital, prestamo.moneda)} · '
                  'te devuelve '
                  '${formatearMonto(prestamo.totalADevolver, prestamo.moneda)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[700]),
                ),

                const SizedBox(height: Espaciado.l),

                if (proxima == null)
                  _TarjetaTerminado(prestamo: prestamo)
                else ...[
                  _TarjetaACobrar(
                    prestamo: prestamo,
                    cuota: proxima,
                    hoy: hoy,
                  ),
                  const SizedBox(height: Espaciado.m),
                  FilledButton.icon(
                    onPressed: () =>
                        _registrarPago(context, prestamo, proxima),
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(
                      proxima.abonado > 0
                          ? 'Registrar otro abono'
                          : 'Registrar pago',
                    ),
                  ),
                  const SizedBox(height: Espaciado.s),
                  _BotonRecordatorio(prestamoId: prestamo.id),
                ],

                const SizedBox(height: Espaciado.xl),

                Text(
                  'Plan de cuotas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Espaciado.s),
                _PlanDeCuotas(
                  cuotas: cuotas,
                  moneda: prestamo.moneda,
                  hoy: hoy,
                ),

                const SizedBox(height: Espaciado.xl),

                Text(
                  'Resumen de pagos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Espaciado.s),
                _HistorialDePagos(prestamo: prestamo),

                const SizedBox(height: Espaciado.l),
              ],
            ),
          );
        },
      ),
    );
  }
}

// El monto del dia, en grande. Es lo unico que se mira antes de cobrar.
class _TarjetaACobrar extends StatelessWidget {
  const _TarjetaACobrar({
    required this.prestamo,
    required this.cuota,
    required this.hoy,
  });

  final Prestamo prestamo;
  final Cuota cuota;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final estado = cuota.estado(hoy);
    final color = colorDeEstado(estado);
    final aCobrar = montoACobrar(cuota, prestamo, hoy);

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: Espaciado.xs,
              children: [
                Icon(iconoDeEstado(estado), size: 18, color: color),
                Text(
                  nombreEstado(estado),
                  style: textos.labelLarge?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: Espaciado.s),
            Text(
              formatearMonto(aCobrar, prestamo.moneda),
              style: textos.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Espaciado.s),
            Text(
              'Cuota ${cuota.numero} de ${prestamo.cantidadCuotas} · vence '
              '${fechaCorta(cuota.vence)}',
              style: textos.bodyMedium,
            ),
            const SizedBox(height: Espaciado.xs),
            Text(
              desgloseDelCobro(cuota, prestamo, hoy),
              style: textos.bodyMedium,
            ),

            // Si ya entrego una parte queda escrito, para que no parezca que
            // el monto cambio solo.
            if (cuota.abonado > 0) ...[
              const SizedBox(height: Espaciado.s),
              Text(
                'Ya abonó ${formatearMonto(cuota.abonado, prestamo.moneda)} '
                'de ${formatearMonto(cuota.monto, prestamo.moneda)}',
                style: textos.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TarjetaTerminado extends StatelessWidget {
  const _TarjetaTerminado({required this.prestamo});

  final Prestamo prestamo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Card(
      color: const Color(0xFFE6F4EA),
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Espaciado.s,
          children: [
            const Row(
              spacing: Espaciado.xs,
              children: [
                Icon(Icons.check_circle_outline,
                    color: Color(0xFF1B6B2F), size: 20),
                Text(
                  'Préstamo terminado',
                  style: TextStyle(
                    color: Color(0xFF1B6B2F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'Te devolvió los '
              '${formatearMonto(prestamo.totalADevolver, prestamo.moneda)} '
              'completos. Ganaste '
              '${formatearMonto(prestamo.ganancia, prestamo.moneda)}.',
              style: textos.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanDeCuotas extends StatelessWidget {
  const _PlanDeCuotas({
    required this.cuotas,
    required this.moneda,
    required this.hoy,
  });

  final List<Cuota> cuotas;
  final String moneda;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: cuotas.map((cuota) {
          final estado = cuota.estado(hoy);
          final color = colorDeEstado(estado);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Espaciado.m,
              vertical: Espaciado.xs,
            ),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                '${cuota.numero}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(fechaCorta(cuota.vence)),
            subtitle: Text(
              cuota.abonado > 0 && !cuota.pagada
                  ? '${formatearMonto(cuota.monto, moneda)} · abonó '
                      '${formatearMonto(cuota.abonado, moneda)}'
                  : formatearMonto(cuota.monto, moneda),
            ),
            // El estado se dice con icono y con texto, no solo con color.
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Espaciado.xs,
              children: [
                Icon(iconoDeEstado(estado), size: 18, color: color),
                Text(
                  nombreEstado(estado),
                  style: TextStyle(color: color, fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Todo lo que el cliente fue entregando, de lo mas nuevo a lo mas viejo.
// Responde a lo que le paso al prestamista con el cuaderno: cobro de mas, el
// cliente reclamo y no tenia con que demostrar cuanto habia recibido.
class _HistorialDePagos extends StatelessWidget {
  const _HistorialDePagos({required this.prestamo});

  final Prestamo prestamo;

  @override
  Widget build(BuildContext context) {
    final pagos = cartera.pagosDe(prestamo.id);

    if (pagos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(Espaciado.m),
          child: Text('Todavía no te entregó nada de este préstamo'),
        ),
      );
    }

    var total = 0.0;
    for (final pago in pagos) {
      total += pago.monto;
    }

    return Card(
      child: Column(
        children: [
          for (final pago in pagos)
            ListTile(
              dense: true,
              leading: const Icon(Icons.receipt_long_outlined, size: 20),
              title: Text(fechaCorta(pago.fecha)),
              trailing: Text(
                formatearMonto(pago.monto, prestamo.moneda),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          const Divider(height: 1),
          ListTile(
            title: const Text(
              'Total entregado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              formatearMonto(total, prestamo.moneda),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Abre el chat de WhatsApp del cliente con el recordatorio ya escrito.
//
// El prestamista solo revisa el texto y le da enviar. Antes de que existiera
// este boton tenia que buscar el contacto, acordarse de cuanto debia y
// escribirlo a mano, que es justo cuando se cometen los errores de monto.
class _BotonRecordatorio extends StatelessWidget {
  const _BotonRecordatorio({required this.prestamoId});

  final String prestamoId;

  Future<void> _abrir(BuildContext context) async {
    final cobro = cartera.cobroDe(prestamoId);
    if (cobro == null) return;

    final enlace = enlaceWhatsapp(cobro);
    if (enlace == null) {
      mostrarAviso(
        context,
        '${cobro.cliente.nombre} no tiene teléfono cargado',
        nivel: NivelAviso.advertencia,
      );
      return;
    }

    final abrio = await launchUrl(
      Uri.parse(enlace),
      mode: LaunchMode.externalApplication,
    );
    if (!abrio && context.mounted) {
      mostrarAviso(
        context,
        'No se pudo abrir WhatsApp en este dispositivo',
        nivel: NivelAviso.bloqueo,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cobro = cartera.cobroDe(prestamoId);
    final tieneTelefono =
        cobro != null && cobro.cliente.telefono.trim().isNotEmpty;

    return OutlinedButton.icon(
      onPressed: tieneTelefono ? () => _abrir(context) : null,
      icon: const Icon(Icons.chat_outlined),
      label: Text(
        tieneTelefono
            ? 'Mandarle el recordatorio'
            : 'Sin teléfono para avisarle',
      ),
    );
  }
}
