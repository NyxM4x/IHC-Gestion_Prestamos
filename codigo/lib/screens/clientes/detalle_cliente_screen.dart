import 'package:flutter/material.dart';

import 'clientes_screen.dart';

class DetalleClienteScreen extends StatelessWidget {
  const DetalleClienteScreen({super.key, required this.cliente});

  final ClienteEjemplo cliente;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cliente.nombre)),
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
                    'Billetera',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _FilaDato(label: 'Saldo deudor', valor: 'Bs 1.200'),
                  _FilaDato(label: 'Capital abonado', valor: 'Bs 800'),
                  _FilaDato(label: 'Teléfono', valor: cliente.telefono),
                  _FilaDato(label: 'Dirección', valor: cliente.direccion),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Historial de préstamos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.request_page_outlined),
                  title: Text('Préstamo Cuota Fija'),
                  subtitle: Text('Bs 2.000 · 6 meses'),
                  trailing: Text('Al día'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaDato extends StatelessWidget {
  const _FilaDato({required this.label, required this.valor});

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
