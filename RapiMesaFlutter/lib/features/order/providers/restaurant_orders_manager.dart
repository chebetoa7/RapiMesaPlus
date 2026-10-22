import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../core/config/api_config.dart';
import '../../../core/services/api_client.dart';
import '../models/dish_model.dart';

enum OrderStatus {
  sent,       // Enviado por mesa / comensal
  confirmed,  // Confirmado por admin de piso / recepción
  cooking,    // Chef comenzó preparación
  ready,      // Listo en barra/cocina para llevar a mesa
  delivered,  // Servido en mesa
  paid,       // Pagado y mesa liberada (archivado para corte de caja)
}

enum OrderType {
  table,        // Mesa física
  walkInBar,    // Barra / Mostrador
  phoneTakeout, // Pedido por teléfono / Para llevar
}

enum WaiterOrigin {
  virtualTable,   // Pedido generado por comensal en la Tablet fija de mesa
  physicalWaiter,  // Pedido levantado por mesero físico con dispositivo en mano
}

class RestaurantBankingInfo {
  final String bankName;
  final String accountHolder;
  final String clabe;
  final String notes;
  final DateTime? updatedAt;

  RestaurantBankingInfo({
    required this.bankName,
    required this.accountHolder,
    required this.clabe,
    this.notes = 'Concepto: Número de mesa o tu nombre',
    this.updatedAt,
  });

  factory RestaurantBankingInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantBankingInfo(
      bankName: json['bankName']?.toString() ?? 'BBVA México',
      accountHolder: json['accountHolder']?.toString() ?? 'Restaurante',
      clabe: json['clabe']?.toString() ?? '',
      notes: json['notes']?.toString() ?? 'Concepto: Número de mesa',
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountHolder': accountHolder,
      'clabe': clabe,
      'notes': notes,
    };
  }
}

class StaffCall {
  final String id;
  final String tableIdentifier;
  final String reason; // 'call_waiter' | 'request_bill' | 'payment_receipt'
  final String? customerName;
  final String? paymentPreference; // 'cash' | 'terminal' | 'transfer'
  final String? receiptImage; // base64 string
  final double? amountToPay;
  final String? restaurantId;
  final String? notes;
  final DateTime createdAt;
  bool isResolved;

  StaffCall({
    required this.id,
    required this.tableIdentifier,
    required this.reason,
    this.customerName,
    this.paymentPreference,
    this.receiptImage,
    this.amountToPay,
    this.restaurantId,
    this.notes,
    required this.createdAt,
    this.isResolved = false,
  });

  factory StaffCall.fromJson(Map<String, dynamic> json) {
    return StaffCall(
      id: json['id']?.toString() ?? '',
      tableIdentifier: json['tableIdentifier']?.toString() ?? '',
      reason: json['reason']?.toString() ?? 'call_waiter',
      customerName: json['customerName']?.toString(),
      paymentPreference: json['paymentPreference']?.toString(),
      receiptImage: json['receiptImage']?.toString(),
      amountToPay: (json['amountToPay'] as num?)?.toDouble(),
      restaurantId: json['restaurantId']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt']) ?? DateTime.now()
          : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now()),
      isResolved: json['isResolved'] == true,
    );
  }
}

class RestaurantOrder {
  final String id;
  final String tableIdentifier;
  final OrderType orderType;
  final WaiterOrigin waiterOrigin;
  final String? waiterName;
  final String? customerName;
  final String? customerPhone;
  final List<OrderCartLine> items;
  final double subtotal;
  final double tipAmount;
  final double totalAmount;
  final DateTime createdAt;
  DateTime? confirmedAt;
  DateTime? cookingStartedAt;
  DateTime? readyAt;
  DateTime? paidAt;
  String? paymentMethod;
  double? amountPaid;
  OrderStatus status;

  RestaurantOrder({
    required this.id,
    required this.tableIdentifier,
    this.orderType = OrderType.table,
    this.waiterOrigin = WaiterOrigin.virtualTable,
    this.waiterName,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.tipAmount,
    required this.totalAmount,
    required this.createdAt,
    this.confirmedAt,
    this.cookingStartedAt,
    this.readyAt,
    this.paidAt,
    this.paymentMethod,
    this.amountPaid,
    this.status = OrderStatus.sent,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableIdentifier': tableIdentifier,
      'orderType': orderType.name,
      'waiterOrigin': waiterOrigin.name,
      'waiterName': waiterName,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((line) => {
        'dishId': line.dish.id,
        'dishName': line.dish.name,
        'dishPrice': line.dish.price,
        'dishImage': line.dish.imageUrl,
        'quantity': line.quantity,
        'kitchenNotes': line.kitchenNotes,
        'extras': line.selectedExtras.map((e) => {
          'id': e.id,
          'name': e.name,
          'extraPrice': e.extraPrice,
        }).toList(),
      }).toList(),
      'subtotal': subtotal,
      'tipAmount': tipAmount,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'cookingStartedAt': cookingStartedAt?.toIso8601String(),
      'readyAt': readyAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'amountPaid': amountPaid,
      'status': status.name,
    };
  }

  factory RestaurantOrder.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>? ?? []).map((item) {
      final extras = (item['extras'] as List<dynamic>? ?? []).map((e) {
        return ExtraIngredient(
          id: e['id']?.toString() ?? '',
          name: e['name']?.toString() ?? '',
          extraPrice: (e['extraPrice'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      final dish = DishItem(
        id: item['dishId']?.toString() ?? '',
        name: item['dishName']?.toString() ?? 'Platillo',
        description: '',
        price: (item['dishPrice'] as num?)?.toDouble() ?? 0.0,
        categoryId: '',
        imageUrl: item['dishImage']?.toString() ?? '',
      );

      return OrderCartLine(
        dish: dish,
        quantity: (item['quantity'] as num?)?.toInt() ?? 1,
        selectedExtras: extras,
        kitchenNotes: item['kitchenNotes']?.toString() ?? '',
      );
    }).toList();

    OrderStatus parseStatus(String? s) {
      return OrderStatus.values.firstWhere(
        (e) => e.name == s,
        orElse: () => OrderStatus.sent,
      );
    }

    OrderType parseType(String? t) {
      return OrderType.values.firstWhere(
        (e) => e.name == t,
        orElse: () => OrderType.table,
      );
    }

    WaiterOrigin parseOrigin(String? o) {
      return WaiterOrigin.values.firstWhere(
        (e) => e.name == o,
        orElse: () => WaiterOrigin.virtualTable,
      );
    }

    return RestaurantOrder(
      id: json['id']?.toString() ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      tableIdentifier: json['tableIdentifier']?.toString() ?? 'Mesa',
      orderType: parseType(json['orderType']?.toString()),
      waiterOrigin: parseOrigin(json['waiterOrigin']?.toString()),
      waiterName: json['waiterName']?.toString(),
      customerName: json['customerName']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      items: itemsList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tipAmount: (json['tipAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      confirmedAt: json['confirmedAt'] != null ? DateTime.tryParse(json['confirmedAt']) : null,
      cookingStartedAt: json['cookingStartedAt'] != null ? DateTime.tryParse(json['cookingStartedAt']) : null,
      readyAt: json['readyAt'] != null ? DateTime.tryParse(json['readyAt']) : null,
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
      paymentMethod: json['paymentMethod']?.toString(),
      amountPaid: (json['amountPaid'] as num?)?.toDouble(),
      status: parseStatus(json['status']?.toString()),
    );
  }

  String get orderTypeLabel {
    switch (orderType) {
      case OrderType.table:
        return tableIdentifier;
      case OrderType.walkInBar:
        return 'BARRA / MOSTRADOR';
      case OrderType.phoneTakeout:
        return 'PARA LLEVAR / TEL';
    }
  }

  String get deliveryInstruction {
    if (orderType == OrderType.walkInBar) {
      return 'Entregar en Barra a ${customerName ?? "Cliente"}';
    } else if (orderType == OrderType.phoneTakeout) {
      return 'Entregar en Mostrador a ${customerName ?? "Cliente"}';
    } else if (waiterOrigin == WaiterOrigin.physicalWaiter) {
      return 'Mesero asignado (${waiterName ?? "Mesero en turno"}) va por el platillo a cocina';
    } else {
      return '¡Mesa Virtual! El Administrador / Capitán de piso debe llevar el platillo a $tableIdentifier';
    }
  }

  int get elapsedMinutes => DateTime.now().difference(createdAt).inMinutes;

  String get statusLabel {
    switch (status) {
      case OrderStatus.sent:
        return 'Pendiente de confirmación';
      case OrderStatus.confirmed:
        return 'Confirmado • En cola de cocina';
      case OrderStatus.cooking:
        return 'El chef está preparando tus platillos 👨‍🍳';
      case OrderStatus.ready:
        return '¡Platillo listo! En camino a la mesa 🚀';
      case OrderStatus.delivered:
        return 'Servido en mesa • Comanda activa';
      case OrderStatus.paid:
        return 'Pagado • ¡Gracias por su visita!';
    }
  }
}

class RestaurantOrdersManager extends ChangeNotifier {
  static final RestaurantOrdersManager _instance = RestaurantOrdersManager._internal();
  factory RestaurantOrdersManager() => _instance;
  RestaurantOrdersManager._internal();

  static List<String> get _endpoints => [
        for (final base in ApiConfig.candidates) '$base/api/orders/sync',
      ];

  final List<RestaurantOrder> _orders = [];
  final List<StaffCall> _staffCalls = [];

  List<RestaurantOrder> get orders => List.unmodifiable(_orders);
  List<StaffCall> get staffCalls => List.unmodifiable(_staffCalls);
  List<StaffCall> get activeStaffCalls => _staffCalls.where((c) => !c.isResolved).toList();

  RestaurantBankingInfo? _bankingInfo;
  RestaurantBankingInfo? get bankingInfo => _bankingInfo;

  // ---------------------------------------------------------------------------
  // SMART POLLING ENGINE (Sondeo Adaptativo Inteligente de Alta Frecuencia / Push)
  // ---------------------------------------------------------------------------
  Timer? _activeBurstTimer;
  Timer? _sleepCountdownTimer;
  DateTime? _channelExpiresAt;
  bool _isBurstChannelActive = false;

  /// Indica si el canal de alta frecuencia (1.5s) está encendido actualmente
  bool get isBurstChannelActive => _isBurstChannelActive;

  /// Minutos u horas restantes antes de que el canal se apague automáticamente
  Duration get remainingChannelTime {
    if (!_isBurstChannelActive || _channelExpiresAt == null) return Duration.zero;
    final diff = _channelExpiresAt!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Despierta o renueva el canal de alta frecuencia por [duration] (por defecto 5 minutos).
  /// Se ejecuta automáticamente al:
  /// - Levantar o enviar un pedido (comida, bebidas, postres)
  /// - Solicitar la cuenta (efectivo, terminal, transferencia)
  /// - Llamar al mesero o subir comprobante
  /// - Recibir una notificación Push entrante
  void wakeUpActiveChannel({Duration duration = const Duration(minutes: 5)}) {
    _channelExpiresAt = DateTime.now().add(duration);
    _sleepCountdownTimer?.cancel();

    // Timer para apagar el canal al cumplirse los 5 minutos sin actividad
    _sleepCountdownTimer = Timer(duration, () {
      sleepChannel();
    });

    if (!_isBurstChannelActive) {
      _isBurstChannelActive = true;
      debugPrint('[SmartPollingEngine] 🚀 Canal Rápido ACTIVADO por ${duration.inMinutes} minutos.');
      // Ejecutar una consulta inmediata
      fetchOrdersFromBackend();
      // Bucle de alta frecuencia (1.5 segundos) mientras esté despierto
      _activeBurstTimer?.cancel();
      _activeBurstTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
        if (_isBurstChannelActive) {
          fetchOrdersFromBackend();
        } else {
          _activeBurstTimer?.cancel();
        }
      });
      notifyListeners();
    } else {
      debugPrint('[SmartPollingEngine] ⏱️ Canal Rápido RENOVADO por ${duration.inMinutes} minutos más.');
    }
  }

  /// Apaga el canal de alta frecuencia para ahorrar batería, base de datos y recursos en la nube.
  /// A partir de este momento, cualquier nuevo evento será recibido vía Push Notification o refresco.
  void sleepChannel() {
    _isBurstChannelActive = false;
    _activeBurstTimer?.cancel();
    _activeBurstTimer = null;
    _sleepCountdownTimer?.cancel();
    _sleepCountdownTimer = null;
    _channelExpiresAt = null;
    debugPrint('[SmartPollingEngine] 💤 Canal Rápido APAGADO. Sistema en modo reposo / Push standby.');
    notifyListeners();
  }

  StaffCall? getActiveCallForTable(String tableId) {
    try {
      return _staffCalls.lastWhere((c) => c.tableIdentifier == tableId && !c.isResolved);
    } catch (_) {
      return null;
    }
  }

  // Todas las comandas activas no pagadas de una mesa ordenadas cronológicamente (Ronda 1, Ronda 2, etc.)
  List<RestaurantOrder> getActiveOrdersForTable(String tableId) {
    final list = _orders.where(
      (order) => order.tableIdentifier == tableId && order.status != OrderStatus.paid,
    ).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  // Pedidos activos para mesa específica (último pedido para compatibilidad)
  RestaurantOrder? getActiveOrderForTable(String tableId) {
    final active = getActiveOrdersForTable(tableId);
    return active.isNotEmpty ? active.last : null;
  }

  // Totales financieros acumulados de toda la mesa
  double getTableSubtotal(String tableId) {
    return getActiveOrdersForTable(tableId).fold(0.0, (sum, o) => sum + o.subtotal);
  }

  double getTableTip(String tableId) {
    return getActiveOrdersForTable(tableId).fold(0.0, (sum, o) => sum + o.tipAmount);
  }

  double getTableTotal(String tableId) {
    return getActiveOrdersForTable(tableId).fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  // Estado consolidado de la mesa según prioridad de servicio
  OrderStatus getTableConsolidatedStatus(String tableId) {
    final active = getActiveOrdersForTable(tableId);
    if (active.isEmpty) return OrderStatus.paid;

    if (active.any((o) => o.status == OrderStatus.sent)) return OrderStatus.sent;
    if (active.any((o) => o.status == OrderStatus.ready)) return OrderStatus.ready;
    if (active.any((o) => o.status == OrderStatus.cooking)) return OrderStatus.cooking;
    if (active.any((o) => o.status == OrderStatus.confirmed)) return OrderStatus.confirmed;
    if (active.every((o) => o.status == OrderStatus.delivered)) return OrderStatus.delivered;

    return active.last.status;
  }

  // Pedidos activos para el administrador (excluyendo los ya pagados/archivados)
  List<RestaurantOrder> get adminOrders => _orders.where((o) => o.status != OrderStatus.paid).toList();

  // Historial de ventas para el Corte de Caja
  List<RestaurantOrder> get paidOrders {
    final list = _orders.where((o) => o.status == OrderStatus.paid).toList();
    list.sort((a, b) => b.paidAt != null && a.paidAt != null ? b.paidAt!.compareTo(a.paidAt!) : b.createdAt.compareTo(a.createdAt));
    return list;
  }

  double get totalSalesToday => paidOrders.fold(0.0, (sum, o) => sum + (o.amountPaid ?? o.totalAmount));

  // Pedidos para la cocina (los confirmados, cocinando o listos) ordenados estrictamente por FIFO (más antiguos primero)
  List<RestaurantOrder> get kitchenOrders {
    final active = _orders.where(
      (o) => o.status == OrderStatus.sent || o.status == OrderStatus.confirmed || o.status == OrderStatus.cooking || o.status == OrderStatus.ready,
    ).toList();
    // Ordenar de más antiguo a más nuevo (FIFO)
    active.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return active;
  }

  // Comandas ya despachadas
  List<RestaurantOrder> get kitchenDeliveredOrders {
    final list = _orders.where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.paid).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> fetchOrdersFromBackend() async {
    for (final ep in _endpoints) {
      try {
        final resp = await ApiClient.get(ep, timeout: const Duration(seconds: 2));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          if (data['orders'] is List) {
            final List<dynamic> remoteList = data['orders'];
            bool changed = false;

            for (final item in remoteList) {
              final remoteOrder = RestaurantOrder.fromJson(item as Map<String, dynamic>);
              final idx = _orders.indexWhere((o) => o.id == remoteOrder.id);
              if (idx >= 0) {
                // `paid` es un estado TERMINAL: si la comanda ya fue cobrada
                // localmente, un sondeo que aún devuelve el estado anterior del
                // servidor NO debe degradarla a 'delivered'. Sin esta guarda la
                // mesa se volvía a bloquear, la venta desaparecía del corte de
                // caja y el cobro confirmado se "deshacía" a los pocos segundos.
                final localIsPaid = _orders[idx].status == OrderStatus.paid;
                final remoteIsPaid = remoteOrder.status == OrderStatus.paid;

                if (localIsPaid && !remoteIsPaid) {
                  // El servidor todavía no registra el cobro: conservamos el
                  // estado local y reintentamos la escritura en el siguiente
                  // sondeo (ver _syncOrderToBackend / payAndClose*).
                  continue;
                }

                if (_orders[idx].status != remoteOrder.status ||
                    _orders[idx].paidAt != remoteOrder.paidAt ||
                    _orders[idx].paymentMethod != remoteOrder.paymentMethod) {
                  _orders[idx].status = remoteOrder.status;
                  _orders[idx].confirmedAt = remoteOrder.confirmedAt;
                  _orders[idx].cookingStartedAt = remoteOrder.cookingStartedAt;
                  _orders[idx].readyAt = remoteOrder.readyAt;
                  _orders[idx].paidAt = remoteOrder.paidAt;
                  _orders[idx].paymentMethod = remoteOrder.paymentMethod;
                  _orders[idx].amountPaid = remoteOrder.amountPaid;
                  changed = true;
                }
              } else {
                _orders.add(remoteOrder);
                changed = true;
              }
            }

            // Consultar también llamadas de personal (/sync/calls)
            final callsChanged = await _fetchCallsFromBackend(ep);
            if (callsChanged) {
              changed = true;
            }

            if (changed) {
              notifyListeners();
            }
          }
          break;
        }
      } catch (_) {}
    }
  }

  RestaurantOrder submitNewOrder({
    required String tableIdentifier,
    OrderType orderType = OrderType.table,
    WaiterOrigin waiterOrigin = WaiterOrigin.virtualTable,
    String? waiterName,
    String? customerName,
    String? customerPhone,
    required List<OrderCartLine> items,
    required double subtotal,
    required double tipAmount,
    required double totalAmount,
  }) {
    final now = DateTime.now();
    final newOrder = RestaurantOrder(
      // ID único por comanda. Antes se usaba
      // `millisecondsSinceEpoch.toString().substring(7)`, que dejaba solo 6
      // dígitos y por lo tanto se repetía cada ~16 minutos (y con más razón
      // si se enviaban dos comandas en el mismo milisegundo). El backend
      // identifica las comandas por id, así que una colisión hacía que una
      // comanda sobrescribiera a la otra.
      id: 'ORD-${now.microsecondsSinceEpoch}-${Random().nextInt(10000).toString().padLeft(4, '0')}',
      tableIdentifier: tableIdentifier,
      orderType: orderType,
      waiterOrigin: waiterOrigin,
      waiterName: waiterName,
      customerName: customerName,
      customerPhone: customerPhone,
      items: List.from(items),
      subtotal: subtotal,
      tipAmount: tipAmount,
      totalAmount: totalAmount,
      createdAt: now,
      // Si es de barra o teléfono creado por admin, ya entra como confirmado
      status: orderType == OrderType.table ? OrderStatus.sent : OrderStatus.confirmed,
      confirmedAt: orderType != OrderType.table ? now : null,
    );
    _orders.insert(0, newOrder);
    notifyListeners();

    // Despertar de inmediato el canal de alta frecuencia por 5 minutos (burst polling)
    wakeUpActiveChannel();

    // Sincronizar con el Backend API para que la Cocina y Admin lo vean en tiempo real
    _syncOrderToBackend(newOrder);

    return newOrder;
  }

  Future<void> _syncOrderToBackend(RestaurantOrder order) async {
    final body = jsonEncode(order.toJson());
    for (final ep in _endpoints) {
      try {
        final resp = await ApiClient.post(
          ep,
          body: body,
          timeout: const Duration(seconds: 3),
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          break;
        }
      } catch (_) {}
    }
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final now = DateTime.now();
      _orders[index].status = newStatus;
      if (newStatus == OrderStatus.confirmed && _orders[index].confirmedAt == null) {
        _orders[index].confirmedAt = now;
      } else if (newStatus == OrderStatus.cooking && _orders[index].cookingStartedAt == null) {
        _orders[index].cookingStartedAt = now;
      } else if (newStatus == OrderStatus.ready && _orders[index].readyAt == null) {
        _orders[index].readyAt = now;
      }
      notifyListeners();

      _syncStatusToBackend(
        orderId,
        newStatus,
        _orders[index].confirmedAt,
        _orders[index].cookingStartedAt,
        _orders[index].readyAt,
      );
    }
  }

  Future<void> _syncStatusToBackend(
    String orderId,
    OrderStatus newStatus,
    DateTime? confirmedAt,
    DateTime? cookingStartedAt,
    DateTime? readyAt,
  ) async {
    final body = jsonEncode({
      'status': newStatus.name,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'cookingStartedAt': cookingStartedAt?.toIso8601String(),
      'readyAt': readyAt?.toIso8601String(),
    });

    for (final ep in _endpoints) {
      try {
        final resp = await ApiClient.patch(
          '$ep/$orderId/status',
          body: body,
          timeout: const Duration(seconds: 3),
        );
        if (resp.statusCode == 200) {
          break;
        }
      } catch (_) {}
    }
  }

  Future<bool> _fetchCallsFromBackend(String syncEndpoint) async {
    try {
      final callsUrl = '$syncEndpoint/calls';
      final resp = await ApiClient.get(callsUrl, timeout: const Duration(seconds: 2));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['calls'] is List) {
          final List<dynamic> list = data['calls'];
          final List<StaffCall> newCalls = [];
          for (final c in list) {
            newCalls.add(StaffCall.fromJson(c as Map<String, dynamic>));
          }

          // Verificar si hubo cambios en cantidad, estado o ids
          bool changed = false;
          if (_staffCalls.length != newCalls.length) {
            changed = true;
          } else {
            for (int i = 0; i < newCalls.length; i++) {
              if (_staffCalls[i].id != newCalls[i].id ||
                  _staffCalls[i].isResolved != newCalls[i].isResolved ||
                  _staffCalls[i].reason != newCalls[i].reason ||
                  _staffCalls[i].paymentPreference != newCalls[i].paymentPreference) {
                changed = true;
                break;
              }
            }
          }

          if (changed) {
            _staffCalls.clear();
            _staffCalls.addAll(newCalls);
            // Si entra una llamada nueva sin resolver, despertar canal rápido de 5 minutos
            if (newCalls.any((c) => !c.isResolved)) {
              wakeUpActiveChannel();
            }
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  Future<bool> callStaff(
    String tableIdentifier, {
    String reason = 'call_waiter',
    String? customerName,
  }) async {
    final body = jsonEncode({
      'tableIdentifier': tableIdentifier,
      'reason': reason,
      'customerName': customerName,
    });

    for (final ep in _endpoints) {
      try {
        final resp = await ApiClient.post(
          '$ep/call-staff',
          body: body,
          timeout: const Duration(seconds: 3),
        );

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          final data = jsonDecode(resp.body);
          if (data['call'] != null) {
            final call = StaffCall.fromJson(data['call']);
            final idx = _staffCalls.indexWhere((c) => c.id == call.id);
            if (idx >= 0) {
              _staffCalls[idx] = call;
            } else {
              _staffCalls.insert(0, call);
            }
            wakeUpActiveChannel();
            notifyListeners();
          }
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  Future<RestaurantBankingInfo?> fetchBankingInfo({String? restaurantId}) async {
    for (final ep in _endpoints) {
      try {
        final uri = Uri.parse('$ep/banking').replace(queryParameters: {
          if (restaurantId != null) 'restaurantId': restaurantId,
        });
        final resp = await ApiClient.get(uri.toString(), timeout: const Duration(seconds: 3));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          if (data['banking'] != null) {
            _bankingInfo = RestaurantBankingInfo.fromJson(data['banking']);
            notifyListeners();
            return _bankingInfo;
          }
        }
      } catch (_) {}
    }
    return _bankingInfo;
  }

  Future<bool> updateBankingInfo(RestaurantBankingInfo info, {String? restaurantId}) async {
    final body = jsonEncode({
      'restaurantId': restaurantId,
      'bankName': info.bankName,
      'accountHolder': info.accountHolder,
      'clabe': info.clabe,
      'notes': info.notes,
    });

    for (final ep in _endpoints) {
      try {
        final resp = await ApiClient.post(
          '$ep/banking',
          body: body,
          timeout: const Duration(seconds: 3),
        );

        if (resp.statusCode == 200) {
          _bankingInfo = info;
          notifyListeners();
          return true;
        }
      } catch (_) {}
    }
    _bankingInfo = info;
    notifyListeners();
    return true;
  }

  Future<bool> requestBillWithPayment(
    String tableIdentifier, {
    required String paymentPreference, // 'cash' | 'terminal' | 'transfer'
    String? receiptImage,
    double? amountToPay,
    String? customerName,
    String? restaurantId,
    String? notes,
  }) async {
    final reason = (paymentPreference == 'transfer' && receiptImage != null)
        ? 'payment_receipt'
        : 'request_bill';

    final body = jsonEncode({
      'tableIdentifier': tableIdentifier,
      'reason': reason,
      'customerName': customerName,
      'paymentPreference': paymentPreference,
      'receiptImage': receiptImage,
      'amountToPay': amountToPay,
      'restaurantId': restaurantId,
      'notes': notes,
    });

    for (final ep in _endpoints) {
      try {
        final resp = await ApiClient.post(
          '$ep/call-staff',
          body: body,
          timeout: const Duration(seconds: 4),
        );

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          final data = jsonDecode(resp.body);
          if (data['call'] != null) {
            final call = StaffCall.fromJson(data['call']);
            final idx = _staffCalls.indexWhere((c) => c.id == call.id);
            if (idx >= 0) {
              _staffCalls[idx] = call;
            } else {
              _staffCalls.insert(0, call);
            }
            wakeUpActiveChannel();
            notifyListeners();
          }
          return true;
        }
      } catch (_) {}
    }

    final localCall = StaffCall(
      id: 'call-${DateTime.now().millisecondsSinceEpoch}',
      tableIdentifier: tableIdentifier,
      reason: reason,
      customerName: customerName,
      paymentPreference: paymentPreference,
      receiptImage: receiptImage,
      amountToPay: amountToPay,
      restaurantId: restaurantId,
      notes: notes,
      createdAt: DateTime.now(),
    );
    final idx = _staffCalls.indexWhere((c) => c.tableIdentifier == tableIdentifier && !c.isResolved);
    if (idx >= 0) {
      _staffCalls[idx] = localCall;
    } else {
      _staffCalls.insert(0, localCall);
    }
    notifyListeners();
    return true;
  }

  Future<bool> resolveStaffCall(String callIdOrTable) async {
    for (final ep in _endpoints) {
      try {
        final resp = await ApiClient.post(
          '$ep/calls/$callIdOrTable/resolve',
          timeout: const Duration(seconds: 3),
        );

        if (resp.statusCode == 200) {
          final idx = _staffCalls.indexWhere((c) => c.id == callIdOrTable || c.tableIdentifier == callIdOrTable);
          if (idx >= 0) {
            _staffCalls[idx].isResolved = true;
            notifyListeners();
          }
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  Future<bool> payAndCloseOrder(
    String orderId, {
    String paymentMethod = 'cash',
    double? amountPaid,
  }) async {
    final body = jsonEncode({
      'paymentMethod': paymentMethod,
      'amountPaid': amountPaid,
    });

    final now = DateTime.now();
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final order = _orders[idx];
      order.status = OrderStatus.paid;
      order.paidAt = now;
      order.paymentMethod = paymentMethod;
      order.amountPaid = amountPaid ?? order.totalAmount;

      // Resolver llamada de cuenta para la mesa si había una
      final callIdx = _staffCalls.indexWhere((c) => c.tableIdentifier == order.tableIdentifier && !c.isResolved);
      if (callIdx >= 0) {
        _staffCalls[callIdx].isResolved = true;
      }
      notifyListeners();
    }

    for (final ep in _endpoints) {
      try {
        final resp = await ApiClient.post(
          '$ep/$orderId/pay',
          body: body,
          timeout: const Duration(seconds: 3),
        );

        if (resp.statusCode == 200) {
          return true;
        }
      } catch (_) {}
    }
    // Ningún endpoint confirmó la escritura: el estado local quedó pagado pero
    // el servidor no lo sabe. Se devuelve false para que la interfaz no
    // anuncie un cobro que en realidad no se persistió.
    debugPrint('[OrdersManager] El cobro de la comanda $orderId no pudo persistirse en el servidor.');
    return false;
  }

  Future<bool> payAndCloseTable(
    String tableId, {
    String paymentMethod = 'cash',
    double? amountPaid,
    String? authorizationFolio,
    String? last4,
  }) async {
    final active = getActiveOrdersForTable(tableId);
    if (active.isEmpty) return true;

    final now = DateTime.now();
    for (final order in active) {
      order.status = OrderStatus.paid;
      order.paidAt = now;
      order.paymentMethod = paymentMethod;
      order.amountPaid = order.totalAmount;
    }

    // Resolver llamadas de esa mesa
    for (final call in _staffCalls.where((c) => (c.tableIdentifier == tableId || c.tableIdentifier.toLowerCase() == tableId.toLowerCase()) && !c.isResolved)) {
      call.isResolved = true;
    }
    notifyListeners();

    final body = jsonEncode({
      'paymentMethod': paymentMethod,
      'amountPaid': amountPaid ?? active.fold<double>(0.0, (s, o) => s + o.totalAmount),
      if (authorizationFolio != null) 'authorizationFolio': authorizationFolio,
      if (last4 != null) 'last4': last4,
    });

    final encodedTable = Uri.encodeComponent(tableId);
    for (final ep in _endpoints) {
      try {
        final resp = await ApiClient.post(
          '$ep/table/$encodedTable/pay',
          body: body,
          timeout: const Duration(seconds: 3),
        );

        if (resp.statusCode == 200) {
          return true;
        }
      } catch (_) {}
    }
    // Ningún endpoint confirmó la escritura. El estado local ya quedó como
    // pagado (la mesa sí se liberó en pantalla), pero el servidor no lo sabe:
    // se devuelve false para que la interfaz pueda avisar de que el cobro no
    // se persistió, en lugar de mostrar un "cobrado con éxito" falso.
    debugPrint('[OrdersManager] El cobro de la mesa $tableId no pudo persistirse en el servidor.');
    return false;
  }

  /// Cancela los temporizadores del motor de sondeo adaptativo.
  ///
  /// El gestor es un singleton, pero `ChangeNotifier.dispose()` es público y
  /// debe dejar el estado limpio: sin esto, los timers de 1.5 s y el de reposo
  /// seguirían disparando `notifyListeners()` sobre un notificador liberado.
  @override
  void dispose() {
    _activeBurstTimer?.cancel();
    _activeBurstTimer = null;
    _sleepCountdownTimer?.cancel();
    _sleepCountdownTimer = null;
    _isBurstChannelActive = false;
    super.dispose();
  }
}
