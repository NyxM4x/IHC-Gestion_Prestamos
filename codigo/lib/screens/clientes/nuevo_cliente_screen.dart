import 'package:flutter/material.dart';

import '../../estado/cartera.dart';
import '../../logica/identificadores.dart';
import '../../modelos/cliente.dart';
import '../../ui/avisos.dart';
import '../../ui/breakpoints.dart';
import '../../ui/espaciado.dart';

// Sirve para crear y para editar: si le llega un cliente, arranca con sus
// datos cargados y al guardar lo actualiza en vez de agregar uno nuevo.
class NuevoClienteScreen extends StatefulWidget {
  const NuevoClienteScreen({super.key, this.clienteAEditar});

  final Cliente? clienteAEditar;

  @override
  State<NuevoClienteScreen> createState() => _NuevoClienteScreenState();
}

class _NuevoClienteScreenState extends State<NuevoClienteScreen> {
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  bool _guardando = false;
  String _error = '';

  bool get _editando => widget.clienteAEditar != null;

  @override
  void initState() {
    super.initState();
    final cliente = widget.clienteAEditar;
    if (cliente != null) {
      _nombreCtrl.text = cliente.nombre;
      _telefonoCtrl.text = cliente.telefono;
      _direccionCtrl.text = cliente.direccion;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  // Solo el nombre es obligatorio: en la calle muchas veces se anota primero
  // a la persona y el telefono se pide despues.
  bool get _puedeGuardar => _nombreCtrl.text.trim().length >= 2;

  // Avisa si ya hay alguien con ese mismo nombre, sin impedir guardarlo:
  // puede haber dos Juan Perez distintos y el prestamista sabra.
  String get _avisoRepetido {
    final nombre = _nombreCtrl.text.trim().toLowerCase();
    if (nombre.isEmpty) return '';
    for (final cliente in cartera.clientes) {
      // Al editar, su propio nombre no cuenta como repetido.
      if (cliente.id == widget.clienteAEditar?.id) continue;
      if (cliente.nombre.toLowerCase() == nombre) {
        return 'Ya tenés un cliente con ese nombre. Si son dos personas '
            'distintas, agregá algo que las diferencie.';
      }
    }
    return '';
  }

  Future<void> _guardar() async {
    setState(() {
      _guardando = true;
      _error = '';
    });

    final cliente = Cliente(
      id: widget.clienteAEditar?.id ?? nuevoId('cli'),
      nombre: _nombreCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
    );

    try {
      if (_editando) {
        await cartera.actualizarCliente(cliente);
      } else {
        await cartera.agregarCliente(cliente);
      }
      if (!mounted) return;

      mostrarAviso(
        context,
        _editando
            ? 'Los datos de ${cliente.nombre} quedaron actualizados'
            : '${cliente.nombre} quedó guardado',
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = 'No se pudo guardar. Revisá tu conexión e intentá de nuevo';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar cliente' : 'Nuevo cliente'),
      ),
      body: ContenidoCentrado(
        anchoMaximo: 480,
        child: ListView(
          padding: const EdgeInsets.all(Espaciado.m),
          children: [
            Text('¿Cómo se llama?', style: textos.titleMedium),
            const SizedBox(height: Espaciado.s),
            TextField(
              controller: _nombreCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Nombre y apellido',
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: (_) => setState(() {}),
            ),

            if (_avisoRepetido.isNotEmpty) ...[
              const SizedBox(height: Espaciado.s),
              Aviso(_avisoRepetido, nivel: NivelAviso.advertencia),
            ],

            const SizedBox(height: Espaciado.l),

            Text('Teléfono', style: textos.titleMedium),
            const SizedBox(height: Espaciado.s),
            TextField(
              controller: _telefonoCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '70011223',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),

            const SizedBox(height: Espaciado.l),

            Text('Dónde vive o trabaja', style: textos.titleMedium),
            const SizedBox(height: Espaciado.s),
            TextField(
              controller: _direccionCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Mercado Abasto, puesto 42',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),

            if (_error.isNotEmpty) ...[
              const SizedBox(height: Espaciado.m),
              Aviso(_error, nivel: NivelAviso.bloqueo),
            ],

            const SizedBox(height: Espaciado.xl),

            FilledButton(
              onPressed: _puedeGuardar && !_guardando ? _guardar : null,
              child: _guardando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_editando ? 'Guardar cambios' : 'Guardar cliente'),
            ),

            if (!_puedeGuardar) ...[
              const SizedBox(height: Espaciado.s),
              const Aviso('Escribí al menos el nombre para poder guardarlo'),
            ],
            const SizedBox(height: Espaciado.l),
          ],
        ),
      ),
    );
  }
}
