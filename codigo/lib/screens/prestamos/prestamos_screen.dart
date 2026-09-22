import 'package:flutter/material.dart';

import '../../estado/cartera.dart';
import '../../logica/fechas.dart';
import '../../modelos/cuota.dart';
import '../../modelos/prestamo.dart';
import '../../ui/breakpoints.dart';
import '../../ui/espaciado.dart';
import '../../ui/formato.dart';
import '../../ui/tema.dart';
import '../../ui/vista_cartera.dart';
import 'detalle_prestamo_screen.dart';
import 'nuevo_prestamo_screen.dart';

class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  String _filtro = 'Todos';

  Future<void> _crearPrestamo() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NuevoPrestamoScreen()),
    );
  }

  // Un prestamo esta en mora si su proxima cuota ya vencio.
  bool _enMora(Prestamo prestamo, DateTime hoy) {
    final proxima = cartera.proximaCuotaDe(prestamo.id);
    return proxima != null && proxima.diasAtraso(hoy) > 0;
  }

  bool _terminado(Prestamo prestamo) {
    return cartera.proximaCuotaDe(prestamo.id) == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Préstamos')),
      body: VistaCartera(
        builder: (context) {
          if (cartera.prestamos.isEmpty) {
            return SinDatos(
              icono: Icons.request_page_outlined,
              titulo: 'Todavía no registraste préstamos',
              explicacion: 'Registrá el primero y la app te arma el plan de '
                  'cuotas sola.',
              textoBoton: 'Registrar préstamo',
              onBoton: _crearPrestamo,
            );
          }

          final hoy = DateTime.now();
          final visibles = cartera.prestamos.where((prestamo) {
            switch (_filtro) {
              case 'En mora':
                return _enMora(prestamo, hoy);
              case 'Al día':
                return !_enMora(prestamo, hoy) && !_terminado(prestamo);
              case 'Terminados':
                return _terminado(prestamo);
              default:
                return true;
            }
          }).toList();

          return ContenidoCentrado(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Espaciado.m,
                    vertical: Espaciado.s,
                  ),
                  child: Wrap(
                    spacing: Espaciado.s,
                    children: ['Todos', 'En mora', 'Al día', 'Terminados']
                        .map((opcion) {
                      return ChoiceChip(
                        label: Text(opcion),
                        selected: _filtro == opcion,
                        onSelected: (_) => setState(() => _filtro = opcion),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: visibles.isEmpty
                      ? SinDatos(
                          icono: Icons.filter_alt_off_outlined,
                          titulo: 'Nada en "$_filtro"',
                          explicacion:
                              'Probá con otro filtro para ver tus préstamos.',
                        )
                      : ListView.separated(
                          itemCount: visibles.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            return _FilaPrestamo(
                              prestamo: visibles[index],
                              hoy: hoy,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearPrestamo,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo préstamo'),
      ),
    );
  }
}

class _FilaPrestamo extends StatelessWidget {
  const _FilaPrestamo({required this.prestamo, required this.hoy});

  final Prestamo prestamo;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final cliente = cartera.clientePorId(prestamo.clienteId);
    final proxima = cartera.proximaCuotaDe(prestamo.id);

    // Sin proxima cuota el prestamo ya se termino de pagar.
    final estado = proxima?.estado(hoy);
    final color = estado == null ? Colors.grey : colorDeEstado(estado);

    var saldo = 0.0;
    for (final cuota in cartera.cuotasDe(prestamo.id)) {
      saldo += cuota.saldo;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Espaciado.m,
        vertical: Espaciado.xs,
      ),
      leading: Icon(
        estado == null ? Icons.check_circle_outline : iconoDeEstado(estado),
        color: color,
      ),
      title: Text(
        cliente?.nombre ?? 'Cliente',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        proxima == null
            ? 'Terminado · te devolvió todo'
            : '${nombreFrecuencia(prestamo.frecuencia)} · próxima '
                '${fechaCorta(proxima.vence)}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatearMonto(saldo, prestamo.moneda),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            estado == null ? 'pagado' : nombreEstado(estado),
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetallePrestamoScreen(prestamoId: prestamo.id),
        ),
      ),
    );
  }
}
