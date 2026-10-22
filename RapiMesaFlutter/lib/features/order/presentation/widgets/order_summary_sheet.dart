import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/order_cart_state.dart';
import '../../providers/restaurant_orders_manager.dart';

class OrderSummarySheet extends StatelessWidget {
  final OrderCartState cart;

  const OrderSummarySheet({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E2228),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de arrastre
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Encabezado de la comanda
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comanda Activa',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          cart.tableIdentifier,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: const Color(0xFFE25822),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (cart.items.isNotEmpty)
                      TextButton.icon(
                        onPressed: cart.clearCart,
                        icon: const Icon(Icons.delete_outline, color: Colors.white60, size: 18),
                        label: Text(
                          'Vaciar',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Lista de platillos
                if (cart.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.restaurant, color: Colors.white24, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'La comanda está vacía.\nSelecciona platillos del menú.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.38,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const Divider(color: Color(0xFF2D323A), height: 16),
                      itemBuilder: (context, index) {
                        final line = cart.items[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Cantidad y botones
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF131518),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF2D323A)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => cart.updateQuantity(index, -1),
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(Icons.remove, color: Colors.white, size: 16),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '${line.quantity}',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => cart.updateQuantity(index, 1),
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(Icons.add, color: Color(0xFFE25822), size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Nombre e info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.dish.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (line.selectedExtras.isNotEmpty)
                                    Text(
                                      '+ ${line.selectedExtras.map((e) => e.name).join(', ')}',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (line.kitchenNotes.isNotEmpty)
                                    Text(
                                      'Nota: "${line.kitchenNotes}"',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFFE25822),
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Precio
                            Text(
                              '\$${line.totalLinePrice.toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 18),

                // Selector de Propina
                if (cart.items.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Propina sugerida:',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                      ),
                      Row(
                        children: [0.0, 0.10, 0.15, 0.20].map((tip) {
                          final isSelected = cart.tipPercentage == tip;
                          final label = tip == 0.0 ? '0%' : '${(tip * 100).toInt()}%';
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: InkWell(
                              onTap: () => cart.setTipPercentage(tip),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFE25822) : const Color(0xFF131518),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFE25822) : const Color(0xFF2D323A),
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Desglose de Totales
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
                            Text('Subtotal:', style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 13)),
                            Text('\$${cart.subtotal.toStringAsFixed(2)}', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                        if (cart.tipAmount > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Propina:', style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 13)),
                              Text('\$${cart.tipAmount.toStringAsFixed(2)}', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF10B981), fontSize: 13)),
                            ],
                          ),
                        ],
                        const Divider(color: Color(0xFF2D323A), height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Final:', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                              '\$${cart.totalWithTip.toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFE25822),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botones de acción directa
                  Row(
                    children: [
                      // Botón Enviar a Cocina (Ideal para levantar el pedido)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final manager = RestaurantOrdersManager();
                            manager.submitNewOrder(
                              tableIdentifier: cart.tableIdentifier,
                              items: cart.items,
                              subtotal: cart.subtotal,
                              tipAmount: cart.tipAmount,
                              totalAmount: cart.totalWithTip,
                            );
                            cart.clearCart();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('¡Comanda de ${cart.tableIdentifier} enviada a Admin y Cocina! 🍳'),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          },
                          icon: const Icon(Icons.soup_kitchen, size: 20),
                          label: Text(
                            'Enviar a Cocina',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE25822),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Botón Cobro Inmediato
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Generando cuenta para cobro... 💳'),
                              backgroundColor: Color(0xFFE25822),
                            ),
                          );
                        },
                        icon: const Icon(Icons.point_of_sale, size: 18, color: Colors.white),
                        label: Text(
                          'Cobrar',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2D323A)),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
