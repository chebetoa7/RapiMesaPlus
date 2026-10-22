import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Entornos en los que puede correr la app.
enum AppEnvironment {
  /// Producción: la URL viene del propio build (`--dart-define=API_BASE_URL`).
  production,

  /// QA: la API está en la red local (tu Mac), la URL viene de `keylocal.txt`.
  qa,
}

/// Estado del entorno en tiempo de ejecución.
///
/// La URL de la API antes era fija de compilación (`String.fromEnvironment`),
/// lo que impedía cambiar entre PR y QA sin recompilar. Ahora el entorno se
/// elige **en runtime** y se guarda en el dispositivo, de modo que la app
/// puede conmutar sola sin reinstalar.
///
/// La contraseña del modo QA **no está en el código**: llega por
/// `--dart-define=QA_PASSWORD=...` desde `keylocal.txt` (ver
/// `scripts/build_qa.sh`). En un build sin esa define, [qaDeshabilitado] es
/// `true` y el conmutador queda completamente inerte.
class EnvironmentService {
  EnvironmentService._();
  static final EnvironmentService instance = EnvironmentService._();

  /// URL base definida en compilación (la de producción).
  static const String buildTimeBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Contraseña del conmutador QA. Vacía = este build NO tiene modo QA.
  static const String qaPassword = String.fromEnvironment(
    'QA_PASSWORD',
    defaultValue: '',
  );

  /// URL de la API en la red local, tomada de `keylocal.txt` al compilar.
  static const String buildTimeQaUrl = String.fromEnvironment(
    'QA_API_URL',
    defaultValue: 'http://192.168.0.136:3000',
  );

  static const String _kEntorno = 'rapimesa.entorno';
  static const String _kQaUrl = 'rapimesa.qa_url';

  AppEnvironment _entorno = AppEnvironment.production;
  String _qaUrl = buildTimeQaUrl;

  AppEnvironment get entorno => _entorno;
  bool get esQa => _entorno == AppEnvironment.qa;
  bool get esProduccion => _entorno == AppEnvironment.production;

  /// Si este build no trae contraseña, el conmutador QA no existe.
  bool get qaDeshabilitado => qaPassword.isEmpty;

  /// URL de la API que se está usando ahora mismo.
  String get baseUrl => esQa ? _qaUrl : buildTimeBaseUrl;

  /// Valida la contraseña del conmutador.
  bool passwordCorrecta(String entrada) =>
      qaPassword.isNotEmpty && entrada == qaPassword;

  /// Lista de URLs a probar, en orden de preferencia.
  ///
  /// La app ya probaba varias (localhost, 127.0.0.1, 10.0.2.2 para el
  /// emulador de Android). En QA se añade la IP de la LAN y el hostname
  /// mDNS, que es estable aunque el DHCP cambie la IP.
  List<String> get candidates {
    if (esQa) {
      final base = _limpiar(_qaUrl);
      return <String>[
        base,
        'http://192.168.0.136:3000',
        'http://MacBook-Air-de-Marco-2.local:3000',
        'http://localhost:3000',
      ];
    }

    final base = _limpiar(buildTimeBaseUrl);
    if (base.isEmpty) return const <String>[''];
    if (base.startsWith('/')) return <String>[base];
    return <String>[
      base,
      if (base == 'http://localhost:3000') ...[
        'http://127.0.0.1:3000',
        'http://10.0.2.2:3000',
      ],
    ];
  }

  static String _limpiar(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  /// Carga el entorno guardado en el dispositivo.
  ///
  /// Se llama al arrancar la app, antes de `runApp`.
  Future<void> cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _qaUrl = prefs.getString(_kQaUrl) ?? buildTimeQaUrl;
      _entorno = prefs.getString(_kEntorno) == 'qa'
          ? AppEnvironment.qa
          : AppEnvironment.production;
    } catch (_) {
      // Si no hay almacenamiento disponible, se sigue con producción.
      _entorno = AppEnvironment.production;
      _qaUrl = buildTimeQaUrl;
    }
  }

  /// Cambia de entorno y lo persiste.
  Future<void> setEntorno(AppEnvironment entorno, {String? qaUrl}) async {
    _entorno = entorno;
    if (qaUrl != null && qaUrl.trim().isNotEmpty) {
      _qaUrl = _limpiar(qaUrl);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kEntorno, entorno.name);
      await prefs.setString(_kQaUrl, _qaUrl);
    } catch (_) {
      // Sin persistencia, el cambio solo dura hasta cerrar la app.
    }
  }

  /// Etiqueta corta para mostrar en pantalla.
  String get etiqueta => esQa ? 'QA · LAN' : 'PROD';
}
