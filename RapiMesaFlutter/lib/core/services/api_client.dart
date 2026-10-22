import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Cliente HTTP centralizado de RapiMesa.
///
/// Se encarga de dos cosas que antes se hacían a mano en 29 lugares:
///
/// 1. **Adjuntar el token de Firebase.** Toda la API (pedidos, cobros, datos
///    bancarios, personal) exige un token válido. Antes el cliente no lo
///    enviaba, por lo que la API era público-para-todos; ahora cada petición
///    va identificada y la API puede distinguir restaurante y rol.
/// 2. **Resolver la URL base** desde [ApiConfig] en vez de URLs fijas.
class ApiClient {
  const ApiClient._();

  /// Cabeceras con el token de Firebase del usuario activo (si hay sesión).
  ///
  /// Si no hay sesión (por ejemplo, el comensal en modo mesa) la petición se
  /// envía sin token y el backend responderá 401 en las rutas protegidas.
  ///
  /// [forceRefresh] obliga a Firebase a emitir un token nuevo. Hace falta
  /// porque los Custom Claims (el rol) viven dentro del token: si se cambian
  /// en el servidor, el token cacheado sigue siendo válido para el
  /// verificador pero con el rol viejo, y el usuario recibe 403.
  static Future<Map<String, String>> authHeaders({bool forceRefresh = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken(forceRefresh);
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {
      // Sin sesión activa la petición sale sin token; no es un error fatal aquí.
    }
    return headers;
  }

  /// Envía la petición y, si el servidor responde 401 o 403, reintenta una
  /// sola vez con el token refrescado.
  ///
  /// Motivo: el token de Firebase se cachea en el cliente, así que un cambio
  /// de rol (o de claims) en el servidor no se refleja hasta que se refresca.
  /// Sin este reintento, un administrador recién promoted recibe 403 y la
  /// operación falla sin motivo aparente.
  static Future<http.Response> _withAuthRetry(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    var resp = await request(await authHeaders());
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      resp = await request(await authHeaders(forceRefresh: true));
    }
    return resp;
  }

  /// Resuelve la URL contra el origen actual cuando es relativa.
  ///
  /// En web permite compilar con `--dart-define=API_BASE_URL=/` y hablar siempre
  /// con el mismo origen (Hosting reescribe `/api/**` hacia la Cloud Function).
  /// Así el build web no queda atado a una URL de función concreta.
  static String _resolve(String url) {
    if (url.startsWith('/') && kIsWeb) {
      return '${Uri.base.origin}$url';
    }
    return url;
  }

  /// Serializa el cuerpo: si ya viene como `String` JSON se reutiliza tal cual,
  /// de lo contrario se codifica con `jsonEncode`.
  static String? _encodeBody(Object? body) {
    if (body == null) return null;
    if (body is String) return body;
    return jsonEncode(body);
  }

  static Future<http.Response> get(
    String url, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    return _withAuthRetry((headers) =>
        http.get(Uri.parse(_resolve(url)), headers: headers).timeout(timeout));
  }

  static Future<http.Response> post(
    String url, {
    Object? body,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final encoded = _encodeBody(body);
    return _withAuthRetry((headers) =>
        http.post(Uri.parse(_resolve(url)), headers: headers, body: encoded).timeout(timeout));
  }

  static Future<http.Response> patch(
    String url, {
    Object? body,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final encoded = _encodeBody(body);
    return _withAuthRetry((headers) =>
        http.patch(Uri.parse(_resolve(url)), headers: headers, body: encoded).timeout(timeout));
  }

  static Future<http.Response> delete(
    String url, {
    Object? body,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final encoded = _encodeBody(body);
    return _withAuthRetry((headers) =>
        http.delete(Uri.parse(_resolve(url)), headers: headers, body: encoded).timeout(timeout));
  }
}
