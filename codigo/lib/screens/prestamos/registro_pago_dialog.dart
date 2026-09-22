import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/avisos.dart';
import '../../ui/espaciado.dart';
import '../../ui/formato.dart';

// Dialogo para registrar el cobro. Devuelve el monto recibido, o null si se
// cancela. Abre en "Todo" con el monto ya puesto, porque es lo que pasa casi
// siempre; lo parcial es la excepcion.
class RegistroPagoDialog extends StatefulWidget {
  const RegistroPagoDialog({
    super.key,
    required this.montoACobrar,
    required this.saldoCuota,
    required this.mora,
    required this.moneda,
    required this.detalleCuota,
    required this.desglose,
  });

  final double montoACobrar; // cuota pendiente + mora
  final double saldoCuota; // solo lo que falta de la cuota, sin mora
  final double mora; // recargo acumulado por el atraso
  final String moneda;
  final String detalleCuota;
  final String desglose;

  @override
  State<RegistroPagoDialog> createState() => _RegistroPagoDialogState();
}

class _RegistroPagoDialogState extends State<RegistroPagoDialog> {
  bool _esParcial = false;
  bool _moraPerdonada = false;
  final _montoCtrl = TextEditingController();
  String _error = '';

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  // Tope de lo que se puede cobrar. Baja si se perdona el recargo.
  double get _maximo =>
      _moraPerdonada ? widget.saldoCuota : widget.montoACobrar;

  double _montoElegido() {
    if (!_esParcial) return _maximo;
    // Se acepta coma o punto: en el teclado del celular sale cualquiera.
    final escrito = _montoCtrl.text.trim().replaceAll(',', '.');
    return double.tryParse(escrito) ?? 0;
  }

  void _confirmar() {
    final monto = _montoElegido();

    if (monto <= 0) {
      setState(() => _error = 'Escribí cuánto te entregó');
      return;
    }
    if (monto > _maximo) {
      setState(() =>
          _error = 'No puede pasar de ${formatearMonto(_maximo, widget.moneda)}');
      return;
    }

    Navigator.pop(context, monto);
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final monto = _montoElegido();
    final restante = _maximo - monto;

    return AlertDialog(
      title: const Text('Registrar pago'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.detalleCuota, style: textos.bodyMedium),
            const SizedBox(height: Espaciado.xs),
            Text(
              widget.desglose,
              style: textos.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),

            // Perdonar el recargo.
            //
            // El prestamista ya lo hace en el cuaderno: cuando el atraso es de
            // un dia, o el cliente es de confianza, deja pasar la mora. Si la
            // app no lo dejara, terminaria cobrando un monto y anotando otro.
            if (widget.mora > 0) ...[
              const SizedBox(height: Espaciado.s),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                value: _moraPerdonada,
                title: Text(
                  'Perdonarle los ${formatearMonto(widget.mora, widget.moneda)} '
                  'de recargo',
                  style: textos.bodyMedium,
                ),
                onChanged: (valor) => setState(() {
                  _moraPerdonada = valor ?? false;
                  _error = '';
                }),
              ),
            ],

            const SizedBox(height: Espaciado.s),

            Wrap(
              spacing: Espaciado.s,
              children: [
                ChoiceChip(
                  label: Text('Todo (${formatearMonto(_maximo, widget.moneda)})'),
                  selected: !_esParcial,
                  onSelected: (_) => setState(() {
                    _esParcial = false;
                    _error = '';
                  }),
                ),
                ChoiceChip(
                  label: const Text('Una parte'),
                  selected: _esParcial,
                  onSelected: (_) => setState(() {
                    _esParcial = true;
                    _error = '';
                  }),
                ),
              ],
            ),

            if (_esParcial) ...[
              const SizedBox(height: Espaciado.m),
              TextField(
                controller: _montoCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Cuánto te entregó',
                  prefixText: '${simboloMoneda(widget.moneda)} ',
                ),
                onChanged: (_) => setState(() => _error = ''),
              ),
            ],

            const SizedBox(height: Espaciado.m),

            // Siempre se dice como queda la cuenta antes de guardar, para que
            // no haya sorpresas despues de confirmar.
            Aviso(
              restante > 0
                  ? 'Le queda debiendo '
                      '${formatearMonto(restante, widget.moneda)} de esta cuota'
                  : 'Con esto la cuota queda saldada',
              nivel: restante > 0 ? NivelAviso.advertencia : NivelAviso.exito,
            ),

            if (_error.isNotEmpty) ...[
              const SizedBox(height: Espaciado.s),
              Aviso(_error, nivel: NivelAviso.bloqueo),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
