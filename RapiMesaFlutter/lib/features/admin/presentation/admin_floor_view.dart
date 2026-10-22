import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../order/models/dish_model.dart';
import '../../order/providers/restaurant_orders_manager.dart';

class AdminFloorView extends StatefulWidget {
  const AdminFloorView({super.key});

  @override
  State<AdminFloorView> createState() => _AdminFloorViewState();
}

class _AdminFloorViewState extends State<AdminFloorView> {
  Timer? _pollTimer;
  int _selectedTab = 0; // 0: Comandas Activas, 1: Corte de Caja / Historial

  @override
  void initState() {
    super.initState();
    RestaurantOrdersManager().fetchOrdersFromBackend();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      RestaurantOrdersManager().fetchOrdersFromBackend();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _openManualOrderDialog(BuildContext context, RestaurantOrdersManager manager) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ManualOrderSheet(manager: manager),
    );
  }

  void _showPaymentDialog(BuildContext context, RestaurantOrder order, RestaurantOrdersManager manager) {
    String selectedMethod = 'cash';
    final tableOrders = manager.getActiveOrdersForTable(order.tableIdentifier);
    final isWholeTable = tableOrders.length > 1;
    final totalToCharge = isWholeTable ? manager.getTableTotal(order.tableIdentifier) : order.totalAmount;
    final subtotalToCharge = isWholeTable ? manager.getTableSubtotal(order.tableIdentifier) : order.subtotal;
    final tipToCharge = isWholeTable ? manager.getTableTip(order.tableIdentifier) : order.tipAmount;

    showDialog(
      context: context,
      builder: (ctx) {
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.point_of_sale_rounded, color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWholeTable ? 'Cobrar Mesa Completa: ${order.tableIdentifier}' : 'Cobrar ${order.tableIdentifier}',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          isWholeTable
                              ? '${tableOrders.length} comandas acumuladas'
                              : 'Comanda ${order.id}',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desglose de monto
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131518),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF2D323A)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isWholeTable ? 'Subtotal (${tableOrders.length} pedidos):' : 'Subtotal:',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12),
                            ),
                            Text('\$${subtotalToCharge.toStringAsFixed(2)}', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        if (tipToCharge > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Propina:', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12)),
                              Text('\$${tipToCharge.toStringAsFixed(2)}', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF10B981), fontSize: 12)),
                            ],
                          ),
                        ],
                        const Divider(color: Color(0xFF2D323A), height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isWholeTable ? 'Gran Total a Cobrar:' : 'Total a Cobrar:',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '\$${totalToCharge.toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF10B981),
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Selecciona Método de Pago:',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  _buildPaymentMethodOption(
                    id: 'cash',
                    icon: Icons.payments_outlined,
                    label: 'Efectivo',
                    isSelected: selectedMethod == 'cash',
                    onSelect: () => setDialogState(() => selectedMethod = 'cash'),
                  ),
                  const SizedBox(height: 6),
                  _buildPaymentMethodOption(
                    id: 'card',
                    icon: Icons.credit_card_rounded,
                    label: 'Tarjeta (Terminal)',
                    isSelected: selectedMethod == 'card',
                    onSelect: () => setDialogState(() => selectedMethod = 'card'),
                  ),
                  const SizedBox(height: 6),
                  _buildPaymentMethodOption(
                    id: 'transfer',
                    icon: Icons.qr_code_2_rounded,
                    label: 'Transferencia / QR',
                    isSelected: selectedMethod == 'transfer',
                    onSelect: () => setDialogState(() => selectedMethod = 'transfer'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancelar', style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Se espera la respuesta real del servidor: antes se lanzaba
                    // sin `await` y se anunciaba el éxito aunque la escritura
                    // nunca llegara al backend.
                    final persisted = isWholeTable
                        ? await manager.payAndCloseTable(order.tableIdentifier, paymentMethod: selectedMethod)
                        : await manager.payAndCloseOrder(order.id, paymentMethod: selectedMethod);
                    if (!context.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              persisted ? Icons.check_circle : Icons.cloud_off,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                persisted
                                    ? (isWholeTable
                                        ? '¡${order.tableIdentifier} cobrada con éxito (${tableOrders.length} pedidos)! Mesa liberada y guardada en Corte de Caja.'
                                        : '¡${order.tableIdentifier} cobrada con éxito! Mesa liberada y guardada en Corte de Caja.')
                                    : 'Cobro registrado en este dispositivo, pero el servidor no lo confirmó. Revisa la conexión: el cobro no quedó guardado en el backend.',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: persisted ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: Text('Confirmar Cobro', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentMethodOption({
    required String id,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withOpacity(0.18) : const Color(0xFF131518),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF2D323A),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF10B981) : Colors.white60, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = RestaurantOrdersManager();

    return AnimatedBuilder(
      animation: manager,
      builder: (context, _) {
        final orders = manager.adminOrders;
        final pendingCount = orders.where((o) => o.status == OrderStatus.sent).length;
        final readyCount = orders.where((o) => o.status == OrderStatus.ready).length;
        final deliveredCount = orders.where((o) => o.status == OrderStatus.delivered).length;
        final staffCalls = manager.activeStaffCalls;

        return Scaffold(
          backgroundColor: const Color(0xFF131518),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E2228),
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE25822).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.manage_accounts_rounded, color: Color(0xFFE25822), size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Administración de Restaurante',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Supervisión de comandas & mostrador',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                tooltip: 'Actualizar',
                onPressed: () => RestaurantOrdersManager().fetchOrdersFromBackend(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openManualOrderDialog(context, manager),
            backgroundColor: const Color(0xFFE25822),
            foregroundColor: Colors.white,
            elevation: 6,
            icon: const Icon(Icons.add_shopping_cart, size: 20),
            label: Text(
              '+ Comanda Barra / Teléfono',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          body: Column(
            children: [
              // Alertas de Llamadas de Mesa / Solicitud de Cuenta
              if (staffCalls.isNotEmpty)
                Container(
                  color: const Color(0xFF9A3412),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: staffCalls.map((call) {
                      final isBill = call.reason == 'request_bill';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              isBill ? Icons.point_of_sale_rounded : Icons.notifications_active,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isBill
                                    ? '🔔 ¡${call.tableIdentifier} ha solicitado la cuenta para pagar!'
                                    : '🔔 ${call.tableIdentifier} llama a un mesero a su mesa.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isBill) ...[
                              ElevatedButton(
                                onPressed: () {
                                  final order = manager.getActiveOrderForTable(call.tableIdentifier);
                                  if (order != null) {
                                    _showPaymentDialog(context, order, manager);
                                  } else {
                                    manager.resolveStaffCall(call.id);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text('Cobrar', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 6),
                            ],
                            OutlinedButton(
                              onPressed: () => manager.resolveStaffCall(call.id),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white70),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text('Atendido', style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Selector de Pestañas: Comandas Activas vs Corte de Caja
              Container(
                color: const Color(0xFF1A1D23),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedTab = 0),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? const Color(0xFFE25822) : const Color(0xFF131518),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Comandas Activas (${orders.length})',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedTab = 1),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? const Color(0xFF10B981) : const Color(0xFF131518),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Corte de Caja (${manager.paidOrders.length} • \$${manager.totalSalesToday.toStringAsFixed(0)})',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Resumen rápido de turno (Métricas)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFF1A1D23),
                child: Row(
                  children: [
                    _buildMetricCapsule(
                      label: 'Pendientes',
                      count: pendingCount,
                      color: Colors.amber,
                      icon: Icons.notifications_active,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricCapsule(
                      label: 'En Cocina / Listas',
                      count: readyCount,
                      color: const Color(0xFF10B981),
                      icon: Icons.room_service,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricCapsule(
                      label: 'Por Cobrar',
                      count: deliveredCount,
                      color: const Color(0xFF38BDF8),
                      icon: Icons.table_restaurant,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricCapsule(
                      label: 'Venta Hoy',
                      countStr: '\$${manager.totalSalesToday.toStringAsFixed(0)}',
                      color: const Color(0xFF10B981),
                      icon: Icons.point_of_sale,
                    ),
                  ],
                ),
              ),

              // Vista Principal según Tab Seleccionado
              Expanded(
                child: _selectedTab == 0
                    ? _buildActiveOrdersList(orders, manager)
                    : _buildCorteDeCajaView(manager),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveOrdersList(List<RestaurantOrder> orders, RestaurantOrdersManager manager) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2228),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2D323A)),
              ),
              child: const Icon(Icons.receipt_long, color: Colors.white24, size: 48),
            ),
            const SizedBox(height: 18),
            Text(
              'Sin comandas activas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Los pedidos de mesas, barra o llamadas aparecerán aquí en vivo.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildAdminOrderCard(order, manager);
      },
    );
  }

  Widget _buildCorteDeCajaView(RestaurantOrdersManager manager) {
    final paidOrders = manager.paidOrders;

    return Column(
      children: [
        // Resumen Financiero
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2228),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Recaudado Hoy', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '\$${manager.totalSalesToday.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF131518),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2D323A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Comandas Cobradas', style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11)),
                    Text(
                      '${paidOrders.length} mesas',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista de Ventas
        Expanded(
          child: paidOrders.isEmpty
              ? Center(
                  child: Text(
                    'No hay comandas cobradas aún en este turno.',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 13),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: paidOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = paidOrders[index];
                    final methodLabel = order.paymentMethod == 'card'
                        ? 'Tarjeta'
                        : order.paymentMethod == 'transfer'
                            ? 'Transferencia'
                            : 'Efectivo';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2228),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF2D323A)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.receipt, color: Color(0xFF10B981), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      order.tableIdentifier,
                                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '• ${order.id}',
                                      style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${order.items.length} platillos • Pago en $methodLabel',
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${order.totalAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Pagado',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMetricCapsule({
    required String label,
    int? count,
    String? countStr,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF131518),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D323A)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    countStr ?? '${count ?? 0}',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white38,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOrderCard(RestaurantOrder order, RestaurantOrdersManager manager) {
    Color statusColor;
    String statusTitle;

    switch (order.status) {
      case OrderStatus.sent:
        statusColor = Colors.amber;
        statusTitle = '🔔 Nuevo de Mesa (Aprobar)';
        break;
      case OrderStatus.confirmed:
        statusColor = const Color(0xFFE25822);
        statusTitle = '⏳ En cola de Cocina';
        break;
      case OrderStatus.cooking:
        statusColor = Colors.orangeAccent;
        statusTitle = '👨‍🍳 Chef Preparando';
        break;
      case OrderStatus.ready:
        statusColor = const Color(0xFF10B981);
        statusTitle = '🚀 ¡LISTO! Llevar a Mesa';
        break;
      case OrderStatus.delivered:
        statusColor = Colors.blueGrey;
        statusTitle = '✅ Entregado / Servido';
        break;
      case OrderStatus.paid:
        statusColor = const Color(0xFF10B981);
        statusTitle = '💵 Pagado / Cerrado';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: order.status == OrderStatus.ready
              ? const Color(0xFF10B981)
              : order.status == OrderStatus.sent
                  ? Colors.amber.withOpacity(0.6)
                  : const Color(0xFF2D323A),
          width: order.status == OrderStatus.ready || order.status == OrderStatus.sent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131518),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2D323A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          order.orderType == OrderType.table
                              ? Icons.table_restaurant
                              : order.orderType == OrderType.walkInBar
                                  ? Icons.local_bar
                                  : Icons.phone_in_talk,
                          color: const Color(0xFFE25822),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.orderTypeLabel,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.id,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusTitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          if (order.customerName != null && order.customerName!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_pin, color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Comensal: ${order.customerName!}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text('(${order.customerPhone!})', style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11)),
                ],
              ],
            ),
          ],

          const Divider(color: Color(0xFF2D323A), height: 20),

          // Resumen de platillos
          ...order.items.map((line) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${line.quantity}x ${line.dish.name}${line.selectedExtras.isNotEmpty ? " (+${line.selectedExtras.length} extras)" : ""}',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  Text(
                    '\$${line.totalLinePrice.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Comanda:', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12)),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFE25822),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // Badge de Origen de Comanda (Mesa Virtual vs Mesero Físico)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: order.waiterOrigin == WaiterOrigin.virtualTable
                  ? Colors.blueGrey.withOpacity(0.18)
                  : const Color(0xFFE25822).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: order.waiterOrigin == WaiterOrigin.virtualTable
                    ? Colors.blueGrey.withOpacity(0.4)
                    : const Color(0xFFE25822).withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  order.waiterOrigin == WaiterOrigin.virtualTable
                      ? Icons.tablet_mac
                      : Icons.badge_outlined,
                  size: 14,
                  color: order.waiterOrigin == WaiterOrigin.virtualTable ? Colors.cyanAccent : const Color(0xFFE25822),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.waiterOrigin == WaiterOrigin.virtualTable
                        ? 'Comanda de Mesa Virtual (Tablet Fija)'
                        : 'Comanda tomada por: ${order.waiterName ?? "Mesero en piso"}',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Botones de acción del Administrador
          if (order.status == OrderStatus.sent)
            ElevatedButton.icon(
              onPressed: () {
                manager.updateOrderStatus(order.id, OrderStatus.confirmed);
              },
              icon: const Icon(Icons.check_circle, size: 18),
              label: Text(
                'Aprobar Pedido y Pasar a Cocina',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE25822),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          else if (order.status == OrderStatus.ready) ...[
            // Banner explicativo de quién lleva el platillo
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: order.waiterOrigin == WaiterOrigin.virtualTable
                    ? const Color(0xFFE25822).withOpacity(0.18)
                    : const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: order.waiterOrigin == WaiterOrigin.virtualTable
                      ? const Color(0xFFE25822)
                      : const Color(0xFF10B981),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    order.waiterOrigin == WaiterOrigin.virtualTable
                        ? Icons.directions_walk
                        : Icons.notifications_active,
                    color: order.waiterOrigin == WaiterOrigin.virtualTable
                        ? const Color(0xFFE25822)
                        : const Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.waiterOrigin == WaiterOrigin.virtualTable
                          ? '👉 Administrador / Capitán: Lleva este platillo a ${order.tableIdentifier} (Mesa Virtual sin mesero físico).'
                          : '👉 Notificado a ${order.waiterName ?? "Mesero"}: El mesero asignado irá por el platillo a cocina.',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                manager.updateOrderStatus(order.id, OrderStatus.delivered);
              },
              icon: const Icon(Icons.room_service, size: 18),
              label: Text(
                order.waiterOrigin == WaiterOrigin.virtualTable
                    ? 'Confirmar Entrega en ${order.tableIdentifier}'
                    : 'Marcar como Entregado / Servido',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]
          else if (order.status == OrderStatus.delivered) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Platillos servidos en mesa. Comensal disfrutando de su consumo.',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                final tableOrders = manager.getActiveOrdersForTable(order.tableIdentifier);
                final isWhole = tableOrders.length > 1;
                final total = isWhole ? manager.getTableTotal(order.tableIdentifier) : order.totalAmount;

                return ElevatedButton.icon(
                  onPressed: () => _showPaymentDialog(context, order, manager),
                  icon: const Icon(Icons.point_of_sale_rounded, size: 18),
                  label: Text(
                    isWhole
                        ? '💵 Cobrar Mesa Completa • ${tableOrders.length} Pedidos (\$${total.toStringAsFixed(2)})'
                        : '💵 Cobrar Cuenta y Liberar Mesa (\$${total.toStringAsFixed(2)})',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                );
              },
            ),
          ]
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF131518),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                'En proceso en cocina...',
                style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _ManualOrderSheet extends StatefulWidget {
  final RestaurantOrdersManager manager;
  const _ManualOrderSheet({required this.manager});

  @override
  State<_ManualOrderSheet> createState() => _ManualOrderSheetState();
}

class _ManualOrderSheetState extends State<_ManualOrderSheet> {
  OrderType _orderType = OrderType.walkInBar;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<DishItem> _dishes = DishItem.sampleDishes;
  DishItem? _selectedDish;
  final List<ExtraIngredient> _selectedExtras = [];
  final int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (_dishes.isNotEmpty) {
      _selectedDish = _dishes.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _currentLineTotal {
    if (_selectedDish == null) return 0.0;
    final extrasCost = _selectedExtras.fold<double>(0.0, (s, e) => s + e.extraPrice);
    return (_selectedDish!.price + extrasCost) * _quantity;
  }

  void _submitManualOrder() {
    if (_selectedDish == null) return;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el nombre del cliente.')),
      );
      return;
    }

    final line = OrderCartLine(
      dish: _selectedDish!,
      quantity: _quantity,
      selectedExtras: List.from(_selectedExtras),
      kitchenNotes: _notesController.text.trim(),
    );

    widget.manager.submitNewOrder(
      tableIdentifier: _orderType == OrderType.walkInBar ? 'Barra Principal' : 'Mostrador Teléfono',
      orderType: _orderType,
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      items: [line],
      subtotal: line.totalLinePrice,
      tipAmount: 0.0,
      totalAmount: line.totalLinePrice,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        content: Text('¡Comanda de ${_nameController.text.trim()} enviada directo a cocina!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E2228),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
                const Icon(Icons.playlist_add, color: Color(0xFFE25822), size: 22),
                const SizedBox(width: 10),
                Text(
                  'Nueva Comanda Manual (Admin)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selector Tipo de Orden
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('🍸 Barra / Mostrador'),
                    selected: _orderType == OrderType.walkInBar,
                    onSelected: (val) => setState(() => _orderType = OrderType.walkInBar),
                    selectedColor: const Color(0xFFE25822),
                    backgroundColor: const Color(0xFF131518),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: _orderType == OrderType.walkInBar ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('📞 Teléfono / Llevar'),
                    selected: _orderType == OrderType.phoneTakeout,
                    onSelected: (val) => setState(() => _orderType = OrderType.phoneTakeout),
                    selectedColor: const Color(0xFFE25822),
                    backgroundColor: const Color(0xFF131518),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: _orderType == OrderType.phoneTakeout ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Inputs Cliente
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nombre del Cliente / Comensal *',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: const Color(0xFF131518),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Teléfono (Opcional)',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: const Color(0xFF131518),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 18),
            Text(
              'Seleccionar Platillo:',
              style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Dropdown de Platillos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF131518),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2D323A)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DishItem>(
                  value: _selectedDish,
                  dropdownColor: const Color(0xFF1E2228),
                  isExpanded: true,
                  items: _dishes.map((dish) {
                    return DropdownMenuItem(
                      value: dish,
                      child: Text(
                        '${dish.name} - \$${dish.price.toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedDish = val;
                        _selectedExtras.clear();
                      });
                    }
                  },
                ),
              ),
            ),

            // Extras disponibles del platillo
            if (_selectedDish != null && _selectedDish!.availableExtras.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Extras / Ingredientes Opcionales:',
                style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _selectedDish!.availableExtras.map((extra) {
                  final isSelected = _selectedExtras.contains(extra);
                  return FilterChip(
                    label: Text(
                      '${extra.name} (+\$${extra.extraPrice.toStringAsFixed(2)})',
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE25822),
                    backgroundColor: const Color(0xFF131518),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedExtras.add(extra);
                        } else {
                          _selectedExtras.remove(extra);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 12),

            // Notas de Cocina
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Notas para Cocina (ej. Sin cebolla, bien cocido)',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: const Color(0xFF131518),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 18),

            // Total y botón de enviar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total a cobrar:', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12)),
                    Text(
                      '\$${_currentLineTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFE25822),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _submitManualOrder,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text('Enviar a Cocina', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE25822),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
