import 'package:flutter/material.dart';

import '../../ui/espaciado.dart';
import 'prestamos_screen.dart';

class _CuotaEjemplo {
  const _CuotaEjemplo(this.numero, this.fecha, this.monto, this.estado);
  final int numero;
  final String fecha;
  final String monto;
  final String estado;
}

const _cuotasEjemplo = [
  _CuotaEjemplo(1, '20/09/2026', 'Bs 350', 'Pagada'),
  _CuotaEjemplo(2, '20/10/2026', 'Bs 350', 'Pagada'),
  _CuotaEjemplo(3, '20/11/2026', 'Bs 350', 'Por vencer'),
  _CuotaEjemplo(4, '20/12/2026', 'Bs 350', 'Pendiente'),
  _CuotaEjemplo(5, '20/01/2027', 'Bs 350', 'Pendiente'),
  _CuotaEjemplo(6, '20/02/2027', 'Bs 350', 'Pendiente'),
];

class DetallePrestamoScreen extends StatelessWidget {
  const DetallePrestamoScreen({super.key, required this.prestamo});

  final PrestamoEjemplo prestamo;

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pagada':
        return Colors.green;
      case 'Por vencer':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _registrarPago(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registrar pago'),
        content: const Text('Se registrará el cobro de la cuota 3 por Bs 380.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago registrado (demo)')),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del préstamo')),
      body: ListView(
        padding: const EdgeInsets.all(Espaciado.m),
        children: [
          Text(prestamo.cliente, style: textos.headlineSmall),
          const SizedBox(height: Espaciado.xs),
          Text(
            '${prestamo.plantilla} · ${prestamo.monto}',
            style: textos.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),

          const SizedBox(height: Espaciado.l),

          Card(
            color: colores.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(Espaciado.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('A cobrar hoy', style: textos.labelLarge),
                  const SizedBox(height: Espaciado.s),
                  Text(
                    'Bs 380',
                    style: textos.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: Espaciado.s),
                  Text(
                    'Cuota 3 de 6 · vence 20/11/2026\nBs 350 cuota + Bs 30 mora',
                    style: textos.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: Espaciado.m),

          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: () => _registrarPago(context),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Registrar pago'),
            ),
          ),

          const SizedBox(height: Espaciado.xl),

          Text('Plan de cuotas', style: textos.titleMedium),
          const SizedBox(height: Espaciado.s),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: _cuotasEjemplo.map((cuota) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Espaciado.m,
                    vertical: Espaciado.xs,
                  ),
                  leading: CircleAvatar(child: Text('${cuota.numero}')),
                  title: Text(cuota.fecha),
                  subtitle: Text(cuota.monto),
                  trailing: Chip(
                    label: Text(cuota.estado),
                    backgroundColor:
                        _colorEstado(cuota.estado).withValues(alpha: 0.15),
                    labelStyle: TextStyle(color: _colorEstado(cuota.estado)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
