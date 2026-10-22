import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/presentation/login_page.dart';
import 'firebase_options.dart';

import 'core/config/environment_service.dart';
import 'core/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // El entorno (PROD / QA) se elige en runtime y se guarda en el dispositivo.
  // Se carga ANTES de runApp para que la primera petición ya vaya al backend
  // correcto. Tarda unos milisegundos (leer SharedPreferences).
  await EnvironmentService.instance.cargar();

  // La inicialización de Firebase no debe impedir que la app arranque: si
  // falla, se muestra la pantalla de acceso y el error queda registrado.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, s) {
    debugPrint('[main] No se pudo inicializar Firebase: $e');
    debugPrintStack(stackTrace: s);
  }

  // IMPORTANTE: `runApp` va ANTES de pedir el permiso de notificaciones.
  // En iOS, `requestPermission()` no resuelve hasta que el usuario responde,
  // y hacerlo antes de `runApp` dejaba la pantalla completamente en blanco
  // durante todo ese tiempo. La app ya está en pantalla cuando aparece el
  // diálogo del sistema.
  runApp(const RapiMesaApp());

  // Notificaciones Push (foreground y background). No bloquea el arranque.
  unawaited(PushNotificationService().initialize());

  // El token FCM se registra en el backend nada más arrancar, para que el
  // dispositivo quede aunque el usuario aún no haya iniciado sesión. La
  // pantalla de menú lo vuelve a registrar con el rol y el restaurante.
  unawaited(PushNotificationService().registerThisDevice());
}

class RapiMesaApp extends StatelessWidget {
  const RapiMesaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RapiMesa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF16821),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
