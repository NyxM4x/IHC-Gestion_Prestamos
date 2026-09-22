import 'package:supabase_flutter/supabase_flutter.dart';

import 'configuracion.dart';

// Arranca la conexion con Supabase una sola vez, al abrir la app.
// Devuelve false si faltan las variables, para que main pueda mostrar una
// pantalla que explique que falta en vez de reventar sin decir nada.
Future<bool> iniciarSupabase() async {
  if (!Configuracion.estaCompleta) return false;

  await Supabase.initialize(
    url: Configuracion.supabaseUrl,
    // Supabase renombro esta llave: en el panel nuevo figura como
    // "publishable key", pero es la misma que antes se llamaba anon key.
    publishableKey: Configuracion.supabaseAnonKey,
  );
  return true;
}

// Atajo para no escribir Supabase.instance.client en todos lados.
SupabaseClient get supabase => Supabase.instance.client;
