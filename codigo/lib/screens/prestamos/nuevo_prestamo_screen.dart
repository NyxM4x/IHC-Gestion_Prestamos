import 'package:flutter/material.dart';

import 'prestamos_screen.dart';

class _PlantillaInfo {
  const _PlantillaInfo(this.nombre, this.descripcion);
  final String nombre;
  final String descripcion;
}

const _plantillas = [
  _PlantillaInfo(
    'Gota a Gota (Diario)',
    'Interés fijo global sumado al capital, dividido en días (20-30 días).',
  ),
  _PlantillaInfo(
    'Comercial (Semanal)',
    'Interés fijo global, cuotas semanales que amortizan capital e interés.',
  ),
  _PlantillaInfo(
    'Pago a Rédito (Mensual)',
    'El cliente paga solo el interés cada mes; el capital vuelve íntegro al final.',
  ),
  _PlantillaInfo(
    'Cuota Fija (Mensual)',
    'Interés simple anualizado; capital e interés en cuotas mensuales iguales.',
  ),
];

const _clientesDisponibles = [
  'María Gutiérrez',
  'Juan Pérez',
];

class NuevoPrestamoScreen extends StatefulWidget {
  const NuevoPrestamoScreen({super.key});

  @override
  State<NuevoPrestamoScreen> createState() => _NuevoPrestamoScreenState();
}

class _NuevoPrestamoScreenState extends State<NuevoPrestamoScreen> {
  int _paso = 0;
  String? _clienteSeleccionado;
  String? _plantillaSeleccionada;
  final _montoCtrl = TextEditingController();
  final _plazoCtrl = TextEditingController();

  @override
  void dispose() {
    _montoCtrl.dispose();
    _plazoCtrl.dispose();
    super.dispose();
  }

  bool get _puedeContinuar {
    switch (_paso) {
      case 0:
        return _clienteSeleccionado != null;
      case 1:
        return _plantillaSeleccionada != null;
      case 2:
        return _montoCtrl.text.trim().isNotEmpty &&
            _plazoCtrl.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  void _guardar() {
    Navigator.pop(
      context,
      PrestamoEjemplo(
        cliente: _clienteSeleccionado!,
        monto: 'Bs ${_montoCtrl.text.trim()}',
        plantilla: _plantillaSeleccionada!,
        estado: 'Al día',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo préstamo')),
      body: Stepper(
        currentStep: _paso,
        onStepContinue: _puedeContinuar
            ? () {
                if (_paso == 2) {
                  _guardar();
                } else {
                  setState(() => _paso++);
                }
              }
            : null,
        onStepCancel: _paso == 0 ? null : () => setState(() => _paso--),
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(_paso == 2 ? 'Guardar' : 'Continuar'),
                ),
                const SizedBox(width: 8),
                if (_paso > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Atrás'),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Cliente'),
            isActive: _paso >= 0,
            state: _clienteSeleccionado != null
                ? StepState.complete
                : StepState.indexed,
            content: RadioGroup<String>(
              groupValue: _clienteSeleccionado,
              onChanged: (v) => setState(() => _clienteSeleccionado = v),
              child: Column(
                children: _clientesDisponibles.map((cliente) {
                  return RadioListTile<String>(
                    title: Text(cliente),
                    value: cliente,
                  );
                }).toList(),
              ),
            ),
          ),
          Step(
            title: const Text('Plantilla'),
            isActive: _paso >= 1,
            state: _plantillaSeleccionada != null
                ? StepState.complete
                : StepState.indexed,
            content: RadioGroup<String>(
              groupValue: _plantillaSeleccionada,
              onChanged: (v) => setState(() => _plantillaSeleccionada = v),
              child: Column(
                children: _plantillas.map((plantilla) {
                  return RadioListTile<String>(
                    title: Text(plantilla.nombre),
                    subtitle: Text(plantilla.descripcion),
                    value: plantilla.nombre,
                  );
                }).toList(),
              ),
            ),
          ),
          Step(
            title: const Text('Monto y plazo'),
            isActive: _paso >= 2,
            content: Column(
              children: [
                TextField(
                  controller: _montoCtrl,
                  decoration: const InputDecoration(labelText: 'Monto (Bs)'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _plazoCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Plazo (número de cuotas)'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
