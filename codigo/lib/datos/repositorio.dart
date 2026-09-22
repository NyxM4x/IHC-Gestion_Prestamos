import '../modelos/cliente.dart';
import '../modelos/cuota.dart';
import '../modelos/pago.dart';
import '../modelos/prestamo.dart';
import 'conexion.dart';

// Todas las idas y venidas a la base de datos, en un solo lugar.
//
// La cartera de un prestamista es chica (entre 7 y 20 prestamos activos),
// asi que se trae todo de una y los calculos se hacen en memoria. Sale mas
// simple que armar consultas cruzadas y la app responde al instante en campo.
//
// La columna usuario_id se llena sola en la base (default auth.uid()), por eso
// aca nunca se manda: cada quien solo ve y escribe lo suyo.
class Repositorio {
  Future<List<Cliente>> cargarClientes() async {
    final filas = await supabase.from('clientes').select().order('nombre');
    return filas.map((fila) => Cliente.desdeMapa(fila)).toList();
  }

  Future<List<Prestamo>> cargarPrestamos() async {
    final filas = await supabase.from('prestamos').select();
    return filas.map((fila) => Prestamo.desdeMapa(fila)).toList();
  }

  // Ordenadas por vencimiento: es como se cobra en la calle.
  Future<List<Cuota>> cargarCuotas() async {
    final filas = await supabase.from('cuotas').select().order('vence');
    return filas.map((fila) => Cuota.desdeMapa(fila)).toList();
  }

  Future<List<Pago>> cargarPagos() async {
    final filas =
        await supabase.from('pagos').select().order('fecha', ascending: false);
    return filas.map((fila) => Pago.desdeMapa(fila)).toList();
  }

  Future<void> guardarCliente(Cliente cliente) async {
    await supabase.from('clientes').insert(cliente.aMapa());
  }

  // El prestamo y su plan de cuotas se guardan juntos: un prestamo sin cuotas
  // no sirve para nada, asi que nunca deben quedar separados.
  Future<void> guardarPrestamoConPlan(
    Prestamo prestamo,
    List<Cuota> cuotas,
  ) async {
    await supabase.from('prestamos').insert(prestamo.aMapa());
    await supabase
        .from('cuotas')
        .insert(cuotas.map((cuota) => cuota.aMapa()).toList());
  }

  Future<void> actualizarCliente(Cliente cliente) async {
    await supabase
        .from('clientes')
        .update(cliente.aMapa())
        .eq('id', cliente.id);
  }

  // Solo se puede cambiar el recargo por atraso. El monto, el plazo y las
  // cuotas no se tocan: ya hay pagos registrados contra ese plan y cambiarlo
  // dejaria el historial sin sentido.
  Future<void> actualizarMora(String prestamoId, double moraPorDia) async {
    await supabase
        .from('prestamos')
        .update({'mora_por_dia': moraPorDia}).eq('id', prestamoId);
  }

  // Borra el prestamo. Sus cuotas y pagos se van solos: el esquema los tiene
  // marcados con "on delete cascade".
  Future<void> borrarPrestamo(String prestamoId) async {
    await supabase.from('prestamos').delete().eq('id', prestamoId);
  }

  // Borra el cliente y, con el, todos sus prestamos.
  Future<void> borrarCliente(String clienteId) async {
    await supabase.from('clientes').delete().eq('id', clienteId);
  }

  // Registrar un cobro son dos cosas: queda el comprobante del pago y sube
  // lo abonado de la cuota. El pago se guarda primero porque es el dato que
  // el prestamista le mostraria al cliente si despues hay un reclamo.
  Future<void> registrarPago(Pago pago, Cuota cuotaActualizada) async {
    await supabase.from('pagos').insert(pago.aMapa());
    await supabase
        .from('cuotas')
        .update({'abonado': cuotaActualizada.abonado}).eq('id', cuotaActualizada.id);
  }
}
