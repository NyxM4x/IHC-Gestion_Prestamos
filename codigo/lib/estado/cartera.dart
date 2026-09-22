import 'package:flutter/foundation.dart';

import '../datos/repositorio.dart';
import '../logica/mora.dart';
import '../logica/plan_cuotas.dart';
import '../modelos/cliente.dart';
import '../modelos/cuota.dart';
import '../modelos/pago.dart';
import '../modelos/prestamo.dart';

// Lo que hay que cobrarle hoy a una persona por un prestamo.
//
// No es una sola cuota: si alguien se atrasa varios dias en un prestamo diario,
// acumula varias cuotas vencidas a la vez. Mostrar solo la mas vieja haria
// creer que debe menos de lo que debe.
class CobroDelDia {
  CobroDelDia({
    required this.cuota,
    required this.vencidas,
    required this.prestamo,
    required this.cliente,
    required this.montoACobrar,
    required this.totalExigible,
    required this.desglose,
  });

  final Cuota cuota; // la mas vieja sin pagar: es la que se cobra primero
  final List<Cuota> vencidas; // todas las que ya se pueden cobrar hoy
  final Prestamo prestamo;
  final Cliente cliente;
  final double montoACobrar; // solo la cuota actual, con su mora
  final double totalExigible; // todas las vencidas juntas, con sus moras
  final String desglose;

  String get moneda => prestamo.moneda;

  int get cantidadVencidas => vencidas.length;

  // Con una sola cuota pendiente no hace falta aclarar nada; con varias, si.
  bool get tieneVarias => vencidas.length > 1;
}

// Toda la cartera del prestamista en memoria, cargada desde la base.
//
// Es la unica fuente de datos de la app: las pantallas leen de aca y nunca
// arman listas propias. Asi no puede volver a pasar que una pantalla muestre
// un cliente que otra no conoce.
//
// Despues de cada cambio se vuelve a cargar todo. Con 7 a 20 prestamos la
// recarga es instantanea, y a cambio nunca queda un dato viejo dando vueltas.
class Cartera extends ChangeNotifier {
  final _repo = Repositorio();

  List<Cliente> clientes = [];
  List<Prestamo> prestamos = [];
  List<Cuota> cuotas = [];
  List<Pago> pagos = [];

  bool cargando = true;
  String error = '';

  // --- Carga ---------------------------------------------------------------

  Future<void> cargarTodo() async {
    cargando = true;
    error = '';
    notifyListeners();

    try {
      clientes = await _repo.cargarClientes();
      prestamos = await _repo.cargarPrestamos();
      cuotas = await _repo.cargarCuotas();
      pagos = await _repo.cargarPagos();
    } catch (e) {
      error = 'No se pudieron traer tus datos. Revisá tu conexión';
    }

    cargando = false;
    notifyListeners();
  }

  // Deja la cartera en blanco. Se usa al cerrar sesion, para que los datos
  // de una cuenta no queden a la vista mientras entra otra.
  void vaciar() {
    clientes = [];
    prestamos = [];
    cuotas = [];
    pagos = [];
    error = '';
    notifyListeners();
  }

  // --- Consultas -----------------------------------------------------------

  Cliente? clientePorId(String id) {
    for (final cliente in clientes) {
      if (cliente.id == id) return cliente;
    }
    return null;
  }

  Prestamo? prestamoPorId(String id) {
    for (final prestamo in prestamos) {
      if (prestamo.id == id) return prestamo;
    }
    return null;
  }

  List<Cuota> cuotasDe(String prestamoId) {
    final propias = cuotas.where((c) => c.prestamoId == prestamoId).toList();
    propias.sort((a, b) => a.numero.compareTo(b.numero));
    return propias;
  }

  // Pagos de un prestamo, del mas nuevo al mas viejo. Es el comprobante que
  // el prestamista muestra si el cliente discute cuanto entrego.
  List<Pago> pagosDe(String prestamoId) {
    return pagos.where((p) => p.prestamoId == prestamoId).toList();
  }

  // Cuanto se cobro hoy en cada moneda, para el cierre del dia.
  double cobradoHoy(String moneda, {DateTime? hoy}) {
    final ahora = hoy ?? DateTime.now();
    var total = 0.0;
    for (final pago in pagos) {
      final esDeHoy = pago.fecha.year == ahora.year &&
          pago.fecha.month == ahora.month &&
          pago.fecha.day == ahora.day;
      if (!esDeHoy) continue;
      final prestamo = prestamoPorId(pago.prestamoId);
      if (prestamo != null && prestamo.moneda == moneda) total += pago.monto;
    }
    return total;
  }

  int cantidadCobradaHoy({DateTime? hoy}) {
    final ahora = hoy ?? DateTime.now();
    return pagos.where((p) {
      return p.fecha.year == ahora.year &&
          p.fecha.month == ahora.month &&
          p.fecha.day == ahora.day;
    }).length;
  }

  List<Prestamo> prestamosDe(String clienteId) {
    return prestamos.where((p) => p.clienteId == clienteId).toList();
  }

  // Primera cuota sin pagar de un prestamo: la que toca cobrar.
  Cuota? proximaCuotaDe(String prestamoId) {
    for (final cuota in cuotasDe(prestamoId)) {
      if (!cuota.pagada) return cuota;
    }
    return null;
  }

  // Agenda del dia: lo vencido primero, despues lo que vence hoy y al final
  // lo que todavia no vence. Ese es el orden en que se cobra en la calle.
  List<CobroDelDia> cobrosDelDia({DateTime? hoy}) {
    final ahora = hoy ?? DateTime.now();
    final lista = <CobroDelDia>[];

    // Se recorre prestamo por prestamo, no cuota por cuota: lo que se le cobra
    // a una persona es el conjunto de sus cuotas vencidas, no una sola.
    for (final prestamo in prestamos) {
      final cliente = clientePorId(prestamo.clienteId);
      if (cliente == null) continue;

      final proxima = proximaCuotaDe(prestamo.id);
      if (proxima == null) continue; // ya termino de pagar

      // Todas las que ya se pueden cobrar: las vencidas y la que vence hoy.
      final vencidas = cuotasEnDeuda(prestamo.id, ahora);

      var total = 0.0;
      for (final cuota in vencidas) {
        total += montoACobrar(cuota, prestamo, ahora);
      }

      lista.add(
        CobroDelDia(
          cuota: proxima,
          vencidas: vencidas,
          prestamo: prestamo,
          cliente: cliente,
          montoACobrar: montoACobrar(proxima, prestamo, ahora),
          totalExigible: total,
          desglose: desgloseDelCobro(proxima, prestamo, ahora),
        ),
      );
    }

    lista.sort((a, b) => a.cuota.vence.compareTo(b.cuota.vence));
    return lista;
  }

  // El cobro pendiente de un prestamo puntual, para las pantallas que
  // trabajan sobre un prestamo y no sobre la agenda entera.
  CobroDelDia? cobroDe(String prestamoId, {DateTime? hoy}) {
    for (final cobro in cobrosDelDia(hoy: hoy)) {
      if (cobro.prestamo.id == prestamoId) return cobro;
    }
    return null;
  }

  // Cuotas de un prestamo que ya se pueden cobrar hoy, de la mas vieja a la
  // mas nueva.
  List<Cuota> cuotasEnDeuda(String prestamoId, DateTime hoy) {
    return cuotasDe(prestamoId).where((c) => c.esExigible(hoy)).toList();
  }

  // Lo que ya se puede cobrar hoy, por moneda. Suma todas las cuotas vencidas
  // de cada prestamo, no solo la primera.
  double exigibleHoy(String moneda, {DateTime? hoy}) {
    final ahora = hoy ?? DateTime.now();
    var total = 0.0;
    for (final cobro in cobrosDelDia(hoy: ahora)) {
      if (cobro.moneda == moneda) total += cobro.totalExigible;
    }
    return total;
  }

  // Cuantas cuotas hay para cobrar hoy en total, sumando las de todos los
  // prestamos.
  int cantidadExigibleHoy({DateTime? hoy}) {
    final ahora = hoy ?? DateTime.now();
    var cuantas = 0;
    for (final cobro in cobrosDelDia(hoy: ahora)) {
      cuantas += cobro.cantidadVencidas;
    }
    return cuantas;
  }

  // A cuantas personas hay que ir a ver hoy. Es distinto de la cantidad de
  // cuotas: una persona puede deber varias.
  int personasPorCobrarHoy({DateTime? hoy}) {
    final ahora = hoy ?? DateTime.now();
    return cobrosDelDia(hoy: ahora).where((c) => c.cantidadVencidas > 0).length;
  }

  // Plata que el prestamista tiene puesta en la calle, por moneda.
  double capitalPrestado(String moneda) {
    var total = 0.0;
    for (final prestamo in prestamos) {
      if (prestamo.moneda == moneda) total += prestamo.capital;
    }
    return total;
  }

  // Lo que ya volvio, por moneda.
  double totalRecuperado(String moneda) {
    var total = 0.0;
    for (final pago in pagos) {
      final prestamo = prestamoPorId(pago.prestamoId);
      if (prestamo != null && prestamo.moneda == moneda) total += pago.monto;
    }
    return total;
  }

  // Monedas que el prestamista realmente usa, para no mostrar tarjetas vacias.
  List<String> get monedasEnUso {
    final usadas = <String>[];
    for (final prestamo in prestamos) {
      if (!usadas.contains(prestamo.moneda)) usadas.add(prestamo.moneda);
    }
    return usadas;
  }

  // --- Cambios -------------------------------------------------------------

  Future<void> agregarCliente(Cliente cliente) async {
    await _repo.guardarCliente(cliente);
    await cargarTodo();
  }

  // Guarda el prestamo junto con su plan de cuotas ya calculado.
  Future<void> crearPrestamo(Prestamo prestamo) async {
    final plan = generarPlan(prestamo);
    await _repo.guardarPrestamoConPlan(prestamo, plan);
    await cargarTodo();
  }

  Future<void> actualizarCliente(Cliente cliente) async {
    await _repo.actualizarCliente(cliente);
    await cargarTodo();
  }

  Future<void> actualizarMora(String prestamoId, double moraPorDia) async {
    await _repo.actualizarMora(prestamoId, moraPorDia);
    await cargarTodo();
  }

  // Cuantos prestamos perderia el cliente si se lo borra. Sirve para avisarlo
  // antes de preguntar, no despues.
  int prestamosQuePerderia(String clienteId) => prestamosDe(clienteId).length;

  Future<void> borrarPrestamo(String prestamoId) async {
    await _repo.borrarPrestamo(prestamoId);
    await cargarTodo();
  }

  Future<void> borrarCliente(String clienteId) async {
    await _repo.borrarCliente(clienteId);
    await cargarTodo();
  }

  // Registra lo que el cliente entrego.
  //
  // El monto cobrado puede ser mayor que la cuota, porque incluye la mora.
  // La mora no es parte de la cuota: es un recargo aparte. Por eso el pago se
  // guarda completo (es lo que realmente entro a la mano del prestamista),
  // pero lo abonado de la cuota solo sube hasta saldarla y nunca mas.
  //
  // Si el monto es menor que la cuota queda como abono y la cuota sigue
  // abierta.
  Future<void> registrarPago(Cuota cuota, double monto, String idPago) async {
    final aLaCuota = monto > cuota.saldo ? cuota.saldo : monto;
    final actualizada = cuota.conAbono(cuota.abonado + aLaCuota);

    await _repo.registrarPago(
      Pago(
        id: idPago,
        cuotaId: cuota.id,
        prestamoId: cuota.prestamoId,
        monto: monto,
        fecha: DateTime.now(),
      ),
      actualizada,
    );
    await cargarTodo();
  }
}

// Una sola cartera para toda la app. Las pantallas la escuchan con
// AnimatedBuilder y se redibujan solas cuando algo cambia, sin que haya que
// pasarla de pantalla en pantalla.
final cartera = Cartera();
