// Una persona a la que el prestamista le presta plata.
class Cliente {
  Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.direccion,
  });

  final String id;
  final String nombre;
  final String telefono;
  final String direccion;

  // La primera letra sirve para el circulito del listado.
  String get inicial => nombre.isEmpty ? '?' : nombre[0].toUpperCase();

  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'direccion': direccion,
    };
  }

  static Cliente desdeMapa(Map<String, dynamic> mapa) {
    return Cliente(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String,
      telefono: (mapa['telefono'] ?? '') as String,
      direccion: (mapa['direccion'] ?? '') as String,
    );
  }
}
