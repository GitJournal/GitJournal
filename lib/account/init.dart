import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://tefpmcttotopcptdivsj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYyODA2NDAyNiwiZXhwIjoxOTQzNjQwMDI2fQ.xAN-giE3m1MPjoRkkdcg_0NJueLH0_L-Wu-V0TSnpwU',
    authCallbackUrlHostname: 'register-callback',
  );
}
