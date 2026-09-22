// Variables que vienen del archivo .env.local al compilar.
//
// Se leen con String.fromEnvironment, que exige que el valor sea constante:
// por eso la app se corre siempre con --dart-define-from-file=.env.local
// (ya esta configurado en .vscode/launch.json).
//
// Aviso: lo que se pone aca queda dentro del programa compilado. La anon key
// de Supabase esta pensada para eso y quien protege los datos es el RLS del
// esquema. La clave service_role NUNCA va aca.
class Configuracion {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Moneda que viene marcada al crear un prestamo. El prestamista la puede
  // cambiar en cada prestamo; esto es solo el valor con el que arranca.
  static const monedaPorDefecto =
      String.fromEnvironment('MONEDA_POR_DEFECTO', defaultValue: 'BOB');

  static bool get estaCompleta =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // Lista de las variables que faltan, para avisar cual es sin adivinar.
  static List<String> get faltantes {
    final faltan = <String>[];
    if (supabaseUrl.isEmpty) faltan.add('SUPABASE_URL');
    if (supabaseAnonKey.isEmpty) faltan.add('SUPABASE_ANON_KEY');
    return faltan;
  }
}
