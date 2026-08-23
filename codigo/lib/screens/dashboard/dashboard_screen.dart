import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: const [
              Expanded(
                child: _TarjetaResumen(
                  titulo: 'Capital Prestado',
                  valor: 'Bs 2.500',
                  icono: Icons.account_balance_wallet_outlined,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _TarjetaResumen(
                  titulo: 'Total Recuperado',
                  valor: 'Bs 700',
                  icono: Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Últimos pagos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: _pagosEjemplo
                  .map(
                    (pago) => ListTile(
                      leading: const Icon(Icons.payments_outlined),
                      title: Text(pago.cliente),
                      subtitle: Text(pago.fecha),
                      trailing: Text(
                        pago.monto,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(titulo, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              valor,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PagoEjemplo {
  const _PagoEjemplo(this.cliente, this.fecha, this.monto);
  final String cliente;
  final String fecha;
  final String monto;
}

const _pagosEjemplo = [
  _PagoEjemplo('María Gutiérrez', '20/10/2026', 'Bs 350'),
  _PagoEjemplo('María Gutiérrez', '20/09/2026', 'Bs 350'),
];
