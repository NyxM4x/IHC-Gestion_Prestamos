import '../estado/cartera.dart';
import '../ui/formato.dart';
import 'fechas.dart';
import 'mora.dart';

// Codigo de pais que se le pone al telefono si no lo trae escrito.
// En el cuaderno los numeros se anotan sin el, como 70011223.
const codigoPaisPorDefecto = '591';

// Deja el telefono como lo espera WhatsApp: solo digitos y con codigo de pais.
//
// Se aceptan las formas en que la gente realmente escribe un numero:
// "70011223", "+591 70011223", "591-70011223", "(591) 700 11223".
String telefonoParaWhatsapp(String telefono) {
  // Fuera todo lo que no sea numero: espacios, guiones, parentesis y el mas.
  final soloNumeros = telefono.replaceAll(RegExp(r'[^0-9]'), '');
  if (soloNumeros.isEmpty) return '';

  // Si ya empieza con el codigo de pais y es largo, se deja como esta.
  if (soloNumeros.startsWith(codigoPaisPorDefecto) && soloNumeros.length > 8) {
    return soloNumeros;
  }
  return '$codigoPaisPorDefecto$soloNumeros';
}

// Mensaje que se le manda al cliente para recordarle lo que debe.
//
// Se escribe como le hablaria el prestamista: nombre, cuanto debe y de que.
// Si hay mora se nombra aparte, con los dias de atraso, para que el cliente
// entienda de donde sale el monto y no crea que le estan cobrando de mas.
String mensajeDeCobro(CobroDelDia cobro, {DateTime? hoy}) {
  final ahora = hoy ?? DateTime.now();
  final nombre = cobro.cliente.nombre.split(' ').first;
  final moneda = cobro.moneda;

  // Cuanto de lo exigible es cuota y cuanto es recargo.
  var cuotas = 0.0;
  var recargo = 0.0;
  var diasDeAtraso = 0;

  for (final cuota in cobro.vencidas) {
    cuotas += cuota.saldo;
    recargo += calcularMora(cuota, cobro.prestamo.moraPorDia, ahora);
    final dias = cuota.diasAtraso(ahora);
    if (dias > diasDeAtraso) diasDeAtraso = dias;
  }

  final partes = <String>['Hola $nombre, ¿cómo estás?'];

  if (cobro.cantidadVencidas == 0) {
    // Todavia no vence nada: es un recordatorio, no un reclamo.
    partes.add(
      'Te recuerdo que el ${fechaCorta(cobro.cuota.vence)} vence tu cuota de '
      '${formatearMonto(cobro.cuota.saldo, moneda)}.',
    );
    return partes.join('\n\n');
  }

  if (cobro.tieneVarias) {
    partes.add(
      'Te paso el detalle de tu préstamo: tenés '
      '${cobro.cantidadVencidas} cuotas pendientes, que suman '
      '${formatearMonto(cuotas, moneda)}.',
    );
  } else {
    partes.add(
      'Te paso el detalle: tenés pendiente la cuota '
      '${cobro.cuota.numero} de ${formatearMonto(cuotas, moneda)}, '
      'que venció el ${fechaCorta(cobro.cuota.vence)}.',
    );
  }

  if (recargo > 0) {
    final plural = diasDeAtraso == 1 ? 'día' : 'días';
    partes.add(
      'A eso se suma ${formatearMonto(recargo, moneda)} de recargo por '
      '$diasDeAtraso $plural de atraso.',
    );
    partes.add(
      'Total a pagar: ${formatearMonto(cobro.totalExigible, moneda)}.',
    );
  }

  partes.add('Cualquier cosa avisame. ¡Gracias!');
  return partes.join('\n\n');
}

// Enlace que abre el chat de WhatsApp con el mensaje ya escrito.
// Devuelve null si esa persona no tiene telefono cargado.
String? enlaceWhatsapp(CobroDelDia cobro, {DateTime? hoy}) {
  final numero = telefonoParaWhatsapp(cobro.cliente.telefono);
  if (numero.isEmpty) return null;

  final texto = Uri.encodeComponent(mensajeDeCobro(cobro, hoy: hoy));
  return 'https://wa.me/$numero?text=$texto';
}
