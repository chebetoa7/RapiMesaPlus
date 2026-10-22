import 'environment_service.dart';

/// Configuración centralizada de la API de RapiMesa.
///
/// La URL base ya NO es fija de compilación: se resuelve en tiempo de
/// ejecución a través de [EnvironmentService], que permite conmutar entre
/// PRODUCCIÓN y QA (red local) sin recompilar.
///
/// La URL se inyecta en build con `--dart-define`:
/// ```bash
/// # Producción
/// flutter build ipa --dart-define=API_BASE_URL=https://api.ejemplo.com
///
/// # QA (usa scripts/build_qa.sh, que lee keylocal.txt)
/// ./scripts/build_qa.sh
/// ```
///
/// IMPORTANTE: en un teléfono o tablet físico, `localhost` NO es el servidor.
///   - `localhost` / `127.0.0.1` apuntan al propio dispositivo.
///   - `10.0.2.2` es el alias del EMULADOR de Android (no funciona en hardware).
/// Por eso `API_BASE_URL` es obligatorio para probar en un dispositivo real,
/// y por eso el modo QA existe: apunta a la IP de la LAN.
class ApiConfig {
  const ApiConfig._();

  /// URL base de la API **ahora mismo** (depende del entorno activo).
  static String get baseUrl => EnvironmentService.instance.baseUrl;

  /// Candidatos de conexión en orden de preferencia, sin barra final.
  ///
  /// Cuando `API_BASE_URL` no se define, se prueban en cascada: primero el
  /// localhost de la máquina de desarrollo y luego el alias del emulador.
  /// En modo QA se añaden la IP de la LAN y el hostname mDNS.
  static List<String> get candidates => EnvironmentService.instance.candidates;

  /// URL de la landing comercial (botón "Registrarte").
  ///
  /// En QA apunta al mismo servidor local, porque la API también sirve la
  /// landing estática desde su carpeta `public/`.
  static String get landingUrl => EnvironmentService.instance.baseUrl;

  /// Construye una URL completa a partir de una ruta de la API.
  static String url(String path) => '${candidates.first}$path';
}
