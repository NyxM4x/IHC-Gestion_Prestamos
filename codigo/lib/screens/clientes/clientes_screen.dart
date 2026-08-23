import 'package:flutter/material.dart';

import 'detalle_cliente_screen.dart';
import 'nuevo_cliente_screen.dart';

class ClienteEjemplo {
  ClienteEjemplo({
    required this.nombre,
    required this.telefono,
    required this.direccion,
  });

  final String nombre;
  final String telefono;
  final String direccion;
}

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final List<ClienteEjemplo> _clientes = [
    ClienteEjemplo(
      nombre: 'María Gutiérrez',
      telefono: '70011223',
      direccion: 'Av. Cristo Redentor, Santa Cruz',
    ),
    ClienteEjemplo(
      nombre: 'Juan Pérez',
      telefono: '69988776',
      direccion: 'Zona Villa 1ro de Mayo',
    ),
  ];

  Future<void> _crearCliente() async {
    final nuevo = await Navigator.push<ClienteEjemplo>(
      context,
      MaterialPageRoute(builder: (_) => const NuevoClienteScreen()),
    );
    if (nuevo != null) {
      setState(() => _clientes.add(nuevo));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _clientes.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final cliente = _clientes[index];
          return ListTile(
            leading: CircleAvatar(child: Text(cliente.nombre[0])),
            title: Text(cliente.nombre),
            subtitle: Text(cliente.telefono),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetalleClienteScreen(cliente: cliente),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearCliente,
        child: const Icon(Icons.add),
      ),
    );
  }
}
