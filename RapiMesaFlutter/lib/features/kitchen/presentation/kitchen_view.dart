import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../order/providers/restaurant_orders_manager.dart';
import '../../auth/presentation/login_page.dart';

class KitchenView extends StatefulWidget {
  const KitchenView({super.key});

  @override
  State<KitchenView> createState() => _KitchenViewState();
}

class _KitchenViewState extends State<KitchenView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Cargar comandas desde el backend inmediatamente
    RestaurantOrdersManager().fetchOrdersFromBackend();
    // Sincronizar en tiempo real cada 2 segundos
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      RestaurantOrdersManager().fetchOrdersFromBackend();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = RestaurantOrdersManager();

    return AnimatedBuilder(
      animation: manager,
      builder: (context, _) {
        final orders = manager.kitchenOrders;

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
                  child: const Icon(Icons.soup_kitchen, color: Color(0xFFE25822), size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitor de Cocina (KDS)',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Cola de comanda FIFO • Tiempo real',
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: orders.isEmpty ? const Color(0xFF2D323A) : const Color(0xFFE25822),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: orders.isNotEmpty
                      ? [
                          BoxShadow(
                            color: const Color(0xFFE25822).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${orders.length} EN COLA',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                tooltip: 'Actualizar Comandas',
                onPressed: () {
                  RestaurantOrdersManager().fetchOrdersFromBackend();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sincronizando comandas con cocina... 🍳'),
                      duration: Duration(milliseconds: 600),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                tooltip: 'Cerrar Turno / Salir',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2228),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2D323A)),
                        ),
                        child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 54),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '¡Cocina al día!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No hay comandas pendientes en preparación.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...orders.map((o) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildKitchenOrderCard(o, manager),
                    )),
                    if (manager.kitchenDeliveredOrders.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ExpansionTile(
                        collapsedBackgroundColor: const Color(0xFF1E2228),
                        backgroundColor: const Color(0xFF1E2228),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(
                          'Comandas Servidas / Despachadas (${manager.kitchenDeliveredOrders.length})',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        leading: const Icon(Icons.done_all, color: Color(0xFF10B981)),
                        children: manager.kitchenDeliveredOrders.map((d) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131518),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF2D323A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${d.tableIdentifier} • ${d.id} • ${d.items.length} platillos (${d.items.map((i) => "${i.quantity}x ${i.dish.name}").join(", ")})',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  d.status == OrderStatus.paid ? 'Cobrado' : 'Servido',
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
        );
      },
    );
  }

  Widget _buildKitchenOrderCard(RestaurantOrder order, RestaurantOrdersManager manager) {
    final isCooking = order.status == OrderStatus.cooking;
    final isReady = order.status == OrderStatus.ready;
    final minutes = order.elapsedMinutes;

    // Semáforo dinámico de tiempo
    Color timerColor;
    Color timerBg;
    if (minutes < 10) {
      timerColor = const Color(0xFF10B981); // Verde
      timerBg = const Color(0xFF10B981).withOpacity(0.12);
    } else if (minutes < 20) {
      timerColor = Colors.amber; // Amarillo
      timerBg = Colors.amber.withOpacity(0.12);
    } else {
      timerColor = Colors.redAccent; // Rojo alerta
      timerBg = Colors.redAccent.withOpacity(0.16);
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCooking
              ? const Color(0xFFE25822)
              : isReady
                  ? const Color(0xFF10B981)
                  : const Color(0xFF2D323A),
          width: isCooking || isReady ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado de la comanda en cocina
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.orderTypeLabel,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFE25822),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    order.id,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              // Semáforo de tiempo transcurrido
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: timerBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: timerColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, color: timerColor, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '$minutes min',
                      style: GoogleFonts.plusJakartaSans(
                        color: timerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Si es orden de cliente en mostrador o llamada
          if (order.customerName != null && order.customerName!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Cliente: ${order.customerName!}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Text(
                    '(${order.customerPhone!})',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],

          const Divider(color: Color(0xFF2D323A), height: 22),

          // Lista de platillos para cocinar
          ...order.items.map((line) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131518),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2D323A)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${line.quantity}x',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.dish.name,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (line.selectedExtras.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE25822).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'EXTRAS: ${line.selectedExtras.map((e) => e.name).join(" • ")}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFE25822),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        if (line.kitchenNotes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                              ),
                              child: Text(
                                '⚠️ NOTA DEL CHEF: "${line.kitchenNotes}"',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 6),

          // Botones de Acción del Chef
          if (order.status == OrderStatus.sent)
            ElevatedButton.icon(
              onPressed: () {
                manager.updateOrderStatus(order.id, OrderStatus.confirmed);
              },
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: Text(
                '✅ Aceptar Pedido',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
            )
          else if (order.status == OrderStatus.confirmed)
            ElevatedButton.icon(
              onPressed: () {
                manager.updateOrderStatus(order.id, OrderStatus.cooking);
              },
              icon: const Icon(Icons.soup_kitchen, size: 20),
              label: Text(
                '🔥 Iniciar Preparación',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE25822),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
            )
          else if (order.status == OrderStatus.cooking)
            ElevatedButton.icon(
              onPressed: () {
                manager.updateOrderStatus(order.id, OrderStatus.ready);
              },
              icon: const Icon(Icons.check_circle, size: 20),
              label: Text(
                '🍽️ ¡Platillos Listos para Recoger!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF131518),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.waiterOrigin == WaiterOrigin.virtualTable
                          ? 'En pase • Avisado al Admin/Capitán para llevar a ${order.tableIdentifier}'
                          : 'En pase • Avisado a ${order.waiterName ?? "Mesero"} para llevar a mesa',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
