import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/config/api_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../order/providers/restaurant_orders_manager.dart';
import '../../menu/presentation/menu_categories_page.dart';
import '../../kitchen/presentation/kitchen_view.dart';
import '../../admin/presentation/admin_floor_view.dart';
import '../../admin/presentation/super_admin_view.dart';
import 'restaurant_menu_management_view.dart';
import 'push_activity_view.dart';

enum StaffType {
  physicalWaiter,
  virtualTable,
  kitchenChef,
}

class RestaurantStaffMember {
  final String id;
  final String name;
  final StaffType type;
  final String tableAssigned;
  final String username;
  final String password;
  final bool isActive;

  RestaurantStaffMember({
    required this.id,
    required this.name,
    required this.type,
    required this.tableAssigned,
    required this.username,
    required this.password,
    this.isActive = true,
  });
}

class RestaurantAdminDashboardView extends StatefulWidget {
  final String restaurantName;
  final String adminEmail;
  final String planName;
  final int trialDaysRemaining;
  final int maxStaffQuota;
  final String restaurantId;
  final String adminUid;

  const RestaurantAdminDashboardView({
    super.key,
    this.restaurantName = 'Víctor Coffee',
    this.adminEmail = 'victor@coffee.com',
    this.planName = 'Prueba Gratuita (7 Días)',
    this.trialDaysRemaining = 7,
    this.maxStaffQuota = 3,
    this.restaurantId = '868a4cf3378b4af4b418fd17c85f5250',
    this.adminUid = 'victor_test_uid_1791953469836',
  });

  @override
  State<RestaurantAdminDashboardView> createState() => _RestaurantAdminDashboardViewState();
}

class _RestaurantAdminDashboardViewState extends State<RestaurantAdminDashboardView> {
  late final List<RestaurantStaffMember> _staffList;
  late String _currentRestaurantName;
  late String _currentRestaurantId;
  bool _isLoadingStaff = false;

  Timer? _ordersPollingTimer;

  @override
  void initState() {
    super.initState();
    _staffList = [];
    _currentRestaurantName = widget.restaurantName;
    _currentRestaurantId = widget.restaurantId;
    _fetchStaffAndRestaurantInfo();
    RestaurantOrdersManager().fetchOrdersFromBackend();
    RestaurantOrdersManager().fetchBankingInfo(restaurantId: _currentRestaurantId);
    _ordersPollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        RestaurantOrdersManager().fetchOrdersFromBackend();
      }
    });
  }

  @override
  void dispose() {
    _ordersPollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStaffAndRestaurantInfo() async {
    final identifier = _currentRestaurantId.isNotEmpty ? _currentRestaurantId : widget.adminUid;
    if (identifier.isEmpty) return;

    if (mounted) setState(() => _isLoadingStaff = true);

    for (final base in ApiConfig.candidates) {
      try {
        final resp = await ApiClient.get(
          '$base/api/auth/staff/$identifier',
          timeout: const Duration(seconds: 4),
        );
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          if (mounted) {
            setState(() {
              if (data['restaurantName'] != null && data['restaurantName'].toString().isNotEmpty) {
                _currentRestaurantName = data['restaurantName'];
              }
              if (data['restaurantId'] != null && data['restaurantId'].toString().isNotEmpty) {
                _currentRestaurantId = data['restaurantId'];
              }

              if (data['staff'] is List) {
                _staffList.clear();
                for (final item in data['staff']) {
                  final role = item['role']?.toString() ?? 'waiter';
                  final isChef = role == 'kitchen' || role == 'chef';
                  _staffList.add(RestaurantStaffMember(
                    id: item['id']?.toString() ?? 'st-${DateTime.now().millisecondsSinceEpoch}',
                    name: item['name']?.toString() ?? 'Personal',
                    type: isChef ? StaffType.kitchenChef : StaffType.virtualTable,
                    tableAssigned: item['tableAssigned']?.toString() ?? 'Mesa 1',
                    username: item['email']?.toString() ?? '',
                    password: '••••••',
                    isActive: true,
                  ));
                }
              }
            });
          }
          break;
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isLoadingStaff = false);
    }
  }

  void _showAddStaffModal() {
    if (_staffList.length >= widget.maxStaffQuota) {
      _showQuotaExceededDialog();
      return;
    }

    final nameController = TextEditingController(text: 'Mesero ${_staffList.length + 1}');
    final tableController = TextEditingController(text: 'Mesa ${_staffList.length + 1}');
    final userController = TextEditingController(
      text: 'mesero${_staffList.length + 1}@${_currentRestaurantName.toLowerCase().replaceAll(' ', '').replaceAll("'", '')}.com',
    );
    final passwordController = TextEditingController(text: '123456');
    StaffType selectedType = StaffType.virtualTable;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E2228),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D323A),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.person_add_alt_1, color: Color(0xFFE25822), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Nuevo Mesero o Mesa Virtual',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cupo restante en Prueba Gratuita: ${widget.maxStaffQuota - _staffList.length} de ${widget.maxStaffQuota}',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Selector de Tipo: Físico vs Virtual vs Cocinero
                    Text(
                      'Tipo de Función en el Restaurante:',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('🪑 Mesa Virtual'),
                            selected: selectedType == StaffType.virtualTable,
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  selectedType = StaffType.virtualTable;
                                  nameController.text = 'Tablet ${tableController.text}';
                                });
                              }
                            },
                            selectedColor: const Color(0xFFE25822),
                            backgroundColor: const Color(0xFF131518),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: selectedType == StaffType.virtualTable ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('🏃 Mesero'),
                            selected: selectedType == StaffType.physicalWaiter,
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  selectedType = StaffType.physicalWaiter;
                                  nameController.text = 'Mesero ${_staffList.length + 1}';
                                });
                              }
                            },
                            selectedColor: const Color(0xFFE25822),
                            backgroundColor: const Color(0xFF131518),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: selectedType == StaffType.physicalWaiter ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('👨‍🍳 Cocina'),
                            selected: selectedType == StaffType.kitchenChef,
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  selectedType = StaffType.kitchenChef;
                                  nameController.text = 'Chef Cocina ${_staffList.length + 1}';
                                  tableController.text = 'Cocina Principal';
                                });
                              }
                            },
                            selectedColor: const Color(0xFF10B981),
                            backgroundColor: const Color(0xFF131518),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: selectedType == StaffType.kitchenChef ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Nombre / Identificador
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: selectedType == StaffType.virtualTable ? 'Identificador de la Tablet' : 'Nombre del Mesero',
                        labelStyle: const TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: const Color(0xFF131518),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Mesa Asignada
                    TextField(
                      controller: tableController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Mesa Asignada (ej. Mesa 4, Mesa 1, Salón General)',
                        labelStyle: TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Color(0xFF131518),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      onChanged: (val) {
                        if (selectedType == StaffType.virtualTable) {
                          nameController.text = 'Tablet $val';
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // Usuario para iniciar sesión
                    TextField(
                      controller: userController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Usuario / Correo de inicio de sesión',
                        labelStyle: TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Color(0xFF131518),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Contraseña / PIN
                    TextField(
                      controller: passwordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Contraseña o PIN para el dispositivo',
                        labelStyle: TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Color(0xFF131518),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        'Guardar y Habilitar en Salón',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE25822),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final email = userController.text.trim();
                        final password = passwordController.text.trim();
                        final tableAssigned = tableController.text.trim().isEmpty ? 'Mesa 1' : tableController.text.trim();

                        if (name.isEmpty || email.isEmpty || password.isEmpty) return;

                        // 1. Guardar localmente de inmediato para UX reactiva
                        final newMember = RestaurantStaffMember(
                          id: 'staff-${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          type: selectedType,
                          tableAssigned: tableAssigned,
                          username: email,
                          password: password,
                          isActive: true,
                        );

                        setState(() {
                          _staffList.add(newMember);
                        });
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(ctx);

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Guardando $name en Firebase...'),
                            backgroundColor: const Color(0xFFE25822),
                            duration: const Duration(seconds: 1),
                          ),
                        );

                        // 2. Persistir en Backend (Firebase Auth + Cloud SQL)
                        try {
                          final payload = {
                            'name': name,
                            'email': email,
                            'password': password,
                            'restaurantId': _currentRestaurantId.isNotEmpty ? _currentRestaurantId : widget.restaurantId,
                            'tableAssigned': tableAssigned,
                            'role': selectedType == StaffType.kitchenChef ? 'kitchen' : 'waiter',
                            'waiterType': selectedType == StaffType.kitchenChef
                                ? 'kitchen'
                                : (selectedType == StaffType.virtualTable ? 'virtualTable' : 'physicalWaiter'),
                            'adminId': widget.adminUid,
                          };

                          http.Response? response;
                          String? lastError;
                          for (final base in ApiConfig.candidates) {
                            try {
                              final resp = await ApiClient.post(
                                '$base/api/auth/create-waiter',
                                body: payload,
                                timeout: const Duration(seconds: 5),
                              );
                              if (resp.statusCode == 201) {
                                response = resp;
                                break;
                              }
                              lastError = 'HTTP ${resp.statusCode}: ${resp.body}';
                            } catch (e) {
                              lastError = e.toString();
                            }
                          }

                          if (response != null && response.statusCode == 201) {
                            _fetchStaffAndRestaurantInfo();
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('¡$name registrado exitosamente en Firebase!'),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          } else {
                            // Sin este aviso el personal quedaba en la lista local
                            // con credenciales que nunca funcionaron, y desaparecía
                            // al siguiente refresco.
                            if (!mounted) return;
                            _staffList.removeWhere((s) => s.username == email);
                            setState(() {});
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('No se pudo crear $name: ${lastError ?? 'sin respuesta del servidor'}'),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          }
                        } catch (err) {
                          debugPrint('Error al persistir mesero en backend: $err');
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showQuotaExceededDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2228),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFEF4444)),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 10),
            Text(
              'Límite de Cupo Alcanzado',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Has alcanzado el límite máximo de ${widget.maxStaffQuota} meseros o mesas virtuales incluido en tu ${widget.planName}.',
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9CA3AF), fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF131518),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2D323A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mejora a Plan Express (\$29 USD/mes):',
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFFE25822), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Hasta 15 cupos simultáneos (meseros y mesas)\n• 2 administradores de restaurante\n• Soporte prioritario',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contactando a soporte para actualizar a Plan Express...'),
                  backgroundColor: Color(0xFFE25822),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE25822),
              foregroundColor: Colors.white,
            ),
            child: const Text('Actualizar Plan'),
          ),
        ],
      ),
    );
  }

  void _showBankingConfigDialog() {
    final manager = RestaurantOrdersManager();
    final currentBanking = manager.bankingInfo ?? RestaurantBankingInfo(
      bankName: 'BBVA México',
      accountHolder: 'Vianey Coffee S.A. de C.V.',
      clabe: '012180015482938475',
      notes: 'Concepto/Referencia: Número de tu mesa',
    );

    final bankNameCtrl = TextEditingController(text: currentBanking.bankName);
    final accountHolderCtrl = TextEditingController(text: currentBanking.accountHolder);
    final clabeCtrl = TextEditingController(text: currentBanking.clabe);
    final notesCtrl = TextEditingController(text: currentBanking.notes);
    String? errorMessage;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E2228),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2D323A)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance, color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Datos Bancarios para SPEI',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingresa la cuenta bancaria donde los comensales transferirán el total de su consumo:',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Nombre del Banco
                  TextField(
                    controller: bankNameCtrl,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Banco Receptor (ej. BBVA, Santander, Banorte, Nu)',
                      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF131518),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.account_balance_outlined, color: Colors.white38, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Titular
                  TextField(
                    controller: accountHolderCtrl,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Nombre del Titular o Razón Social',
                      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF131518),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.badge_outlined, color: Colors.white38, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // CLABE
                  TextField(
                    controller: clabeCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 18,
                    style: GoogleFonts.jetBrainsMono(color: const Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'CLABE Interbancaria (18 dígitos)',
                      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12),
                      counterStyle: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11),
                      filled: true,
                      fillColor: const Color(0xFF131518),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.numbers, color: Colors.white38, size: 20),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Instrucciones o concepto
                  TextField(
                    controller: notesCtrl,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Instrucción / Concepto de Transferencia',
                      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF131518),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.note_alt_outlined, color: Colors.white38, size: 20),
                    ),
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // CLÁUSULA LEGAL Y DE PRIVACIDAD
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131518),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2D323A)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.security, color: Colors.amber, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Seguridad & Privacidad: La información bancaria ingresada se utilizará única y exclusivamente para que los comensales en mesa realicen depósitos directos vía SPEI hacia tu cuenta bancaria. RapiMesa no retiene fondos de tus ventas ni solicita números completos de tarjeta o códigos CVV.',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final clabeClean = clabeCtrl.text.replaceAll(RegExp(r'\s+'), '');
                      if (clabeClean.length != 18 || !RegExp(r'^\d{18}$').hasMatch(clabeClean)) {
                        setDialogState(() => errorMessage = 'La CLABE interbancaria debe tener exactamente 18 dígitos numéricos.');
                        return;
                      }
                      if (bankNameCtrl.text.trim().isEmpty || accountHolderCtrl.text.trim().isEmpty) {
                        setDialogState(() => errorMessage = 'Por favor ingresa el Banco y el Titular de la cuenta.');
                        return;
                      }

                      setDialogState(() {
                        errorMessage = null;
                        isSaving = true;
                      });

                      final newInfo = RestaurantBankingInfo(
                        bankName: bankNameCtrl.text.trim(),
                        accountHolder: accountHolderCtrl.text.trim(),
                        clabe: clabeClean,
                        notes: notesCtrl.text.trim(),
                        updatedAt: DateTime.now(),
                      );

                      final ok = await manager.updateBankingInfo(newInfo, restaurantId: _currentRestaurantId);

                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok ? '¡Datos bancarios guardados con éxito!' : 'Datos actualizados localmente.',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Guardar Datos', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2228),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2D323A)),
        ),
        title: Row(
          children: [
            const Icon(Icons.gavel_rounded, color: Color(0xFFE25822), size: 22),
            const SizedBox(width: 10),
            Text(
              'Aviso de Privacidad y Términos',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Identidad del Prestador Tecnológico:\nRapiMesa es una plataforma de software como servicio (SaaS) dedicada a la gestión de comandas, menú interactivo y monitor KDS.\n',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '2. Tratamiento de Datos Bancarios y Cobros Directos (SPEI / Efectivo / Terminal):\nLa información bancaria (Banco, Titular de cuenta y CLABE Interbancaria de 18 dígitos) ingresada por el Administrador del restaurante se utiliza única y exclusivamente con la finalidad de que los comensales en mesa realicen depósitos y transferencias electrónicas directas hacia la cuenta bancaria del propio establecimiento.\n\nRapiMesa NO es una entidad financiera ni intermediario de fondos (pasarela que retenga o custodie el dinero del restaurante): los fondos viajan directamente de la cuenta bancaria del cliente a la del restaurante.\n\nAsimismo, la captura de comprobantes de pago de los comensales se utiliza de forma confidencial únicamente para la validación visual y confirmación del pago de la comanda en curso. RapiMesa nunca solicita ni almacena números de tarjeta de crédito/débito de 16 dígitos (PAN) ni códigos de seguridad (CVV).\n',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, height: 1.35),
                ),
                Text(
                  '3. Deslinde de Responsabilidad Legal:\nLa preparación, calidad, precios e higiene de los alimentos comercializados son responsabilidad exclusiva del establecimiento gastronómico.',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE25822),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Entendido', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showViewReceiptDialog(StaffCall call) {
    final manager = RestaurantOrdersManager();
    final tableTotal = manager.getTableTotal(call.tableIdentifier);
    final amountToShow = call.amountToPay ?? (tableTotal > 0 ? tableTotal : 0.0);

    Widget imageWidget;
    if (call.receiptImage != null && call.receiptImage!.isNotEmpty) {
      try {
        final clean = call.receiptImage!.contains(',')
            ? call.receiptImage!.split(',').last
            : call.receiptImage!;
        final bytes = base64Decode(clean);
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            height: 280,
          ),
        );
      } catch (_) {
        imageWidget = Container(
          height: 180,
          color: const Color(0xFF131518),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long, color: Color(0xFF10B981), size: 48),
              const SizedBox(height: 8),
              Text('Comprobante Registrado', style: GoogleFonts.plusJakartaSans(color: Colors.white70)),
            ],
          ),
        );
      }
    } else {
      imageWidget = Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF131518),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D323A)),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 40),
            const SizedBox(height: 8),
            Text(
              'El comensal avisó de su transferencia sin adjuntar imagen.',
              style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2228),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2D323A)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long, color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comprobante • ${call.tableIdentifier}',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Monto Reportado: \$${amountToShow.toStringAsFixed(2)} MXN',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imageWidget,
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF131518),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hora de envío:', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 11)),
                    Text(
                      '${call.createdAt.hour.toString().padLeft(2, '0')}:${call.createdAt.minute.toString().padLeft(2, '0')} hrs',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cerrar', style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final persisted = await manager.payAndCloseTable(
                call.tableIdentifier,
                paymentMethod: 'transfer',
                amountPaid: amountToShow,
              );
              await manager.resolveStaffCall(call.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      persisted
                          ? '✅ ¡Pago de ${call.tableIdentifier} validado! Mesa liberada y archivada en corte.'
                          : '⚠️ Pago de ${call.tableIdentifier} registrado solo en este dispositivo; el servidor no lo confirmó.',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text('Validar y Confirmar Pago', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualPayTableDialog(StaffCall call) {
    final manager = RestaurantOrdersManager();
    final total = manager.getTableTotal(call.tableIdentifier);
    String method = call.paymentPreference == 'terminal' ? 'terminal' : 'cash';
    final folioCtrl = TextEditingController();
    final last4Ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E2228),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2D323A)),
          ),
          title: Text(
            'Cobrar Mesa • ${call.tableIdentifier}',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total de la Mesa: \$${total.toStringAsFixed(2)} MXN',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (call.notes != null && call.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('Nota del comensal: ${call.notes}', style: GoogleFonts.plusJakartaSans(color: Colors.amberAccent, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              Text('Método de Cobro:', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Efectivo'),
                    selected: method == 'cash',
                    onSelected: (val) => setDialogState(() => method = 'cash'),
                    backgroundColor: const Color(0xFF131518),
                    selectedColor: const Color(0xFFE25822),
                    labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Terminal Bancaria'),
                    selected: method == 'terminal',
                    onSelected: (val) => setDialogState(() => method = 'terminal'),
                    backgroundColor: const Color(0xFF131518),
                    selectedColor: const Color(0xFF38BDF8),
                    labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (method == 'terminal') ...[
                const SizedBox(height: 14),
                TextField(
                  controller: folioCtrl,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Folio / Aut. de Voucher (Opcional)',
                    labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF131518),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: last4Ctrl,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Últimos 4 dígitos tarjeta (ej. 4521)',
                    labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF131518),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final persisted = await manager.payAndCloseTable(
                  call.tableIdentifier,
                  paymentMethod: method,
                  authorizationFolio: folioCtrl.text.isNotEmpty ? folioCtrl.text.trim() : null,
                  last4: last4Ctrl.text.isNotEmpty ? last4Ctrl.text.trim() : null,
                );
                await manager.resolveStaffCall(call.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        persisted
                            ? '✅ Mesa ${call.tableIdentifier} cobrada y liberada con éxito.'
                            : '⚠️ Cobro de ${call.tableIdentifier} registrado solo en este dispositivo; el servidor no lo confirmó.',
                      ),
                      backgroundColor: persisted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: Text('Confirmar Cobro', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCallsPriorityBanner(RestaurantOrdersManager manager) {
    final calls = manager.activeStaffCalls;
    if (calls.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE25822).withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE25822).withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: Color(0xFFE25822), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Atención en Mesas: Solicitudes de Cobro & Llamadas',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (manager.isBurstChannelActive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.6)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'CANAL RÁPIDO (${manager.remainingChannelTime.inMinutes + 1}m)',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE25822),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${calls.length} PENDIENTES',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...calls.map((call) {
            final isReceipt = call.reason == 'payment_receipt';
            final isBill = call.reason == 'request_bill';

            Color itemBorder = isReceipt
                ? const Color(0xFF10B981)
                : (isBill ? const Color(0xFF38BDF8) : const Color(0xFFE25822));

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF131518),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: itemBorder.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(
                    isReceipt
                        ? Icons.qr_code_2_rounded
                        : (isBill ? Icons.point_of_sale_rounded : Icons.person_pin_circle_rounded),
                    color: itemBorder,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              call.tableIdentifier,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: itemBorder.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isReceipt
                                    ? 'COMPROBANTE SPEI'
                                    : (isBill
                                        ? (call.paymentPreference == 'terminal' ? 'TERMINAL' : 'EFECTIVO')
                                        : 'LLAMADA MESERO'),
                                style: GoogleFonts.plusJakartaSans(
                                  color: itemBorder,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isReceipt
                              ? 'Comprobante subido por \$${call.amountToPay?.toStringAsFixed(2) ?? "0.00"} MXN • Requiere validación'
                              : (isBill
                                  ? 'Solicitó pagar cuenta • ${call.notes ?? "Sin notas"}'
                                  : 'El cliente solicita atención de mesero en mesa'),
                          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isReceipt) ...[
                    OutlinedButton.icon(
                      onPressed: () => _showViewReceiptDialog(call),
                      icon: const Icon(Icons.remove_red_eye, size: 14),
                      label: Text('Ver Comprobante', style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF10B981)),
                        foregroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await manager.payAndCloseTable(
                          call.tableIdentifier,
                          paymentMethod: 'transfer',
                          amountPaid: call.amountToPay,
                        );
                        await manager.resolveStaffCall(call.id);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ ¡Pago de ${call.tableIdentifier} confirmado! Mesa liberada.'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check, size: 14),
                      label: Text('Validar', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ] else if (isBill) ...[
                    ElevatedButton.icon(
                      onPressed: () => _showManualPayTableDialog(call),
                      icon: const Icon(Icons.point_of_sale, size: 14),
                      label: Text('Registrar Cobro', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () => manager.resolveStaffCall(call.id),
                      icon: const Icon(Icons.check, size: 14),
                      label: Text('Atender', style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE25822),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usedQuota = _staffList.length;
    final isQuotaMax = usedQuota >= widget.maxStaffQuota;
    final progress = usedQuota / widget.maxStaffQuota;

    return Scaffold(
      backgroundColor: const Color(0xFF131518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2228),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront, color: Color(0xFFE25822), size: 20),
                const SizedBox(width: 8),
                Text(
                  _currentRestaurantName,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              'Admin: ${widget.adminEmail} • Panel de Control',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFF38BDF8)),
            tooltip: 'Notificaciones: dispositivos y actividad',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PushActivityView(
                    restaurantName: _currentRestaurantName,
                    restaurantId: _currentRestaurantId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_rounded, color: Color(0xFFE25822)),
            tooltip: 'Gestionar Menú & Platillos (Cloud SQL)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RestaurantMenuManagementView(
                    restaurantId: _currentRestaurantId,
                    restaurantName: _currentRestaurantName,
                    adminEmail: widget.adminEmail,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_outlined, color: Colors.white70),
            tooltip: 'Configuración Bancaria (SPEI)',
            onPressed: _showBankingConfigDialog,
          ),
          IconButton(
            icon: const Icon(Icons.gavel_rounded, color: Colors.white70),
            tooltip: 'Aviso de Privacidad y Términos',
            onPressed: _showPrivacyPolicyDialog,
          ),
          IconButton(
            icon: _isLoadingStaff
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE25822)),
                  )
                : const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Actualizar Personal',
            onPressed: () => _fetchStaffAndRestaurantInfo(),
          ),
          // Selector Rápido de Roles
          PopupMenuButton<String>(
            icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white70),
            color: const Color(0xFF1E2228),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF2D323A)),
            ),
            onSelected: (role) {
              if (role == 'manage_menu') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantMenuManagementView(
                      restaurantId: _currentRestaurantId,
                      restaurantName: _currentRestaurantName,
                      adminEmail: widget.adminEmail,
                    ),
                  ),
                );
              } else if (role == 'menu') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MenuCategoriesPage(
                      restaurantId: widget.restaurantId,
                      userRole: 'restaurant_admin',
                    ),
                  ),
                );
              } else if (role == 'kitchen') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KitchenView()),
                );
              } else if (role == 'floor_admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminFloorView()),
                );
              } else if (role == 'super_admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SuperAdminDashboardView()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'manage_menu',
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: Color(0xFFE25822), size: 20),
                    const SizedBox(width: 10),
                    Text('Gestionar Menú & Platillos', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'menu',
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: Color(0xFFE25822), size: 20),
                    const SizedBox(width: 10),
                    Text('Ver Menú / Comensal en Mesa', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'kitchen',
                child: Row(
                  children: [
                    const Icon(Icons.soup_kitchen, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Text('Ver Monitor de Cocina (Chef)', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'floor_admin',
                child: Row(
                  children: [
                    const Icon(Icons.manage_accounts, color: Color(0xFF3B82F6), size: 20),
                    const SizedBox(width: 10),
                    Text('Ver Comandas de Piso', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              if (widget.adminEmail.toLowerCase().trim() == 'chebetoa7@gmail.com')
                PopupMenuItem(
                  value: 'super_admin',
                  child: Row(
                    children: [
                      const Icon(Icons.shield, color: Colors.amber, size: 20),
                      const SizedBox(width: 10),
                      Text('Super Admin (SaaS Global)', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStaffModal,
        backgroundColor: const Color(0xFFE25822),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Agregar Mesero / Mesa',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedBuilder(
        animation: RestaurantOrdersManager(),
        builder: (context, _) {
          final manager = RestaurantOrdersManager();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner de Alertas y Comprobantes de Mesas en Vivo
                _buildStaffCallsPriorityBanner(manager),

                // Tarjeta de Acceso Rápido: Gestión de Menú, Carta & Platillos (Cloud SQL)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E1A14), Color(0xFF1E2228)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE25822).withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE25822).withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE25822).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.restaurant_menu, color: Color(0xFFE25822), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestión de Carta & Menú (Cloud SQL)',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Administra categorías, platillos, bebidas, precios e ingredientes extra.',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RestaurantMenuManagementView(
                                restaurantId: _currentRestaurantId,
                                restaurantName: _currentRestaurantName,
                                adminEmail: widget.adminEmail,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE25822),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Ver Carta',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                // Banner de Prueba Gratuita y Estado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A332B), Color(0xFF1E2228)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user, color: Color(0xFF10B981), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.planName,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${widget.trialDaysRemaining} DÍAS RESTANTES',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tu periodo de prueba de 7 días está activo. Puedes registrar hasta 3 meseros o mesas virtuales para levantar pedidos.',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Tarjeta de Control de Cupo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2228),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isQuotaMax ? const Color(0xFFEF4444).withOpacity(0.5) : const Color(0xFF2D323A),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_alt, color: Color(0xFFE25822), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Cupos de Meseros y Mesas Virtuales',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$usedQuota / ${widget.maxStaffQuota} Usados',
                        style: GoogleFonts.plusJakartaSans(
                          color: isQuotaMax ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFF131518),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isQuotaMax ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isQuotaMax)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFFEF4444), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Has alcanzado el límite de 3 meseros/mesas de tu Prueba Gratuita. Para habilitar más cupos, sube al Plan Express.',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFFCA5A5),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      'Tienes ${widget.maxStaffQuota - usedQuota} cupo(s) disponible(s) para asignar a tus meseros o tablets incrustadas en mesa.',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Encabezado de la Lista
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meseros y Mesas Habilitadas (${_staffList.length})',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE25822),
                  ),
                  onPressed: _showAddStaffModal,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Lista de Tarjetas de Meseros / Mesas
            if (_isLoadingStaff && _staffList.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2228),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFFE25822)),
                    const SizedBox(height: 12),
                    Text(
                      'Cargando personal registrado...',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              )
            else if (_staffList.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2228),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.table_restaurant_outlined, size: 48, color: Colors.white30),
                    const SizedBox(height: 12),
                    Text(
                      'No tienes meseros o mesas registradas todavía.',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _showAddStaffModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE25822),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Crear Primer Mesero o Mesa'),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _staffList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final staff = _staffList[index];
                  final isVirtual = staff.type == StaffType.virtualTable;
                  final isChef = staff.type == StaffType.kitchenChef;

                  Color chipColor = const Color(0xFFE25822);
                  IconData chipIcon = Icons.badge_outlined;
                  String roleSubtitle = 'Mesero Móvil asignado a ${staff.tableAssigned}';

                  if (isVirtual) {
                    chipColor = const Color(0xFF3B82F6);
                    chipIcon = Icons.tablet_mac;
                    roleSubtitle = 'Mesero Virtual Incrustado en ${staff.tableAssigned}';
                  } else if (isChef) {
                    chipColor = const Color(0xFF10B981);
                    chipIcon = Icons.soup_kitchen;
                    roleSubtitle = 'Cocinero / Chef (Monitor KDS Cocina)';
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2228),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2D323A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: chipColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                chipIcon,
                                color: chipColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        staff.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFF10B981)),
                                        ),
                                        child: Text(
                                          'ACTIVO',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF10B981),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    roleSubtitle,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF9CA3AF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFF2D323A), height: 1),
                        const SizedBox(height: 12),

                        // Bloque de Credenciales para entregar al mesero o ingresar en la tablet
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131518),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF2D323A)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.account_circle, size: 14, color: Color(0xFF9CA3AF)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Usuario: ${staff.username}',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.key, size: 14, color: Color(0xFF9CA3AF)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Clave / PIN: ${staff.password}',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFFE25822),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18, color: Colors.white60),
                                tooltip: 'Copiar credenciales',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Credenciales de ${staff.name} copiadas.'),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: const Color(0xFF1E2228),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Acciones de Tarjeta
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white54),
                              label: const Text('Eliminar', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              onPressed: () {
                                setState(() {
                                  _staffList.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cupo liberado.'),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Color(0xFF1E2228),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow_rounded, size: 16),
                              label: Text(
                                isVirtual ? 'Iniciar Mesa Virtual' : 'Iniciar Comanda Mesero',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isVirtual ? const Color(0xFF3B82F6) : const Color(0xFFE25822),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              onPressed: () {
                                // Abre el menú operativo asignando el contexto de la mesa
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MenuCategoriesPage(
                                      restaurantId: widget.restaurantId,
                                      userRole: 'restaurant_admin',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),

            // Accesos Operativos Rápidos
            Text(
              'Accesos Rápidos Operativos',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    title: 'Comandas Salón',
                    subtitle: 'Menú digital para mesas',
                    icon: Icons.restaurant_menu,
                    color: const Color(0xFFE25822),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MenuCategoriesPage(
                          restaurantId: widget.restaurantId,
                          userRole: 'restaurant_admin',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    title: 'Monitor de Cocina',
                    subtitle: 'Cola FIFO para Chefs',
                    icon: Icons.soup_kitchen,
                    color: const Color(0xFF10B981),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KitchenView())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    },
  ),
);
}

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2228),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2D323A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF9CA3AF),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
