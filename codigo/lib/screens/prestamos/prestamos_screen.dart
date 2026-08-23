import 'package:flutter/material.dart';

import 'detalle_prestamo_screen.dart';
import 'nuevo_prestamo_screen.dart';

class PrestamoEjemplo {
  PrestamoEjemplo({
    required this.cliente,
    required this.monto,
    required this.plantilla,
    required this.estado,
  });

  final String cliente;
  final String monto;
  final String plantilla;
  final String estado;
}

class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  final List<PrestamoEjemplo> _prestamos = [
    PrestamoEjemplo(
      cliente: 'María Gutiérrez',
      monto: 'Bs 2.000',
      plantilla: 'Cuota Fija (Mensual)',
      estado: 'Al día',
    ),
    PrestamoEjemplo(
      cliente: 'Juan Pérez',
      monto: 'Bs 500',
      plantilla: 'Gota a Gota (Diario)',
      estado: 'En mora',
    ),
  ];

  String _filtro = 'Todos';

  Future<void> _crearPrestamo() async {
    final nuevo = await Navigator.push<PrestamoEjemplo>(
      context,
      MaterialPageRoute(builder: (_) => const NuevoPrestamoScreen()),
    );
    if (nuevo != null) {
      setState(() => _prestamos.add(nuevo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibles = _filtro == 'Todos'
        ? _prestamos
        : _prestamos.where((p) => p.estado == _filtro).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Préstamos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: ['Todos', 'Al día', 'En mora'].map((opcion) {
                return ChoiceChip(
                  label: Text(opcion),
                  selected: _filtro == opcion,
                  onSelected: (_) => setState(() => _filtro = opcion),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: visibles.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final prestamo = visibles[index];
                final enMora = prestamo.estado == 'En mora';
                return ListTile(
                  leading: Icon(
                    Icons.request_page_outlined,
                    color: enMora ? Colors.red : Colors.green,
                  ),
                  title: Text(prestamo.cliente),
                  subtitle: Text('${prestamo.monto} · ${prestamo.plantilla}'),
                  trailing: Chip(
                    label: Text(prestamo.estado),
                    backgroundColor: enMora
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetallePrestamoScreen(prestamo: prestamo),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearPrestamo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
