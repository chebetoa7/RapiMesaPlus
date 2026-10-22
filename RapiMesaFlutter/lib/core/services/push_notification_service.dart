import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/api_config.dart';
import 'api_client.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[FCM Background] Notificación en segundo plano recibida: ${message.data}');
  } catch (e) {
    debugPrint('[FCM Background Error]: $e');
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String? _currentToken;
  bool _initialized = false;
  Timer? _reregisterTimer;

  /// Restaurante y rol del último registro válido.
  ///
  /// Se guardan porque hay varios momentos en que se re-registra el
  /// dispositivo (al iniciar sesión, al abrir el menú, cada 5 minutos) y
  /// alguno de ellos ocurre sin tener el restaurante a mano. Si el re-registro
  /// se mandara sin restaurante, el backend perdía el que ya tenía y el
  /// dispositivo dejaba de recibir push (el envío se filtra por restaurante).
  String? _knownRestaurantId;
  String? _knownRole;

  // Callbacks reactivos para primer plano
  //
  // `onMenuUpdated` recibe los datos del push (acción, tipo y nombre del
  // platillo) para que la app pueda avisar QUÉ se eliminó del menú, y no solo
  // recargar la lista en silencio.
  void Function(Map<String, dynamic> data)? onMenuUpdated;
  void Function(Map<String, dynamic> data)? onNewOrder;
  void Function(Map<String, dynamic> data)? onStaffCall;

  /// Traduce el rol de la app al que espera el backend.  ///
  /// El backend suscribe el token al tópico según el rol:
  /// table -> _tables, kitchen -> _kitchen, waiter -> _waiters, resto -> _admins.
  static String backendRoleFor(String? role) {
    switch ((role ?? '').toLowerCase()) {
      case 'table':
      case 'tablet':
        return 'table';
      case 'kitchen':
      case 'chef':
      case 'cocina':
        return 'kitchen';
      case 'waiter':
      case 'mesero':
      case 'waitress':
        return 'waiter';
      default:
        return 'admin';
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // 1. Solicitar permisos de notificación (Android 13+, iOS, Web)
      try {
        final settings = await _fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        debugPrint('[FCM] Permisos de notificación: ${settings.authorizationStatus}');
      } catch (permErr) {
        debugPrint('[FCM Warning]: Permisos no concedidos o pendientes: $permErr');
      }

      // 2. Obtener Token FCM del dispositivo
      //
      // En WEB la clave VAPID es obligatoria: sin ella, el SDK de FCM no
      // resuelve la promesa y la llamada se queda colgada para siempre. La
      // clave es el "Web Push certificate" de Firebase (Project settings →
      // Cloud Messaging → Web Push certificates → Generate key pair) y se
      // inyecta en build con:
      //   flutter run -d chrome --dart-define=VAPID_KEY=<clave publica>
      const vapidKey = String.fromEnvironment('VAPID_KEY');

      try {
        _currentToken = await _obtainToken(vapidKey);
        if (_currentToken == null || _currentToken!.isEmpty) {
          debugPrint(
            '[FCM] No se obtuvo token FCM.'
            '${kIsWeb && vapidKey.isEmpty ? ' En web hace falta la VAPID key (--dart-define=VAPID_KEY=...).' : ''}',
          );
        } else {
          debugPrint('[FCM] Token obtenido: $_currentToken');
        }

        // Escuchar refresco de token
        _fcm.onTokenRefresh.listen((newToken) {
          _currentToken = newToken;
          debugPrint('[FCM] Token actualizado: $newToken');
          // Un token rotado sin volver a registrar deja el dispositivo sin push.
          unawaited(registerThisDevice());
        });
      } catch (tokenErr) {
        debugPrint('[FCM Warning]: Error al obtener token: $tokenErr');
      }

      // 3. Cada vez que haya sesión iniciada, el dispositivo se registra en el
      // backend. `register-device` exige un token de Firebase válido, así que
      // registrar en el arranque (antes de iniciar sesión) siempre devolvía
      // 401 y el dispositivo se quedaba sin push para siempre.
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user == null) return;
        debugPrint('[FCM] Sesión iniciada: registrando dispositivo en el backend');
        unawaited(registerThisDevice());
      });

      // 3. Escuchar notificaciones en PRIMER PLANO (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM Foreground] Mensaje recibido en primer plano:');
        debugPrint('  Título: ${message.notification?.title}');
        debugPrint('  Cuerpo: ${message.notification?.body}');
        debugPrint('  Data: ${message.data}');

        final type = message.data['type'];
        if (type == 'menu_updated') {
          debugPrint('[FCM Foreground] Disparando recarga de menú reactiva...');
          onMenuUpdated?.call(message.data);
        } else if (type == 'new_order') {
          debugPrint('[FCM Foreground] Disparando recarga de comandas...');
          onNewOrder?.call(message.data);
        } else if (type == 'staff_call') {
          debugPrint('[FCM Foreground] Disparando llamado de personal...');
          onStaffCall?.call(message.data);
        }
      });

      // 4. Configurar handler de segundo plano (Solo en Android/iOS nativo; en Web lo maneja firebase-messaging-sw.js)
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }

      // 5. Manejar click al abrir notificación desde segundo plano o terminada
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM onMessageOpenedApp] Notificación abierta por usuario: ${message.data}');
        final type = message.data['type'];
        if (type == 'menu_updated') {
          onMenuUpdated?.call(message.data);
        } else if (type == 'new_order') {
          onNewOrder?.call(message.data);
        } else if (type == 'staff_call') {
          onStaffCall?.call(message.data);
        }
      });
    } catch (e) {
      debugPrint('[FCM Init Error]: $e');
    }
  }

  /// Obtiene el token FCM reintentando.
  ///
  /// En web el SDK de FCM registra su service worker y llama a
  /// `pushManager.subscribe()` nada más terminar. Si el service worker todavía
  /// se está instalando, el navegador responde:
  ///   "Subscription failed - no active Service Worker"
  /// y la app se queda SIN TOKEN: nunca se registra en el backend y nunca le
  /// llega ninguna push. El plugin solo reintenta una vez y sin esperar, así
  /// que aquí se reintenta con espera hasta que el worker esté activo.
  Future<String?> _obtainToken(String vapidKey) async {
    String? lastError;
    for (int intento = 0; intento < 4; intento++) {
      if (intento > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 1500));
      }
      try {
        final token = await _fcm
            .getToken(vapidKey: vapidKey.isEmpty ? null : vapidKey)
            .timeout(const Duration(seconds: 20), onTimeout: () => null);
        if (token != null && token.isNotEmpty) return token;
        lastError = 'getToken devolvió vacío';
      } catch (e) {
        lastError = e.toString();
        debugPrint('[FCM] getToken falló (intento ${intento + 1}/4): $e');
      }
    }
    debugPrint('[FCM] No se pudo obtener el token FCM. Último error: $lastError');
    return null;
  }

  /// Suscribe el dispositivo al canal de mesas del restaurante
  Future<void> subscribeToRestaurantTables({
    required String restaurantId,
    required String role,
  }) async {
    final sanitizedRestId = restaurantId.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_');
    final topic = 'restaurant_${sanitizedRestId}_tables';

    if (!kIsWeb) {
      try {
        await _fcm.subscribeToTopic(topic);
        await _fcm.subscribeToTopic('restaurant_${sanitizedRestId}_all');
        debugPrint('[FCM] Suscrito exitosamente al tópico: $topic');
      } catch (e) {
        debugPrint('[FCM Subscribe Error]: $e');
      }
    }

    // Registrar token en el backend para despacho directo o Web.
    // Se usa `registerThisDevice` (y no el registro directo) para que el
    // restaurante quede memorizado y los re-registros posteriores no lo pierdan.
    await registerThisDevice(restaurantId: restaurantId, role: role);
  }

  /// Suscribe el dispositivo al canal de cocina (KDS)
  Future<void> subscribeToRestaurantKitchen({
    required String restaurantId,
  }) async {
    final sanitizedRestId = restaurantId.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_');
    final topic = 'restaurant_${sanitizedRestId}_kitchen';

    if (!kIsWeb) {
      try {
        await _fcm.subscribeToTopic(topic);
        await _fcm.subscribeToTopic('restaurant_${sanitizedRestId}_all');
        debugPrint('[FCM] Suscrito exitosamente a cocina: $topic');
      } catch (e) {
        debugPrint('[FCM Kitchen Subscribe Error]: $e');
      }
    }

    await _registerDeviceWithBackend(restaurantId: restaurantId, role: 'kitchen');
  }

  /// Suscribe el dispositivo al canal de meseros / administración
  Future<void> subscribeToRestaurantWaiters({
    required String restaurantId,
  }) async {
    final sanitizedRestId = restaurantId.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_');
    final topic = 'restaurant_${sanitizedRestId}_waiters';

    if (!kIsWeb) {
      try {
        await _fcm.subscribeToTopic(topic);
        await _fcm.subscribeToTopic('restaurant_${sanitizedRestId}_all');
        debugPrint('[FCM] Suscrito exitosamente a meseros: $topic');
      } catch (e) {
        debugPrint('[FCM Waiters Subscribe Error]: $e');
      }
    }

    await _registerDeviceWithBackend(restaurantId: restaurantId, role: 'waiter');
  }

  /// Registra este dispositivo en el backend para poder recibir push.
  ///
  /// El endpoint `register-device` exige un token de Firebase válido, así que
  /// solo funciona con sesión iniciada. Se llama:
  ///   - al detectar una sesión (ver `initialize`),
  ///   - tras iniciar sesión, con el restaurante y el rol definitivos,
  ///   - y cada pocos minutos, para re-registrarse si el backend se reinició
  ///     (los tokens se guardan en el servidor y se pierden al reiniciar).
  Future<void> registerThisDevice({
    String? restaurantId,
    String role = 'waiter',
    String? deviceLabel,
  }) async {
    final backendRole = backendRoleFor(role);

    // Recordar el último restaurante/rol conocido: los re-registros
    // posteriores deben llevar siempre el restaurante real.
    if (restaurantId != null && restaurantId.isNotEmpty) {
      _knownRestaurantId = restaurantId;
    }
    _knownRole = backendRole;

    await _registerDeviceWithBackend(
      restaurantId: _knownRestaurantId ?? '',
      role: _knownRole!,
      deviceLabel: deviceLabel,
    );
    _ensureReregisterTimer();
  }

  /// Re-registra el dispositivo cada 5 minutos.
  ///
  /// Los tokens viven en el backend y se pierden si el proceso se reinicia.
  /// Sin este refresco, un dispositivo que abrió la app antes de un reinicio
  /// del backend se quedaba sin push para siempre.
  void _ensureReregisterTimer() {
    if (_reregisterTimer != null) return;
    _reregisterTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      unawaited(registerThisDevice());
    });
  }

  Future<void> _registerDeviceWithBackend({
    required String restaurantId,
    required String role,
    String? deviceLabel,
  }) async {
    final token = _currentToken;
    if (token == null || token.isEmpty) {
      debugPrint('[FCM] Sin token FCM: no se puede registrar el dispositivo');
      return;
    }

    // Identificación del dispositivo: en la tabla PushDevice queda quién lo
    // tiene abierto, desde qué plataforma y cuándo se vio por última vez.
    final platform = currentPlatform;
    final label = deviceLabel ?? _defaultDeviceLabel(platform);

    String? lastError;
    for (final base in ApiConfig.candidates) {
      try {
        final resp = await ApiClient.post(
          '$base/api/orders/sync/register-device',
          body: {
            'token': token,
            'role': role,
            'restaurantId': restaurantId,
            'platform': platform,
            'deviceLabel': label,
          },
          timeout: const Duration(seconds: 5),
        ).timeout(const Duration(seconds: 5));

        if (resp.statusCode == 200) {
          debugPrint('[FCM] Dispositivo registrado exitosamente en backend ($role / ${restaurantId.isEmpty ? 'sin restaurante' : restaurantId} / $platform)');
          return;
        }
        lastError = 'HTTP ${resp.statusCode}: ${resp.body}';
        if (resp.statusCode == 401 || resp.statusCode == 403) {
          debugPrint('[FCM] El backend rechazó el registro por falta de sesión (HTTP ${resp.statusCode}). '
              'Se reintentará al iniciar sesión.');
          return;
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('[FCM] Registro falló contra $base: $e');
      }
    }
    debugPrint('[FCM] No se pudo registrar el dispositivo en ningún endpoint. Último error: $lastError');
  }

  /// Plataforma desde la que se registra el dispositivo.
  static String get currentPlatform {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return 'other';
    }
  }

  /// Etiqueta legible del dispositivo para el panel de notificaciones.
  static String _defaultDeviceLabel(String platform) {
    final nombre = switch (platform) {
      'web' => 'Navegador',
      'ios' => 'iOS',
      'android' => 'Android',
      _ => 'Dispositivo',
    };
    final email = FirebaseAuth.instance.currentUser?.email;
    return email == null ? nombre : '$nombre · $email';
  }
}
