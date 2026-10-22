import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/api_config.dart';
import '../../../core/services/api_client.dart';
import '../../order/models/dish_model.dart';
import '../../order/providers/order_cart_state.dart';
import '../../order/providers/restaurant_orders_manager.dart';
import '../../order/presentation/widgets/dish_detail_sheet.dart';
import '../../order/presentation/widgets/order_summary_sheet.dart';
import '../../order/presentation/widgets/active_order_sheet.dart';
import '../../admin/presentation/admin_floor_view.dart';
import '../../admin/presentation/super_admin_view.dart';
import '../../admin/presentation/restaurant_admin_dashboard_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../kitchen/presentation/kitchen_view.dart';
import '../../auth/presentation/login_page.dart';
import '../../../core/services/push_notification_service.dart';

class MenuCategoriesPage extends StatefulWidget {
  final String? restaurantId;
  final String userRole;

  const MenuCategoriesPage({
    super.key,
    this.restaurantId,
    this.userRole = 'waiter',
  });

  @override
  State<MenuCategoriesPage> createState() => _MenuCategoriesPageState();
}

class _MenuCategoriesPageState extends State<MenuCategoriesPage> {
  final OrderCartState _cart = OrderCartState(tableIdentifier: 'Mesa 4');
  String _selectedCategory = 'bebidas_default';
  late final PageController _pageController;
  int _currentPageIndex = 0;

  static const DishItem defaultFreeWater = DishItem(
    id: 'default_agua_gratis',
    categoryId: 'bebidas_default',
    name: 'Vaso de Agua (Gratis)',
    description: 'Vaso de agua purificada fresca de la casa.',
    price: 0.0,
    imageUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=600&q=80',
    isAvailable: true,
    availableExtras: [],
  );

  static const MenuCategory defaultBebidasCategory = MenuCategory(
    id: 'bebidas_default',
    name: 'Bebidas',
    imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=200&q=80',
    emoji: '🥤',
  );

  List<MenuCategory> _categories = [defaultBebidasCategory];
  List<DishItem> _allDishes = [defaultFreeWater];

  Timer? _autoPlayTimer;
  Timer? _syncTimer;
  Timer? _menuPollTimer;
  bool _isAutoPlayActive = true;
  String? _resolvedRestaurantId;
  bool _isFetchingMenu = false;

  /// Diagnóstico del último intento de sincronizar el menú con el servidor.
  ///
  /// Antes, si la API no respondía, el error se tragaba en un `catch (_) {}` y
  /// la app se quedaba con el catálogo de ejemplo (solo el agua gratis), sin
  /// avisar nada. Eso hacía imposible diagnosticar el caso más común: la app
  /// instalada en un dispositivo físico, donde `localhost` no es el servidor.
  String? _menuSyncError;
  bool _showingSampleMenu = true;

  // Handlers de push previos (el servicio es un singleton global)
  void Function(Map<String, dynamic> data)? _previousOnMenuUpdated;
  void Function(Map<String, dynamic>)? _previousOnNewOrder;
  void Function(Map<String, dynamic>)? _previousOnStaffCall;

  String get _currentCategoryName {
    final cat = _categories.firstWhere(
      (c) => c.id == _selectedCategory,
      orElse: () => _categories.isNotEmpty ? _categories.first : defaultBebidasCategory,
    );
    return cat.name;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    _startAutoPlay();
    _fetchLiveMenuFromCloudSql();

    // Listener Push en Primer Plano: Al recibir señal de menú actualizado o nueva comanda
    //
    // Los callbacks viven en un singleton global. Se guardan los anteriores para
    // restaurarlos al salir: si esta pantalla se apila sobre otra (el admin
    // abre el menú desde el dashboard), sobrescribir el handler dejaba a la
    // pantalla de abajo sin recibir push.
    _previousOnMenuUpdated = PushNotificationService().onMenuUpdated;
    _previousOnNewOrder = PushNotificationService().onNewOrder;
    _previousOnStaffCall = PushNotificationService().onStaffCall;

    PushNotificationService().onMenuUpdated = (data) {
      final accion = data['action']?.toString() ?? '';
      final tipo = data['targetType']?.toString() ?? '';
      final nombre = data['targetName']?.toString() ?? '';
      debugPrint('[FCM Foreground] Señal de menú actualizado ($accion $tipo: "$nombre"): Refrescando lista...');
      _fetchLiveMenuFromCloudSql();

      // Aviso visible: el mesero ve QUÉ desapareció del menú en vez de que el
      // platillo desaparezca en silencio de la lista.
      if (!mounted) return;
      if (accion == 'delete') {
        final queSeElimino = nombre.isNotEmpty
            ? (tipo == 'category' ? '"$nombre"' : '"$nombre"')
            : (tipo == 'category' ? 'una categoría' : 'un platillo');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se eliminó $queSeElimino del menú'),
            backgroundColor: const Color(0xFFE25822),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    };

    PushNotificationService().onNewOrder = (data) {
      debugPrint('[FCM Foreground] Nueva comanda detectada: Sincronizando órdenes...');
      RestaurantOrdersManager().fetchOrdersFromBackend();
    };

    // "Llamar Mesero" / "Pedir la Cuenta": hasta ahora este callback estaba
    // declarado en el servicio pero NUNCA se asignaba, así que el push llegaba
    // al dispositivo y la app lo descartaba en silencio.
    PushNotificationService().onStaffCall = (data) {
      final motivo = data['reason']?.toString() ?? 'call_waiter';
      debugPrint('[FCM Foreground] Llamado de personal ($motivo): sincronizando...');
      RestaurantOrdersManager().fetchOrdersFromBackend();
      if (!mounted) return;
      final texto = motivo == 'request_bill'
          ? '💵 Una mesa solicita la cuenta'
          : motivo == 'payment_receipt'
              ? '🧾 Una mesa envió su comprobante de pago'
              : '🔔 Una mesa está llamando al personal';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: const Color(0xFFE25822),
          behavior: SnackBarBehavior.floating,
        ),
      );
    };

    _setupPushSubscription();

    // Sincronizar comandas de inmediato con el backend y escuchar en tiempo real
    RestaurantOrdersManager().fetchOrdersFromBackend();

    // Solo sincronizamos comandas de la mesa cada 6s como respaldo (cero polling de menú completo)
    _syncTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      RestaurantOrdersManager().fetchOrdersFromBackend();
    });

    // Respaldo del push: el menú se refresca cada 60s mientras la app está
    // abierta. El push sigue siendo el mecanismo inmediato, pero FCM no
    // garantiza la entrega (y en web depende de la VAPID key), así que sin
    // este respaldo un mesero con la app abierta NO vería un producto nuevo
    // hasta que reiniciara la aplicación.
    _menuPollTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!mounted) return;
      _fetchLiveMenuFromCloudSql();
    });
  }

  Future<void> _setupPushSubscription() async {
    // El restaurante es OBLIGATORIO para que la push llegue: el backend
    // filtra los dispositivos por `restaurantId` y suscribe el token al tópico
    // del restaurante. Antes, cuando el perfil no se podía resolver, se usaba
    // el literal 'restaurant_vianey_001': el dispositivo se registraba con un
    // restaurante inventado y la push del restaurante real nunca le llegaba.
    final restId = _resolvedRestaurantId ?? (widget.restaurantId ?? '');
    if (restId.isEmpty) {
      debugPrint('[FCM] Todavía no hay restaurantId: se registrará el dispositivo en cuanto se resuelva.');
      return;
    }
    await PushNotificationService().subscribeToRestaurantTables(
      restaurantId: restId,
      role: widget.userRole,
    );
  }

  Future<void> _fetchLiveMenuFromCloudSql() async {
    if (_isFetchingMenu) return;
    _isFetchingMenu = true;

    try {
      String restId = _resolvedRestaurantId ?? widget.restaurantId ?? '';

      // Si no se proporcionó restaurantId, resolverlo desde el perfil de Firebase Auth solo si no lo tenemos aún
      if (restId.isEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          for (final base in ApiConfig.candidates) {
            try {
              final resp = await ApiClient.get(
                '$base/api/auth/profile/${user.uid}',
                timeout: const Duration(seconds: 3),
              );
              if (resp.statusCode == 200) {
                final data = jsonDecode(resp.body);
                if (data['restaurantId'] != null && data['restaurantId'].toString().isNotEmpty) {
                  restId = data['restaurantId'].toString();
                  _resolvedRestaurantId = restId;
                  // Ya hay restaurante: el dispositivo puede registrarse en el
                  // backend y quedar suscrito al tópico de push correcto.
                  unawaited(_setupPushSubscription());
                  break;
                }
              }
            } catch (_) {}
          }
        }
      }

      if (restId.isEmpty) {
        restId = 'default-restaurant';
      }

      // Se registra el último error real para poder mostrarlo en pantalla.
      final List<String> fallos = <String>[];
      bool menuLoaded = false;

      for (final base in ApiConfig.candidates) {
        try {
          final resp = await ApiClient.get(
            '$base/api/menu/restaurant/$restId',
            timeout: const Duration(seconds: 3),
          );
          debugPrint('[MENU-FETCH] $base -> HTTP ${resp.statusCode} (${resp.body.length} bytes) restId=$restId');
          if (resp.statusCode == 200) {            final body = jsonDecode(resp.body);
            if (body['success'] == true && body['data'] != null) {
              final rawCategories = body['data']['menuCategories'] as List? ?? [];
              if (rawCategories.isNotEmpty) {
                final List<MenuCategory> loadedCategories = [];
                final List<DishItem> loadedDishes = [];

                String bebidasCatId = '';

                for (final catJson in rawCategories) {
                  final cat = MenuCategory.fromDataConnect(catJson as Map<String, dynamic>);
                  loadedCategories.add(cat);

                  final lower = cat.name.toLowerCase();
                  if (bebidasCatId.isEmpty && (lower.contains('bebida') || lower.contains('refresco') || lower.contains('agua'))) {
                    bebidasCatId = cat.id;
                  }

                  final rawItems = catJson['menuItems_on_category'] as List? ?? [];
                  for (final itemJson in rawItems) {
                    final dish = DishItem.fromDataConnect(itemJson as Map<String, dynamic>, categoryId: cat.id);
                    if (dish.isAvailable) {
                      loadedDishes.add(dish);
                    }
                  }
                }

                // Si el restaurante aún no tiene categoría de bebidas, agregamos Bebidas
                if (bebidasCatId.isEmpty) {
                  loadedCategories.add(defaultBebidasCategory);
                  bebidasCatId = defaultBebidasCategory.id;
                }

                // Agregamos el permanente "Vaso de Agua (Gratis $0.00)" a la categoría de bebidas
                loadedDishes.add(
                  DishItem(
                    id: 'default_agua_gratis',
                    categoryId: bebidasCatId,
                    name: 'Vaso de Agua (Gratis)',
                    description: 'Vaso de agua purificada fresca de la casa.',
                    price: 0.0,
                    imageUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=600&q=80',
                    isAvailable: true,
                    availableExtras: [],
                  ),
                );

                if (mounted) {
                  // Detección reactiva de cambios: si se eliminó, pausó o editó algún platillo
                  final bool hasCategoryChanges = loadedCategories.length != _categories.length ||
                      loadedCategories.any((newCat) => !_categories.any((oldCat) => oldCat.id == newCat.id && oldCat.name == newCat.name));
                  final bool hasDishChanges = loadedDishes.length != _allDishes.length ||
                      loadedDishes.any((newDish) => !_allDishes.any((oldDish) =>
                          oldDish.id == newDish.id &&
                          oldDish.isAvailable == newDish.isAvailable &&
                          oldDish.price == newDish.price &&
                          oldDish.name == newDish.name &&
                          oldDish.categoryId == newDish.categoryId));

                  if (hasCategoryChanges || hasDishChanges) {
                    setState(() {
                      _categories = loadedCategories;
                      _allDishes = loadedDishes;
                      if (!_categories.any((c) => c.id == _selectedCategory)) {
                        _selectedCategory = _categories.isNotEmpty ? _categories.first.id : defaultBebidasCategory.id;
                      }
                      final currentFiltered = _filteredDishes;
                      if (_currentPageIndex >= currentFiltered.length) {
                        _currentPageIndex = (currentFiltered.length - 1).clamp(0, currentFiltered.length);
                        if (_pageController.hasClients && currentFiltered.isNotEmpty) {
                          _pageController.jumpToPage(_currentPageIndex);
                        }
                      }
                    });
                  }
                  menuLoaded = true;
                  break;
                }
              }
            } else {
              // La API respondió, pero no con un menú válido. Se registra el
              // motivo real: un 500 aquí significa casi siempre que el
              // restaurantId no es un UUID (por ejemplo, que se pasó el UID de
              // Firebase en lugar del identificador del restaurante).
              fallos.add('$base → HTTP ${resp.statusCode}: ${_extractApiError(resp.body)}');
            }
          }
        } catch (e) {
          fallos.add('$base → $e');
          debugPrint('[MENU-FETCH] EXCEPCION en $base → $e');
        }
      }

      debugPrint('[MENU-FETCH] menuLoaded=$menuLoaded fallos=$fallos');
      if (mounted) {
        setState(() {
          if (menuLoaded) {
            _menuSyncError = null;
            _showingSampleMenu = false;
          } else {
            _showingSampleMenu = true;
            _menuSyncError = fallos.isEmpty
                ? 'El servidor respondió sin un menú válido para este restaurante.'
                : 'No se pudo alcanzar la API.\n${fallos.join('\n')}';
          }
        });
      }
    } finally {
      _isFetchingMenu = false;
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isAutoPlayActive || !mounted || !_pageController.hasClients) return;
      final dishes = _filteredDishes;
      if (dishes.isEmpty) return;

      int nextIndex = _currentPageIndex + 1;
      if (nextIndex >= dishes.length) {
        nextIndex = 0;
      }

      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _pauseAutoPlayTemporarily() {
    _isAutoPlayActive = false;
    _autoPlayTimer?.cancel();
    // Reanudar suavemente tras 8 segundos de inactividad del usuario
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        _isAutoPlayActive = true;
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    // Se restauran los handlers previos en lugar de ponerlos a null: si esta
    // pantalla estaba apilada sobre otra, dejarlos a null hacía que la de abajo
    // dejara de recibir push para el resto de su vida.
    PushNotificationService().onMenuUpdated = _previousOnMenuUpdated;
    PushNotificationService().onNewOrder = _previousOnNewOrder;
    PushNotificationService().onStaffCall = _previousOnStaffCall;
    _autoPlayTimer?.cancel();
    _syncTimer?.cancel();
    _menuPollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<DishItem> get _filteredDishes =>
      _allDishes.where((dish) => dish.categoryId == _selectedCategory).toList();

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _currentPageIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    _startAutoPlay();
  }

  void _previousDish() {
    _pauseAutoPlayTemporarily();
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _nextDish() {
    _pauseAutoPlayTemporarily();
    if (_currentPageIndex < _filteredDishes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _openDishDetail(DishItem dish) async {
    _pauseAutoPlayTemporarily();

    // 1. Si es el agua de cortesía de la casa, siempre está disponible
    if (dish.id != 'default_agua_gratis') {
      // 2. Consulta en tiempo real a Cloud SQL si el producto aún existe o sigue disponible
      final check = await _checkDishAvailability(dish.id);
      if (!check.isAvailable) {
        _removeDishFromLocalMenu(dish);
        _showDishUnavailableDialog(dish.name, reason: check.message);
        return;
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (context) => DishDetailSheet(
        dish: dish,
        onConfirm: (extras, notes) async {
          // Doble verificación rápida al confirmar pedido antes de agregar a comanda
          if (dish.id != 'default_agua_gratis') {
            final recheck = await _checkDishAvailability(dish.id);
            if (!recheck.isAvailable) {
              _removeDishFromLocalMenu(dish);
              _showDishUnavailableDialog(dish.name, reason: recheck.message);
              return;
            }
          }
          _cart.addDish(dish, extras: extras, notes: notes);
          _showFeedbackBadge(dish.name);
        },
      ),
    );
  }

  Future<({bool isAvailable, String message})> _checkDishAvailability(String dishId) async {
    for (final base in ApiConfig.candidates) {
      try {
        final resp = await ApiClient.get(
          '$base/api/menu/item/$dishId',
          timeout: const Duration(seconds: 3),
        );
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          // El backend responde 200 incluso ante un error interno de Data Connect
          // (campo `error` presente). Ese caso NO significa que el producto haya
          // desaparecido: si lo tratáramos como "no existe", un fallo transitorio
          // borraría el platillo del menú del comensal.
          if (data['error'] != null || data['success'] == false) {
            continue; // error del servidor: seguimos con el siguiente endpoint
          }
          final bool exists = data['exists'] != false;
          final bool available = data['available'] == true;
          final String msg = data['message']?.toString() ?? (exists ? 'Producto agotado' : 'El producto ya no existe en el menú');

          if (!exists || !available) {
            return (isAvailable: false, message: msg);
          }
          return (isAvailable: true, message: 'Disponible');
        } else if (resp.statusCode == 404) {
          return (isAvailable: false, message: 'El producto ya no existe en el menú');
        }
      } catch (_) {}
    }
    // En caso de fallo de red temporal, no bloquear la interfaz
    return (isAvailable: true, message: 'Disponible');
  }

  void _removeDishFromLocalMenu(DishItem dish) {
    if (!mounted) return;
    setState(() {
      _allDishes.removeWhere((d) => d.id == dish.id);
      final currentFiltered = _filteredDishes;
      if (_currentPageIndex >= currentFiltered.length) {
        _currentPageIndex = (currentFiltered.length - 1).clamp(0, currentFiltered.length);
        if (_pageController.hasClients && currentFiltered.isNotEmpty) {
          _pageController.jumpToPage(_currentPageIndex);
        }
      }
    });
  }

  void _showDishUnavailableDialog(String dishName, {String? reason}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2228),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE25822), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFE25822), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Disculpe el Inconveniente',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El producto "$dishName" ya no se encuentra disponible en nuestro menú.',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hemos actualizado la carta de la mesa automáticamente para que no vuelva a aparecer. Por favor, seleccione alguna otra de nuestras opciones.',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE25822),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Ver otras opciones',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _openOrderSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (context) => OrderSummarySheet(cart: _cart),
    );
  }

  void _openActiveOrderSheet([RestaurantOrder? order]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (context) => ActiveOrderSheet(
        order: order,
        tableIdentifier: _cart.tableIdentifier,
      ),
    );
  }

  Future<void> _callStaffQuickly() async {
    final ok = await RestaurantOrdersManager().callStaff(_cart.tableIdentifier, reason: 'call_waiter');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '¡Llamada enviada! Un mesero se dirige a ${_cart.tableIdentifier} 🛎️' : 'Llamada registrada.'),
          backgroundColor: const Color(0xFFE25822),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.sent:
        return 'Pendiente de confirmación';
      case OrderStatus.confirmed:
        return 'En cola de cocina';
      case OrderStatus.cooking:
        return 'El chef preparando';
      case OrderStatus.ready:
        return 'Platillos listos en camino';
      case OrderStatus.delivered:
        return 'Servido en mesa';
      case OrderStatus.paid:
        return 'Pagado';
    }
  }

  void _showFeedbackBadge(String dishName) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Agregado a la comanda: $dishName',
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E2228),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE25822), width: 1),
        ),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  Future<void> _handleCerrarTurno() async {
    // 1. Validar si hay platillos en el carrito pendientes de enviar
    if (_cart.items.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E2228),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.block, color: Colors.redAccent, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Comanda sin enviar',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Text(
            'No se puede cerrar turno: La mesa ${_cart.tableIdentifier} tiene platillos en el carrito pendientes de confirmar o enviar a cocina.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE25822),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text('Entendido', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Validar si hay pedidos activos pendientes de cobrar en esta mesa
    final activeOrders = RestaurantOrdersManager().getActiveOrdersForTable(_cart.tableIdentifier);
    if (activeOrders.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E2228),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.amber, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cuentas Pendientes de Cobro',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Text(
            'No se puede cerrar turno: Hay ${activeOrders.length} pedido(s) activo(s) en ${_cart.tableIdentifier} sin pagar.\n\nEl comensal debe liquidar la cuenta y el personal debe marcar los pedidos como pagados antes de cerrar turno.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE25822),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text('Entendido', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    // 3. Confirmación obligatoria con contraseña
    final passwordController = TextEditingController();
    bool isVerifying = false;
    String? errorMessage;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E2228),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF2D323A)),
              ),
              title: Row(
                children: [
                  const Icon(Icons.lock_outline, color: Color(0xFFE25822), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Confirmar Cierre de Turno',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Para evitar que los comensales salgan de la pantalla de la mesa, ingrese su contraseña de personal autorizado para cerrar sesión:',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    autofocus: true,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Contraseña de mesero / admin',
                      hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF131518),
                      prefixIcon: const Icon(Icons.key, color: Color(0xFFE25822), size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2D323A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2D323A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE25822)),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () => Navigator.pop(dialogCtx),
                  child: Text('Cancelar', style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE25822),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isVerifying
                      ? null
                      : () async {
                          final password = passwordController.text.trim();
                          if (password.isEmpty) {
                            setDialogState(() {
                              errorMessage = 'Ingrese la contraseña';
                            });
                            return;
                          }

                          setDialogState(() {
                            isVerifying = true;
                            errorMessage = null;
                          });

                          final rootNav = Navigator.of(context);
                          final dialogNav = Navigator.of(dialogCtx);

                          try {
                            final currentUser = FirebaseAuth.instance.currentUser;
                            if (currentUser != null && currentUser.email != null) {
                              final credential = EmailAuthProvider.credential(
                                email: currentUser.email!,
                                password: password,
                              );
                              await currentUser.reauthenticateWithCredential(credential);

                              dialogNav.pop();
                              await FirebaseAuth.instance.signOut();
                              rootNav.pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                                (route) => false,
                              );
                            } else {
                              dialogNav.pop();
                              rootNav.pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              isVerifying = false;
                              errorMessage = 'Contraseña incorrecta. Solo personal autorizado.';
                            });
                          }
                        },
                  child: isVerifying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Cerrar Turno', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Extrae el mensaje de error de una respuesta de la API para mostrarlo
  /// en el aviso de falta de conexión, en lugar de un HTTP 500 seco.
  String _extractApiError(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
    } catch (_) {}
    return body.length > 160 ? '${body.substring(0, 160)}…' : body;
  }

  /// Diálogo de desarrollo que simula la llegada de los tres tipos de push
  /// que envía el backend. Permite comprobar la reacción de la app (refresco
  /// del menú, aviso de llamada, sincronización de órdenes) sin depender de un
  /// dispositivo físico ni de la entrega real de FCM.
  void _showPushTestDialog() {
    showDialog<void>(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: const Color(0xFF1E2228),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Simular push',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pushTestTile(d, '🍽️  Menú actualizado', 'menu_updated'),
            _pushTestTile(d, '🔔  Llamado de personal', 'staff_call'),
            _pushTestTile(d, '📋  Nueva comanda', 'new_order'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: Text('Cerrar', style: GoogleFonts.plusJakartaSans(color: Colors.white60)),
          ),
        ],
      ),
    );
  }

  Widget _pushTestTile(BuildContext d, String etiqueta, String tipo) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(etiqueta, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14)),
      trailing: const Icon(Icons.play_arrow, color: Color(0xFFF59E0B), size: 20),
      onTap: () {
        Navigator.pop(d);
        // Se dispara exactamente el mismo callback que activaría el push real.
        switch (tipo) {
          case 'menu_updated':
            PushNotificationService().onMenuUpdated?.call({
              'type': 'menu_updated',
              'action': 'add',
              'targetType': 'item',
              'targetName': 'Platillo de prueba',
            });
            break;
          case 'staff_call':
            PushNotificationService().onStaffCall?.call({
              'type': 'staff_call',
              'reason': 'call_waiter',
              'tableIdentifier': 'Mesa 4',
            });
            break;
          case 'new_order':
            PushNotificationService().onNewOrder?.call({
              'type': 'new_order',
              'orderId': 'ORD-SIMULADA',
              'tableIdentifier': 'Mesa 4',
            });
            break;
        }
      },
    );
  }

  /// Banner que se muestra cuando la API no responde.
  ///
  /// Es la diferencia entre "el restaurante no tiene productos" y "la app no
  /// pudo conectarse al servidor": sin este aviso, la app muestra el catálogo de
  /// ejemplo y el diagnóstico es imposible.
  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2A12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_off, color: Color(0xFFF59E0B), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sin conexión con el servidor — mostrando menú de ejemplo',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFCD34D),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _menuSyncError = null;
                  _fetchLiveMenuFromCloudSql();
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFCD34D),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'API probada en: ${ApiConfig.candidates.join("  ·  ")}',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'En un teléfono o tablet físico, "localhost" NO es el servidor.\n'
            'Compila con:  flutter run --dart-define=API_BASE_URL=http://<IP-DEL-SERVIDOR>:3000',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white54,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDishes = _filteredDishes;
    return Scaffold(
      backgroundColor: const Color(0xFF131518),
      body: SafeArea(
        child: Column(
          children: [
            // Aviso de falta de conexión con la API: sin esto, la app muestra
            // en silencio el catálogo de ejemplo y parece que "no hay productos".
            if (_menuSyncError != null) _buildOfflineBanner(),

            // Cabecera Superior: Mesa activa y Cápsula interactiva
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _menuSyncError == null
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _cart.tableIdentifier,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _menuSyncError != null
                            ? (_showingSampleMenu
                                ? 'Sin servidor · mostrando menú de ejemplo'
                                : 'Sin servidor · menú no disponible')
                            : 'Turno Activo • Comanda abierta',
                        style: GoogleFonts.plusJakartaSans(
                          color: _menuSyncError != null
                              ? const Color(0xFFF59E0B)
                              : Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // Cápsula Dinámica de Comanda y Pedido Activo
                      AnimatedBuilder(
                        animation: Listenable.merge([_cart, RestaurantOrdersManager()]),
                        builder: (context, _) {
                          final hasCartItems = _cart.items.isNotEmpty;
                          final manager = RestaurantOrdersManager();
                          final activeOrders = manager.getActiveOrdersForTable(_cart.tableIdentifier);
                          final tableTotal = manager.getTableTotal(_cart.tableIdentifier);

                          final String label;
                          final IconData icon;
                          final Color color;
                          final bool isHighlighted;

                          if (hasCartItems) {
                            label = '${_cart.totalItemCount} por enviar • \$${_cart.subtotal.toStringAsFixed(2)}';
                            icon = Icons.shopping_bag_outlined;
                            color = const Color(0xFFE25822);
                            isHighlighted = true;
                          } else if (activeOrders.isNotEmpty) {
                            label = activeOrders.length > 1
                                ? '${activeOrders.length} Pedidos • \$${tableTotal.toStringAsFixed(2)}'
                                : 'Pedido Activo • \$${tableTotal.toStringAsFixed(2)}';
                            icon = Icons.receipt_long;
                            color = const Color(0xFF10B981);
                            isHighlighted = true;
                          } else {
                            label = 'Sin pedido';
                            icon = Icons.receipt_long_outlined;
                            color = Colors.white54;
                            isHighlighted = false;
                          }

                          return InkWell(
                            onTap: () {
                              if (hasCartItems) {
                                _openOrderSummary();
                              } else if (activeOrders.isNotEmpty) {
                                _openActiveOrderSheet();
                              } else {
                                _showFeedbackBadge('Elige tus platillos favoritos del menú');
                              }
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isHighlighted ? color : const Color(0xFF1E2228),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isHighlighted ? color : const Color(0xFF2D323A),
                                ),
                                boxShadow: isHighlighted
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(icon, color: Colors.white, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    label,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),

                      // Selector Rápido de Roles (Admin / Cocina / Mesa)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white70),
                        color: const Color(0xFF1E2228),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFF2D323A)),
                        ),
                        onSelected: (role) {
                          if (role == 'admin') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminFloorView()),
                            );
                          } else if (role == 'kitchen') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const KitchenView()),
                            );
                          } else if (role == 'super_admin') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SuperAdminDashboardView()),
                            );
                          } else if (role == 'restaurant_admin') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RestaurantAdminDashboardView()),
                            );
                          } else if (role == 'logout') {
                            _handleCerrarTurno();
                          } else if (role == 'test_push') {
                            _showPushTestDialog();
                          }
                        },
                        itemBuilder: (context) {
                          final isWaiter = widget.userRole == 'waiter';
                          final isSuperAdmin = FirebaseAuth.instance.currentUser?.email?.toLowerCase().trim() == 'chebetoa7@gmail.com' || widget.userRole == 'super_admin';

                          final List<PopupMenuEntry<String>> items = [];

                          // Las mesas / meseros virtuales no tienen acceso a paneles administrativos ni monitores de cocina
                          if (!isWaiter) {
                            items.addAll([
                              PopupMenuItem(
                                value: 'restaurant_admin',
                                child: Row(
                                  children: [
                                    const Icon(Icons.storefront, color: Color(0xFFE25822), size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Panel Admin Restaurante',
                                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'admin',
                                child: Row(
                                  children: [
                                    const Icon(Icons.manage_accounts, color: Color(0xFF3B82F6), size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Ver Administrador de Piso',
                                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'kitchen',
                                child: Row(
                                  children: [
                                    const Icon(Icons.soup_kitchen, color: Color(0xFF10B981), size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Ver Monitor de Cocina (Chef)',
                                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ]);

                            if (isSuperAdmin) {
                              items.add(
                                PopupMenuItem(
                                  value: 'super_admin',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.shield, color: Colors.amber, size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Super Admin (SaaS Global)',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            items.add(const PopupMenuDivider());
                          }

                          items.add(
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Cerrar Turno / Salir',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );

                          // Herramienta de desarrollo: simula la llegada de un push
                          // para comprobar la reacción de la app sin depender de un
                          // dispositivo real ni de la entrega real de FCM.
                          if (kDebugMode) {
                            items.add(
                              PopupMenuItem(
                                value: 'test_push',
                                child: Row(
                                  children: [
                                    const Icon(Icons.notifications_active, color: Color(0xFFF59E0B), size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Probar push (simular)',
                                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return items;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Banner en Tiempo Real del Estatus de la Comanda
            AnimatedBuilder(
              animation: RestaurantOrdersManager(),
              builder: (context, _) {
                final manager = RestaurantOrdersManager();
                final activeOrders = manager.getActiveOrdersForTable(_cart.tableIdentifier);

                if (activeOrders.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2228),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF2D323A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.table_restaurant, color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mesa lista • Ordena desde tu pantalla o solicita mesero',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                        InkWell(
                          onTap: _callStaffQuickly,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE25822).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE25822).withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.notifications_active_outlined, color: Color(0xFFE25822), size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  'Llamar Mesero',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFE25822),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final tableTotal = manager.getTableTotal(_cart.tableIdentifier);
                final consolidatedStatus = manager.getTableConsolidatedStatus(_cart.tableIdentifier);
                final isMultiple = activeOrders.length > 1;

                Color badgeColor;
                IconData badgeIcon;

                switch (consolidatedStatus) {
                  case OrderStatus.sent:
                    badgeColor = Colors.amber;
                    badgeIcon = Icons.send_rounded;
                    break;
                  case OrderStatus.confirmed:
                    badgeColor = const Color(0xFFE25822);
                    badgeIcon = Icons.hourglass_top_rounded;
                    break;
                  case OrderStatus.cooking:
                    badgeColor = Colors.orangeAccent;
                    badgeIcon = Icons.soup_kitchen;
                    break;
                  case OrderStatus.ready:
                    badgeColor = const Color(0xFF10B981);
                    badgeIcon = Icons.check_circle_rounded;
                    break;
                  case OrderStatus.delivered:
                    badgeColor = const Color(0xFF38BDF8);
                    badgeIcon = Icons.done_all_rounded;
                    break;
                  case OrderStatus.paid:
                    badgeColor = const Color(0xFF10B981);
                    badgeIcon = Icons.task_alt_rounded;
                    break;
                }

                final statusSubtitle = isMultiple
                    ? '${activeOrders.length} rondas acumuladas • ${_getStatusLabel(consolidatedStatus)}'
                    : activeOrders.first.statusLabel;

                return InkWell(
                  onTap: () => _openActiveOrderSheet(),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2228),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: badgeColor.withOpacity(0.6), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: badgeColor.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(badgeIcon, color: badgeColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isMultiple
                                        ? '${activeOrders.length} PEDIDOS ACTIVOS'
                                        : 'PEDIDO ACTIVO • ${activeOrders.first.id}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: badgeColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(\$${tableTotal.toStringAsFixed(2)})',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                statusSubtitle,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.receipt_long, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Ver Cuenta',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Selector horizontal de Categorías con miniatura fotográfica y nombre
            SizedBox(
              height: 50,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat.id == _selectedCategory;
                  return InkWell(
                    onTap: () => _onCategorySelected(cat.id),
                    borderRadius: BorderRadius.circular(25),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.fromLTRB(5, 5, 14, 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE25822).withOpacity(0.18)
                            : const Color(0xFF1E2228),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFE25822) : const Color(0xFF2D323A),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFE25822).withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Miniatura circular del platillo/categoría
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFFE25822) : Colors.white24,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                cat.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    cat.emoji ?? '🍽️',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Nombre de la Categoría
                          Text(
                            cat.name,
                            style: GoogleFonts.plusJakartaSans(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Indicador de Platillo en Categoría
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2228),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2D323A)),
                    ),
                    child: Text(
                      '${_currentCategoryName.toUpperCase()}  •  ${currentDishes.isEmpty ? 0 : _currentPageIndex + 1} de ${currentDishes.length}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Vista 3D de Platillos con Botones Circulares Flotantes a los Extremos
            Expanded(
              child: currentDishes.isEmpty
                  ? Center(
                      child: Text(
                        'No hay platillos en esta categoría.',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white38),
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: currentDishes.length,
                          onPageChanged: (index) {
                            setState(() => _currentPageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            final dish = currentDishes[index];
                            return Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 440),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  child: _buildDish3DPlateView(dish),
                                ),
                              ),
                            );
                          },
                        ),

                        // Botón Circular Flotante: Izquierda Centro
                        Positioned(
                          left: 8,
                          child: _buildCircularFloatingNavButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: _previousDish,
                            enabled: _currentPageIndex > 0,
                          ),
                        ),

                        // Botón Circular Flotante: Derecha Centro
                        Positioned(
                          right: 8,
                          child: _buildCircularFloatingNavButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: _nextDish,
                            enabled: _currentPageIndex < currentDishes.length - 1,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 75), // Espacio para la comanda inferior
          ],
        ),
      ),

      // Barra Inferior de Acción Rápida (Sticky Bar de la Comanda)
      bottomSheet: AnimatedBuilder(
        animation: _cart,
        builder: (context, _) {
          if (_cart.items.isEmpty) return const SizedBox.shrink();
          return Container(
            color: const Color(0xFF131518),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: InkWell(
              onTap: _openOrderSummary,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE25822),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE25822).withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_cart.totalItemCount}',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Ver Comanda de la Mesa',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${_cart.subtotal.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircularFloatingNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled ? const Color(0xFF1E2228).withOpacity(0.92) : const Color(0xFF1E2228).withOpacity(0.4),
            border: Border.all(
              color: enabled ? const Color(0xFF2D323A) : Colors.white10,
              width: 1.5,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.white24,
            size: 26,
          ),
        ),
      ),
    );
  }

  // Vista 3D: Plato circular flotante sin encuadre rígido, optimizado para tablets y móviles
  Widget _buildDish3DPlateView(DishItem dish) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // En móviles y tabletas fijamos un diámetro de plato contenido y elegante (140px a 195px)
        final plateSize = (constraints.maxWidth * 0.46).clamp(140.0, 195.0);

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            // Pedestal / Tarjeta de información inferior con curvatura orgánica
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: plateSize * 0.45,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2228),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF2D323A), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: plateSize * 0.45), // Espacio para el plato que desborda
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Nombre del Platillo
                              Text(
                                dish.name,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Descripción breve
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  dish.description,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white60,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Precio destacado
                              Text(
                                '\$${dish.price.toStringAsFixed(2)}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFE25822),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Botón "Personalizar e Ingredientes" (Pide extras de inmediato)
                    ElevatedButton(
                      onPressed: () => _openDishDetail(dish),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE25822),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                        shadowColor: const Color(0xFFE25822).withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.tune_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Ingredientes & Extras',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Plato 3D Flotante con sombra profunda cenital
            Positioned(
              top: 4,
              child: Hero(
                tag: 'dish_${dish.id}',
                child: Container(
                  width: plateSize,
                  height: plateSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      // Sombra 3D profunda que da la ilusión de estar suspendido sobre la tarjeta
                      BoxShadow(
                        color: Colors.black.withOpacity(0.65),
                        blurRadius: 28,
                        spreadRadius: 2,
                        offset: const Offset(0, 16),
                      ),
                      // Resplandor gastronómico sutil
                      BoxShadow(
                        color: const Color(0xFFE25822).withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      dish.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1E2228),
                        child: const Icon(Icons.restaurant, color: Color(0xFFE25822), size: 48),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
