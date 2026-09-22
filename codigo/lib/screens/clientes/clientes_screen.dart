import 'package:flutter/material.dart';

import '../../estado/cartera.dart';
import '../../modelos/cliente.dart';
import '../../ui/breakpoints.dart';
import '../../ui/espaciado.dart';
import '../../ui/formato.dart';
import '../../ui/vista_cartera.dart';
import 'detalle_cliente_screen.dart';
import 'nuevo_cliente_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _busquedaCtrl = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _crearCliente() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NuevoClienteScreen()),
    );
    // La cartera se refresca sola al guardar, no hace falta hacer nada mas.
  }

  // Busca por nombre y tambien por telefono: a veces se acuerda del numero
  // antes que del apellido.
  List<Cliente> _filtrar(List<Cliente> todos) {
    final texto = _busqueda.trim().toLowerCase();
    if (texto.isEmpty) return todos;
    return todos.where((cliente) {
      return cliente.nombre.toLowerCase().contains(texto) ||
          cliente.telefono.contains(texto);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: VistaCartera(
        builder: (context) {
          if (cartera.clientes.isEmpty) {
            return SinDatos(
              icono: Icons.people_outline,
              titulo: 'Todavía no tenés clientes',
              explicacion:
                  'Empezá agregando a la persona a la que le vas a prestar.',
              textoBoton: 'Agregar mi primer cliente',
              onBoton: _crearCliente,
            );
          }

          final visibles = _filtrar(cartera.clientes);

          return ContenidoCentrado(
            child: Column(
              children: [
                // El buscador aparece cuando hay suficientes clientes como
                // para que recorrer la lista con el dedo sea incomodo.
                if (cartera.clientes.length >= 5)
                  Padding(
                    padding: const EdgeInsets.all(Espaciado.m),
                    child: TextField(
                      controller: _busquedaCtrl,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o teléfono',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _busqueda.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                tooltip: 'Limpiar',
                                onPressed: () {
                                  _busquedaCtrl.clear();
                                  setState(() => _busqueda = '');
                                },
                              ),
                      ),
                      onChanged: (valor) => setState(() => _busqueda = valor),
                    ),
                  ),

                Expanded(
                  child: visibles.isEmpty
                      ? SinDatos(
                          icono: Icons.person_search_outlined,
                          titulo: 'Nadie se llama así',
                          explicacion:
                              'No encontramos ningún cliente con "$_busqueda".',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: visibles.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            return _FilaCliente(cliente: visibles[index]);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearCliente,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Nuevo cliente'),
      ),
    );
  }
}

class _FilaCliente extends StatelessWidget {
  const _FilaCliente({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    final susPrestamos = cartera.prestamosDe(cliente.id);

    // Cuanto le debe en total, separado por moneda.
    final deudas = <String, double>{};
    for (final prestamo in susPrestamos) {
      var saldo = 0.0;
      for (final cuota in cartera.cuotasDe(prestamo.id)) {
        saldo += cuota.saldo;
      }
      if (saldo > 0) {
        deudas[prestamo.moneda] = (deudas[prestamo.moneda] ?? 0) + saldo;
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Espaciado.m,
        vertical: Espaciado.xs,
      ),
      leading: CircleAvatar(child: Text(cliente.inicial)),
      title: Text(
        cliente.nombre,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        susPrestamos.isEmpty
            ? 'Sin préstamos'
            : '${susPrestamos.length} préstamo'
                '${susPrestamos.length == 1 ? '' : 's'}',
      ),
      trailing: deudas.isEmpty
          ? const Icon(Icons.chevron_right)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final entrada in deudas.entries)
                  Text(
                    formatearMonto(entrada.value, entrada.key),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                const Text('debe', style: TextStyle(fontSize: 12)),
              ],
            ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalleClienteScreen(cliente: cliente),
        ),
      ),
    );
  }
}
