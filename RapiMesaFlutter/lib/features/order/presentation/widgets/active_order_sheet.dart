import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/receipt_image_picker.dart';
import '../../models/dish_model.dart';
import '../../providers/restaurant_orders_manager.dart';

class ActiveOrderSheet extends StatefulWidget {
  final RestaurantOrder? order;
  final String? tableIdentifier;

  const ActiveOrderSheet({
    super.key,
    this.order,
    this.tableIdentifier,
  });

  @override
  State<ActiveOrderSheet> createState() => _ActiveOrderSheetState();
}

class _ActiveOrderSheetState extends State<ActiveOrderSheet> {
  bool _isCallingStaff = false;
  bool _isRequestingBill = false;

  String get _currentTableId =>
      widget.tableIdentifier ?? widget.order?.tableIdentifier ?? 'Mesa';

  Future<void> _handleCallStaff() async {
    setState(() => _isCallingStaff = true);
    final manager = RestaurantOrdersManager();
    final ok = await manager.callStaff(
      _currentTableId,
      reason: 'call_waiter',
      customerName: widget.order?.customerName,
    );
    if (mounted) {
      setState(() => _isCallingStaff = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ok
                      ? '¡Llamada enviada! Un mesero o encargado se dirige a $_currentTableId 🛎️'
                      : 'Llamada registrada en el sistema de piso.',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE25822),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleRequestBill(double totalAmount) async {
    _showPaymentSelectionModal(context, totalAmount);
  }

  void _showPaymentSelectionModal(BuildContext parentContext, double totalAmount) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        int selectedMethod = 2; // 0: Cash, 1: Terminal, 2: Transfer (default as per flow)
        String? selectedReceiptBase64;
        bool isSubmitting = false;
        String cashChangeNote = 'Monto exacto';
        final changeOptions = ['Monto exacto', '\$200', '\$500', '\$1,000', 'Otro'];

        return StatefulBuilder(
          builder: (context, setModalState) {
            final manager = RestaurantOrdersManager();
            final bankingInfo = manager.bankingInfo ?? RestaurantBankingInfo(
              bankName: 'BBVA México',
              accountHolder: "Vianey Coffee S.A. de C.V.",
              clabe: '012180015482938475',
              notes: 'Concepto: $_currentTableId',
            );

            // Cargar datos bancarios si aún no están
            if (manager.bankingInfo == null) {
              manager.fetchBankingInfo().then((_) {
                if (context.mounted) setModalState(() {});
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Color(0xFF1E2228),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 4),
                ],
              ),
              child: Column(
                children: [
                  // Manija superior
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Título del Modal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
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
                              child: const Icon(Icons.point_of_sale_rounded, color: Color(0xFF10B981), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pagar Cuenta • $_currentTableId',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  'Total: \$${totalAmount.toStringAsFixed(2)} MXN',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF10B981),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
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
                  ),

                  const Divider(color: Color(0xFF2D323A), height: 20),

                  // Selector de Método de Pago
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131518),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF2D323A)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMethodTab(
                              title: 'Efectivo',
                              icon: Icons.payments_outlined,
                              isSelected: selectedMethod == 0,
                              onTap: () => setModalState(() => selectedMethod = 0),
                            ),
                          ),
                          Expanded(
                            child: _buildMethodTab(
                              title: 'Terminal',
                              icon: Icons.credit_card_rounded,
                              isSelected: selectedMethod == 1,
                              onTap: () => setModalState(() => selectedMethod = 1),
                            ),
                          ),
                          Expanded(
                            child: _buildMethodTab(
                              title: 'Transferencia',
                              icon: Icons.qr_code_2_rounded,
                              isSelected: selectedMethod == 2,
                              onTap: () => setModalState(() => selectedMethod = 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Contenido según Método
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (selectedMethod == 0) ...[
                            // EFECTIVO
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131518),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF2D323A)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline, color: Color(0xFFE25822), size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Pago en Efectivo en Mesa',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'El mesero o encargado de piso acudirá a tu mesa con tu cuenta en mano.',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '¿Requieres cambio? Indícanos tu billete aproximado:',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 12),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: changeOptions.map((opt) {
                                      final isOptSelected = cashChangeNote == opt;
                                      return ChoiceChip(
                                        label: Text(opt),
                                        selected: isOptSelected,
                                        onSelected: (val) {
                                          if (val) setModalState(() => cashChangeNote = opt);
                                        },
                                        backgroundColor: const Color(0xFF1E2228),
                                        selectedColor: const Color(0xFFE25822),
                                        labelStyle: GoogleFonts.plusJakartaSans(
                                          color: isOptSelected ? Colors.white : Colors.white70,
                                          fontWeight: isOptSelected ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (selectedMethod == 1) ...[
                            // TERMINAL EN MESA
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131518),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF2D323A)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.contactless, color: Color(0xFF38BDF8), size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Terminal Bancaria en Mesa',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Un mesero llevará la terminal inalámbrica directo a tu mesa para cobrarte con tarjeta de débito o crédito (Visa, Mastercard, AMEX o Apple Pay).',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF38BDF8).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.security, color: Color(0xFF38BDF8), size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'PCI-DSS Compliant: El cobro se realiza directamente en la terminal bancaria del establecimiento. RapiMesa nunca almacena ni solicita números de tarjeta ni CVV.',
                                            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // TRANSFERENCIA SPEI
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131518),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF2D323A)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.account_balance, color: Color(0xFF10B981), size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Datos Bancarios del Restaurante',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'SPEI Directo',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF10B981),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  _buildBankDataRow('Banco Receptor:', bankingInfo.bankName),
                                  const SizedBox(height: 8),
                                  _buildBankDataRow('Titular de la Cuenta:', bankingInfo.accountHolder),
                                  const SizedBox(height: 8),
                                  _buildBankClabeRow(context, bankingInfo.clabe),
                                  const SizedBox(height: 8),
                                  _buildBankDataRow('Monto Exacto:', '\$${totalAmount.toStringAsFixed(2)} MXN', isHighlighted: true),
                                  const SizedBox(height: 8),
                                  _buildBankDataRow('Concepto / Referencia:', '$_currentTableId • ${(widget.order?.customerName?.isNotEmpty ?? false) ? widget.order!.customerName : "Comensal"}'),

                                  const SizedBox(height: 14),

                                  // Aviso Legal de Privacidad y Destino de Fondos
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E2228),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF2D323A)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.gavel_rounded, color: Colors.amber, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Aviso Legal y de Privacidad: La cuenta CLABE mostrada es propiedad exclusiva del restaurante. Tu transferencia viaja directo a su cuenta bancaria. RapiMesa no retiene fondos ni solicita datos de tus tarjetas bancarias.',
                                            style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Sección Subir Comprobante
                                  Text(
                                    'Comprobante de Pago:',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Toma una captura de pantalla o foto del comprobante exitoso de tu banco y súbelo para validación del cajero.',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 12),
                                  ),
                                  const SizedBox(height: 12),

                                  if (selectedReceiptBase64 != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E2228),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF10B981)),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              color: Colors.black38,
                                              child: _buildReceiptThumbnail(selectedReceiptBase64!),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Comprobante Listo',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        color: const Color(0xFF10B981),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  'Listo para enviar al cajero',
                                                  style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              final img = await ReceiptImagePicker.pickImage();
                                              if (img != null && context.mounted) {
                                                setModalState(() => selectedReceiptBase64 = img);
                                              }
                                            },
                                            child: Text('Cambiar', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final img = await ReceiptImagePicker.pickImage();
                                        if (img != null && context.mounted) {
                                          setModalState(() => selectedReceiptBase64 = img);
                                        }
                                      },
                                      icon: const Icon(Icons.upload_file_rounded, color: Color(0xFF10B981), size: 20),
                                      label: Text(
                                        'Adjuntar Foto o Captura del Comprobante',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF10B981),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFF10B981)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Botón de Acción Principal
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() => isSubmitting = true);
                              final pref = selectedMethod == 0
                                  ? 'cash'
                                  : (selectedMethod == 1 ? 'terminal' : 'transfer');

                              final notes = selectedMethod == 0
                                  ? 'Cambio con: $cashChangeNote'
                                  : null;

                              await manager.requestBillWithPayment(
                                _currentTableId,
                                paymentPreference: pref,
                                receiptImage: selectedReceiptBase64,
                                amountToPay: totalAmount,
                                customerName: widget.order?.customerName,
                                notes: notes,
                              );

                              if (context.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(parentContext).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            selectedMethod == 2 && selectedReceiptBase64 != null
                                                ? '¡Comprobante enviado al cajero! En espera de validación.'
                                                : '¡Solicitud enviada! El personal se dirige a tu mesa.',
                                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedMethod == 2
                            ? const Color(0xFF10B981)
                            : (selectedMethod == 1 ? const Color(0xFF38BDF8) : const Color(0xFFE25822)),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              selectedMethod == 2
                                  ? (selectedReceiptBase64 != null
                                      ? 'Enviar Comprobante al Administrador'
                                      : 'Pagar con Transferencia (Avisar sin foto)')
                                  : (selectedMethod == 1
                                      ? 'Solicitar Terminal en Mesa'
                                      : 'Solicitar Cobro en Efectivo'),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMethodTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D323A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF10B981) : Colors.white54,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDataRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              color: isHighlighted ? const Color(0xFF10B981) : Colors.white,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              fontSize: isHighlighted ? 14 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankClabeRow(BuildContext context, String clabe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2D323A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CLABE Interbancaria (18 dígitos):',
                style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 10),
              ),
              const SizedBox(height: 2),
              SelectableText(
                clabe,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF38BDF8),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: clabe));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('¡CLABE copiada al portapapeles!', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF38BDF8),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 14),
            label: Text('Copiar', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8).withOpacity(0.2),
              foregroundColor: const Color(0xFF38BDF8),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptThumbnail(String base64String) {
    try {
      final clean = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      final bytes = base64Decode(clean);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      return const Icon(Icons.receipt_long, color: Color(0xFF10B981));
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = RestaurantOrdersManager();

    return AnimatedBuilder(
      animation: manager,
      builder: (context, _) {
        final activeOrders = manager.getActiveOrdersForTable(_currentTableId);

        // Fallback si no hay en manager pero pasaron order por parámetro
        final ordersToShow = activeOrders.isNotEmpty
            ? activeOrders
            : (widget.order != null ? [widget.order!] : <RestaurantOrder>[]);

        if (ordersToShow.isEmpty) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E2228),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 48),
                const SizedBox(height: 16),
                Text(
                  'Sin pedidos pendientes',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_currentTableId no tiene comandas activas por pagar.',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Totales acumulados
        final subtotal = ordersToShow.fold(0.0, (s, o) => s + o.subtotal);
        final tipAmount = ordersToShow.fold(0.0, (s, o) => s + o.tipAmount);
        final totalAmount = ordersToShow.fold(0.0, (s, o) => s + o.totalAmount);
        final consolidatedStatus = manager.getTableConsolidatedStatus(_currentTableId);

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

        final isMultipleRounds = ordersToShow.length > 1;

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E2228),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Indicador de arrastre
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Banner de estado de llamada o comprobante pendiente
                  Builder(
                    builder: (context) {
                      final activeCall = manager.getActiveCallForTable(_currentTableId);
                      if (activeCall == null) return const SizedBox.shrink();

                      final isReceipt = activeCall.reason == 'payment_receipt';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isReceipt
                              ? const Color(0xFF10B981).withOpacity(0.12)
                              : const Color(0xFF38BDF8).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isReceipt
                                ? const Color(0xFF10B981).withOpacity(0.4)
                                : const Color(0xFF38BDF8).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isReceipt
                                    ? const Color(0xFF10B981).withOpacity(0.2)
                                    : const Color(0xFF38BDF8).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isReceipt ? Icons.task_alt_rounded : Icons.hourglass_top_rounded,
                                color: isReceipt ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isReceipt
                                        ? 'Comprobante SPEI enviado'
                                        : 'Cuenta solicitada (${activeCall.paymentPreference == 'terminal' ? 'Terminal en mesa' : (activeCall.paymentPreference == 'transfer' ? 'Transferencia' : 'Efectivo')})',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isReceipt
                                        ? 'Esperando validación del cajero o administrador para liberar tu mesa.'
                                        : 'Un miembro del personal está en camino a tu mesa.',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Encabezado Principal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _currentTableId,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            isMultipleRounds
                                ? '${ordersToShow.length} pedidos acumulados sin pagar'
                                : 'Comanda ${ordersToShow.first.id} • Hace ${ordersToShow.first.elapsedMinutes} min',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon, color: badgeColor, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              isMultipleRounds
                                  ? '${ordersToShow.length} Rondas'
                                  : _getStatusLabel(ordersToShow.first.status),
                              style: GoogleFonts.plusJakartaSans(
                                color: badgeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Barra Visual de Progreso General
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131518),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2D323A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(badgeIcon, color: badgeColor, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isMultipleRounds
                                    ? 'Estado general: ${_getStatusLabel(consolidatedStatus)}'
                                    : ordersToShow.first.statusLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildProgressStep(
                              label: 'Enviado',
                              isActive: true,
                              isDone: consolidatedStatus != OrderStatus.sent,
                            ),
                            _buildProgressConnector(isDone: consolidatedStatus != OrderStatus.sent),
                            _buildProgressStep(
                              label: 'Cocina',
                              isActive: consolidatedStatus == OrderStatus.confirmed ||
                                  consolidatedStatus == OrderStatus.cooking,
                              isDone: consolidatedStatus == OrderStatus.ready ||
                                  consolidatedStatus == OrderStatus.delivered ||
                                  consolidatedStatus == OrderStatus.paid,
                            ),
                            _buildProgressConnector(
                              isDone: consolidatedStatus == OrderStatus.ready ||
                                  consolidatedStatus == OrderStatus.delivered ||
                                  consolidatedStatus == OrderStatus.paid,
                            ),
                            _buildProgressStep(
                              label: 'Listo',
                              isActive: consolidatedStatus == OrderStatus.ready,
                              isDone: consolidatedStatus == OrderStatus.delivered ||
                                  consolidatedStatus == OrderStatus.paid,
                            ),
                            _buildProgressConnector(
                              isDone: consolidatedStatus == OrderStatus.delivered ||
                                  consolidatedStatus == OrderStatus.paid,
                            ),
                            _buildProgressStep(
                              label: 'Servido',
                              isActive: consolidatedStatus == OrderStatus.delivered,
                              isDone: consolidatedStatus == OrderStatus.paid,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Lista de Platillos (Agrupados por ronda si hay más de 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isMultipleRounds ? 'Rondas y Platillos Solicitados' : 'Detalle de Platillos Solicitados',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${ordersToShow.fold<int>(0, (s, o) => s + o.items.length)} tipo(s)',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (isMultipleRounds) ...[
                    // Renderizar cada ronda por separado
                    ...ordersToShow.asMap().entries.map((entry) {
                      final roundIdx = entry.key + 1;
                      final order = entry.value;
                      final rBadgeColor = _getOrderColor(order.status);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131518),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2D323A)),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Encabezado de la Ronda
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE25822).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Ronda $roundIdx',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFFE25822),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      order.id,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: rBadgeColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: rBadgeColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    _getStatusLabel(order.status),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: rBadgeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Items de la comanda
                            ...order.items.map((line) => _buildDishLine(line)),

                            const Divider(color: Color(0xFF242830), height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal Ronda $roundIdx:', style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11)),
                                Text(
                                  '\$${order.totalAmount.toStringAsFixed(2)}',
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    // Una sola orden
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF131518),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2D323A)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Column(
                        children: ordersToShow.first.items.map((line) => _buildDishLine(line)).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Resumen Acumulado de la Mesa
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131518),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMultipleRounds ? const Color(0xFF10B981).withOpacity(0.4) : const Color(0xFF2D323A),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isMultipleRounds ? 'Subtotal Acumulado (${ordersToShow.length} pedidos):' : 'Subtotal:',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 13),
                            ),
                            Text(
                              '\$${subtotal.toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        if (tipAmount > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Propina voluntaria:', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 13)),
                              Text(
                                '\$${tipAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF10B981), fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                        const Divider(color: Color(0xFF2D323A), height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isMultipleRounds ? 'Gran Total Acumulado:' : 'Total Comanda:',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '\$${totalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF10B981),
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botones de Acción de Mesa: Llamar Personal y Pedir la Cuenta
                  Row(
                    children: [
                      // Botón 1: Llamar al Personal
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isCallingStaff ? null : _handleCallStaff,
                          icon: _isCallingStaff
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.notifications_active_outlined, size: 18),
                          label: Text(
                            'Llamar Personal',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE25822)),
                            foregroundColor: const Color(0xFFE25822),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón 2: Pedir la Cuenta / Pagar
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isRequestingBill ? null : () => _handleRequestBill(totalAmount),
                          icon: _isRequestingBill
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Icon(
                                  manager.getActiveCallForTable(_currentTableId)?.reason == 'payment_receipt'
                                      ? Icons.receipt_long
                                      : Icons.point_of_sale_rounded,
                                  size: 18,
                                ),
                          label: Text(
                            manager.getActiveCallForTable(_currentTableId)?.reason == 'payment_receipt'
                                ? 'Comprobante Enviado'
                                : 'Pedir la Cuenta',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: manager.getActiveCallForTable(_currentTableId)?.reason == 'payment_receipt'
                                ? const Color(0xFF0D9488)
                                : const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Nota informativa para el comensal
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131518),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white38, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tu pedido permanece visible hasta que el administrador o mesero confirme tu pago en caja. Al pagar, la mesa quedará liberada para nuevos clientes.',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDishLine(OrderCartLine line) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE25822).withOpacity(0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${line.quantity}x',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFE25822),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.dish.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (line.selectedExtras.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '+ ${line.selectedExtras.map((e) => e.name).join(", ")}',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11),
                    ),
                  ),
                if (line.kitchenNotes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Nota: "${line.kitchenNotes}"',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.amberAccent,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '\$${line.totalLinePrice.toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.sent:
        return 'Enviada';
      case OrderStatus.confirmed:
        return 'En Cola';
      case OrderStatus.cooking:
        return 'En Cocina';
      case OrderStatus.ready:
        return 'Platillo Listo';
      case OrderStatus.delivered:
        return 'Servido en Mesa';
      case OrderStatus.paid:
        return 'Pagado';
    }
  }

  Color _getOrderColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.sent:
        return Colors.amber;
      case OrderStatus.confirmed:
        return const Color(0xFFE25822);
      case OrderStatus.cooking:
        return Colors.orangeAccent;
      case OrderStatus.ready:
        return const Color(0xFF10B981);
      case OrderStatus.delivered:
        return const Color(0xFF38BDF8);
      case OrderStatus.paid:
        return const Color(0xFF10B981);
    }
  }

  Widget _buildProgressStep({
    required String label,
    required bool isActive,
    required bool isDone,
  }) {
    Color color = isDone
        ? const Color(0xFF10B981)
        : isActive
            ? const Color(0xFFE25822)
            : const Color(0xFF2D323A);

    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone || isActive ? color : const Color(0xFF1E2228),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isDone || isActive ? Colors.white : Colors.white38,
            fontSize: 10,
            fontWeight: isDone || isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressConnector({required bool isDone}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isDone ? const Color(0xFF10B981) : const Color(0xFF2D323A),
      ),
    );
  }
}
