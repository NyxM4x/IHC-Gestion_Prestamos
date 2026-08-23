import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(prestamo.cliente)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prestamo.plantilla,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Monto: ${prestamo.monto}'),
                  Text('Estado: ${prestamo.estado}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Plan de cuotas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: _cuotasEjemplo.map((cuota) {
                return ListTile(
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
