import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../datos/configuracion.dart';
import '../../estado/cartera.dart';
import '../../logica/fechas.dart';
import '../../logica/identificadores.dart';
import '../../logica/plan_cuotas.dart';
import '../../modelos/cliente.dart';
import '../../modelos/prestamo.dart';
import '../../ui/avisos.dart';
import '../../ui/breakpoints.dart';
import '../../ui/espaciado.dart';
import '../../ui/formato.dart';
import '../clientes/nuevo_cliente_screen.dart';

// Como se define lo que gana el prestamista. Son dos maneras de decir lo
// mismo, pero cada uno piensa a su manera: unos dicen "le cobro 20%" y otros
// "le presto 1.000 y me devuelve 1.200".
enum ModoInteres { porcentaje, montoFinal }

class NuevoPrestamoScreen extends StatefulWidget {
  const NuevoPrestamoScreen({super.key});

  @override
  State<NuevoPrestamoScreen> createState() => _NuevoPrestamoScreenState();
}

class _NuevoPrestamoScreenState extends State<NuevoPrestamoScreen> {
  String? _clienteId;
  String _moneda = Configuracion.monedaPorDefecto;
  ModoInteres _modo = ModoInteres.porcentaje;
  Frecuencia _frecuencia = Frecuencia.mensual;
  DateTime _fechaInicio = DateTime.now().add(const Duration(days: 1));

  final _capitalCtrl = TextEditingController();
  final _interesCtrl = TextEditingController();
  final _cuotasCtrl = TextEditingController(text: '6');
  final _moraCtrl = TextEditingController();

  bool _guardando = false;
  String _error = '';

  @override
  void dispose() {
    _capitalCtrl.dispose();
    _interesCtrl.dispose();
    _cuotasCtrl.dispose();
    _moraCtrl.dispose();
    super.dispose();
  }

  // --- Cuentas que se rehacen mientras el prestamista escribe --------------

  double _numero(TextEditingController ctrl) {
    return double.tryParse(ctrl.text.trim().replaceAll(',', '.')) ?? 0;
  }

  double get _capital => _numero(_capitalCtrl);
  int get _cantidadCuotas => int.tryParse(_cuotasCtrl.text.trim()) ?? 0;
  double get _moraPorDia => _numero(_moraCtrl);

  // Lo que el cliente termina devolviendo, salga del porcentaje o del monto.
  double get _totalADevolver {
    if (_modo == ModoInteres.montoFinal) return _numero(_interesCtrl);
    return _capital + (_capital * _numero(_interesCtrl) / 100);
  }

  double get _ganancia => _totalADevolver - _capital;
  double get _cuota => cuotaEstimada(_totalADevolver, _cantidadCuotas);

  bool get _puedeGuardar {
    return _clienteId != null &&
        _capital > 0 &&
        _totalADevolver > 0 &&
        _cantidadCuotas > 0;
  }

  // --- Avisos --------------------------------------------------------------

  String get _avisoGanancia {
    if (_capital <= 0 || _totalADevolver <= 0) return '';
    if (_ganancia < 0) {
      return 'Ojo: te devuelve menos de lo que prestaste. Estás perdiendo '
          '${formatearMonto(-_ganancia, _moneda)}.';
    }
    if (_ganancia == 0) return 'Con estos números no estás ganando nada.';
    return '';
  }

  String get _avisoFecha {
    final dias = diasEntre(DateTime.now(), _fechaInicio);
    if (dias < 0) {
      return 'La primera cuota vence en una fecha que ya pasó. Si es a '
          'propósito está bien, va a aparecer como vencida.';
    }
    return '';
  }

  String get _avisoCliente {
    if (_clienteId == null) return '';
    final activos = cartera
        .prestamosDe(_clienteId!)
        .where((p) => cartera.proximaCuotaDe(p.id) != null)
        .length;
    if (activos == 0) return '';
    return activos == 1
        ? 'Esta persona ya tiene 1 préstamo sin terminar de pagar.'
        : 'Esta persona ya tiene $activos préstamos sin terminar de pagar.';
  }

  // --- Acciones ------------------------------------------------------------

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: '¿Cuándo paga la primera cuota?',
    );
    if (elegida != null) setState(() => _fechaInicio = elegida);
  }

  Future<void> _nuevoCliente() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NuevoClienteScreen()),
    );
    if (!mounted) return;
    // Si se acaba de crear uno, queda elegido para no hacerlo buscar.
    if (cartera.clientes.isNotEmpty) {
      setState(() => _clienteId = cartera.clientes.last.id);
    }
  }

  Future<void> _guardar() async {
    setState(() {
      _guardando = true;
      _error = '';
    });

    try {
      await cartera.crearPrestamo(
        Prestamo(
          id: nuevoId('pre'),
          clienteId: _clienteId!,
          capital: _capital,
          totalADevolver: _totalADevolver,
          moneda: _moneda,
          frecuencia: _frecuencia,
          cantidadCuotas: _cantidadCuotas,
          fechaInicio: _fechaInicio,
          moraPorDia: _moraPorDia,
        ),
      );
      if (!mounted) return;

      mostrarAviso(context, 'Préstamo registrado con $_cantidadCuotas cuotas');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = 'No se pudo guardar. Revisá tu conexión e intentá de nuevo';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo préstamo')),
      body: ContenidoCentrado(
        anchoMaximo: 520,
        child: ListView(
          padding: const EdgeInsets.all(Espaciado.m),
          children: [
            // --- 1. A quien ---------------------------------------------
            Text('¿A quién le prestás?', style: textos.titleMedium),
            const SizedBox(height: Espaciado.s),
            if (cartera.clientes.isEmpty)
              const Aviso(
                'Todavía no tenés clientes. Agregá uno para poder seguir.',
                nivel: NivelAviso.advertencia,
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _clienteId,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Elegí un cliente',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: cartera.clientes.map((Cliente cliente) {
                  return DropdownMenuItem(
                    value: cliente.id,
                    child: Text(cliente.nombre),
                  );
                }).toList(),
                onChanged: (valor) => setState(() => _clienteId = valor),
              ),
            const SizedBox(height: Espaciado.s),
            TextButton.icon(
              onPressed: _nuevoCliente,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Es un cliente nuevo'),
            ),
            if (_avisoCliente.isNotEmpty) ...[
              const SizedBox(height: Espaciado.s),
              Aviso(_avisoCliente, nivel: NivelAviso.advertencia),
            ],

            const SizedBox(height: Espaciado.l),

            // --- 2. Cuanto ----------------------------------------------
            Text('¿Cuánto le prestás?', style: textos.titleMedium),
            const SizedBox(height: Espaciado.s),
            Row(
              spacing: Espaciado.s,
              children: [
                for (final moneda in monedasDisponibles)
                  ChoiceChip(
                    label: Text(nombreMoneda(moneda)),
                    selected: _moneda == moneda,
                    onSelected: (_) => setState(() => _moneda = moneda),
                  ),
              ],
            ),
            const SizedBox(height: Espaciado.s),
            _CampoNumero(
              controller: _capitalCtrl,
              etiqueta: 'Monto que le entregás',
              prefijo: simboloMoneda(_moneda),
              onCambio: () => setState(() {}),
            ),

            const SizedBox(height: Espaciado.l),

            // --- 3. Cuanto gana -----------------------------------------
            Text('¿Cuánto te devuelve?', style: textos.titleMedium),
            const SizedBox(height: Espaciado.s),
            Row(
              spacing: Espaciado.s,
              children: [
                ChoiceChip(
                  label: const Text('Un porcentaje'),
                  selected: _modo == ModoInteres.porcentaje,
                  onSelected: (_) => setState(() {
                    _modo = ModoInteres.porcentaje;
                    _interesCtrl.clear();
                  }),
                ),
                ChoiceChip(
                  label: const Text('Un monto fijo'),
                  selected: _modo == ModoInteres.montoFinal,
                  onSelected: (_) => setState(() {
                    _modo = ModoInteres.montoFinal;
                    _interesCtrl.clear();
                  }),
                ),
              ],
            ),
            const SizedBox(height: Espaciado.s),
            _CampoNumero(
              controller: _interesCtrl,
              etiqueta: _modo == ModoInteres.porcentaje
                  ? 'Interés que le cobrás'
                  : 'Total que te devuelve',
              prefijo: _modo == ModoInteres.porcentaje
                  ? null
                  : simboloMoneda(_moneda),
              sufijo: _modo == ModoInteres.porcentaje ? '%' : null,
              onCambio: () => setState(() {}),
            ),
            if (_avisoGanancia.isNotEmpty) ...[
              const SizedBox(height: Espaciado.s),
              Aviso(_avisoGanancia, nivel: NivelAviso.advertencia),
            ],

            const SizedBox(height: Espaciado.l),

            // --- 4. Como paga -------------------------------------------
            Text('¿Cada cuánto te paga?', style: textos.titleMedium),
            const SizedBox(height: Espaciado.s),
            Wrap(
              spacing: Espaciado.s,
              children: Frecuencia.values.map((f) {
                return ChoiceChip(
                  label: Text(nombreFrecuencia(f)),
                  selected: _frecuencia == f,
                  onSelected: (_) => setState(() => _frecuencia = f),
                );
              }).toList(),
            ),
            const SizedBox(height: Espaciado.m),
            _CampoNumero(
              controller: _cuotasCtrl,
              etiqueta: 'En cuántas cuotas',
              soloEnteros: true,
              onCambio: () => setState(() {}),
            ),
            const SizedBox(height: Espaciado.m),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Primera cuota'),
              subtitle: Text(fechaCorta(_fechaInicio)),
              trailing: TextButton(
                onPressed: _elegirFecha,
                child: const Text('Cambiar'),
              ),
            ),
            if (_avisoFecha.isNotEmpty) ...[
              const SizedBox(height: Espaciado.s),
              Aviso(_avisoFecha, nivel: NivelAviso.advertencia),
            ],

            const SizedBox(height: Espaciado.l),

            // --- 5. Mora (opcional) -------------------------------------
            Text('¿Cobrás algo por atraso?', style: textos.titleMedium),
            const SizedBox(height: Espaciado.xs),
            Text(
              'Opcional. Si lo dejás vacío, no se cobra mora.',
              style: textos.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: Espaciado.s),
            _CampoNumero(
              controller: _moraCtrl,
              etiqueta: 'Por cada día de atraso',
              prefijo: simboloMoneda(_moneda),
              onCambio: () => setState(() {}),
            ),

            const SizedBox(height: Espaciado.xl),

            // --- 6. Resumen ---------------------------------------------
            _Resumen(
              clienteId: _clienteId,
              capital: _capital,
              total: _totalADevolver,
              ganancia: _ganancia,
              cuota: _cuota,
              cantidadCuotas: _cantidadCuotas,
              frecuencia: _frecuencia,
              fechaInicio: _fechaInicio,
              moneda: _moneda,
              completo: _puedeGuardar,
            ),

            if (_error.isNotEmpty) ...[
              const SizedBox(height: Espaciado.m),
              Aviso(_error, nivel: NivelAviso.bloqueo),
            ],

            const SizedBox(height: Espaciado.m),

            FilledButton(
              onPressed: _puedeGuardar && !_guardando ? _guardar : null,
              child: _guardando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar préstamo'),
            ),
            const SizedBox(height: Espaciado.l),
          ],
        ),
      ),
    );
  }
}

// Campo numerico con el teclado de numeros y el simbolo de la moneda puesto.
class _CampoNumero extends StatelessWidget {
  const _CampoNumero({
    required this.controller,
    required this.etiqueta,
    required this.onCambio,
    this.prefijo,
    this.sufijo,
    this.soloEnteros = false,
  });

  final TextEditingController controller;
  final String etiqueta;
  final VoidCallback onCambio;
  final String? prefijo;
  final String? sufijo;
  final bool soloEnteros;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !soloEnteros),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          soloEnteros ? RegExp(r'[0-9]') : RegExp(r'[0-9.,]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixText: prefijo == null ? null : '$prefijo ',
        suffixText: sufijo,
      ),
      onChanged: (_) => onCambio(),
    );
  }
}

// El trato explicado en una frase, como se lo diria al cliente. Se actualiza
// con cada tecla, asi el prestamista ve el efecto antes de guardar nada.
class _Resumen extends StatelessWidget {
  const _Resumen({
    required this.clienteId,
    required this.capital,
    required this.total,
    required this.ganancia,
    required this.cuota,
    required this.cantidadCuotas,
    required this.frecuencia,
    required this.fechaInicio,
    required this.moneda,
    required this.completo,
  });

  final String? clienteId;
  final double capital;
  final double total;
  final double ganancia;
  final double cuota;
  final int cantidadCuotas;
  final Frecuencia frecuencia;
  final DateTime fechaInicio;
  final String moneda;
  final bool completo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    if (!completo) {
      return const Aviso(
        'Completá el cliente, el monto y las cuotas para ver cómo queda el '
        'trato.',
      );
    }

    final cliente = cartera.clientePorId(clienteId!);
    final nombre = cliente?.nombre.split(' ').first ?? 'Tu cliente';

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Así queda el trato', style: textos.labelLarge),
            const SizedBox(height: Espaciado.s),
            Text(
              formatearMonto(cuota, moneda),
              style: textos.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${cadaCuanto(frecuencia)}, $cantidadCuotas veces',
              style: textos.bodyMedium,
            ),
            const SizedBox(height: Espaciado.m),
            Text(
              '$nombre empieza a pagar el ${fechaCorta(fechaInicio)}. '
              'Le entregás ${formatearMonto(capital, moneda)} y te devuelve '
              '${formatearMonto(total, moneda)} en total.',
              style: textos.bodyMedium?.copyWith(height: 1.4),
            ),
            if (ganancia > 0) ...[
              const SizedBox(height: Espaciado.s),
              Text(
                'Ganás ${formatearMonto(ganancia, moneda)}.',
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
