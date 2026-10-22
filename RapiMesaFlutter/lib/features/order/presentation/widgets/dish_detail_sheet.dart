import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dish_model.dart';

class DishDetailSheet extends StatefulWidget {
  final DishItem dish;
  final Function(List<ExtraIngredient> extras, String notes) onConfirm;

  const DishDetailSheet({
    super.key,
    required this.dish,
    required this.onConfirm,
  });

  @override
  State<DishDetailSheet> createState() => _DishDetailSheetState();
}

class _DishDetailSheetState extends State<DishDetailSheet> {
  final List<ExtraIngredient> _selectedExtras = [];
  final TextEditingController _notesController = TextEditingController();

  // Lista de extras por defecto si el platillo no trae específicos
  List<ExtraIngredient> get _effectiveExtras {
    if (widget.dish.availableExtras.isNotEmpty) {
      return widget.dish.availableExtras;
    }
    return const [
      ExtraIngredient(id: 'def_1', name: 'Porción Extra / Doble', extraPrice: 2.50),
      ExtraIngredient(id: 'def_2', name: 'Queso fundido extra', extraPrice: 1.80),
      ExtraIngredient(id: 'def_3', name: 'Salsa especial de la casa', extraPrice: 1.00),
      ExtraIngredient(id: 'def_4', name: 'Guarnición de papas rústicas', extraPrice: 3.00),
    ];
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    final extrasCost = _selectedExtras.fold<double>(0.0, (sum, extra) => sum + extra.extraPrice);
    return widget.dish.price + extrasCost;
  }

  @override
  Widget build(BuildContext context) {
    final extras = _effectiveExtras;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra superior
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

              // Imagen y datos del platillo
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 85,
                      height: 85,
                      color: const Color(0xFF131518),
                      child: Image.network(
                        widget.dish.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.restaurant,
                          color: Color(0xFFE25822),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.dish.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.dish.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${widget.dish.price.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE25822),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Sección de Extras / Ingredientes Obligatorios a revisar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ingredientes & Extras para este platillo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE25822).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Personalizable',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFE25822),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...extras.map((extra) {
                final isSelected = _selectedExtras.contains(extra);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedExtras.remove(extra);
                        } else {
                          _selectedExtras.add(extra);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF282D36) : const Color(0xFF131518),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFE25822) : const Color(0xFF2D323A),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            extra.name,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              if (extra.extraPrice > 0)
                                Text(
                                  '+\$${extra.extraPrice.toStringAsFixed(2)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFE25822),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              const SizedBox(width: 10),
                              Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                color: isSelected ? const Color(0xFFE25822) : Colors.white30,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Notas para Cocina
              Text(
                'Instrucciones Especiales para Cocina',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ej. Término medio, sin cebolla, aderezo aparte...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF131518),
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

              const SizedBox(height: 22),

              // Botón Confirmar y Agregar a Comanda
              ElevatedButton(
                onPressed: () {
                  widget.onConfirm(_selectedExtras, _notesController.text.trim());
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE25822),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_shopping_cart, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Confirmar y Agregar • \$${_totalPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
  }
}
