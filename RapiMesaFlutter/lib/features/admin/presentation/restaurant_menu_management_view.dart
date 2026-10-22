import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/config/api_config.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../order/models/dish_model.dart';

class RestaurantMenuManagementView extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final String adminEmail;

  const RestaurantMenuManagementView({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    required this.adminEmail,
  });

  @override
  State<RestaurantMenuManagementView> createState() => _RestaurantMenuManagementViewState();
}

class _RestaurantMenuManagementViewState extends State<RestaurantMenuManagementView> {
  bool _isLoading = false;
  final List<MenuCategory> _categories = [];
  String _selectedCategoryId = '';
  final Map<String, List<DishItem>> _dishesByCategory = {};

  List<String> get _baseEndpoints => [
        for (final base in ApiConfig.candidates) '$base/api/menu',
      ];

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    if (widget.restaurantId.isEmpty) return;
    setState(() => _isLoading = true);

    for (final base in _baseEndpoints) {
      try {
        final resp = await ApiClient.get(
          '$base/restaurant/${widget.restaurantId}',
          timeout: const Duration(seconds: 4),
        );
        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body);
          if (body['success'] == true && body['data'] != null) {
            final rawCategories = body['data']['menuCategories'] as List? ?? [];
            _categories.clear();
            _dishesByCategory.clear();

            for (final catJson in rawCategories) {
              final cat = MenuCategory.fromDataConnect(catJson as Map<String, dynamic>);
              _categories.add(cat);

              final rawItems = catJson['menuItems_on_category'] as List? ?? [];
              final items = rawItems
                  .map((i) => DishItem.fromDataConnect(i as Map<String, dynamic>, categoryId: cat.id))
                  .toList();
              _dishesByCategory[cat.id] = items;
            }

            if (_categories.isNotEmpty) {
              if (!_categories.any((c) => c.id == _selectedCategoryId)) {
                _selectedCategoryId = _categories.first.id;
              }
            } else {
              _selectedCategoryId = '';
            }

            break;
          }
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // DIÁLOGO: CREAR NUEVA CATEGORÍA (ELIGE DEL CATÁLOGO ESTANDARIZADO O PERSONALIZA)
  void _showAddCategoryDialog() {
    final customNameController = TextEditingController();
    final customIconController = TextEditingController();
    MenuCategory? selectedTaxonomy = MenuCategory.masterTaxonomy.first;
    bool isCustom = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E2228),
      barrierColor: Colors.black.withOpacity(0.75),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dar de Alta Categoría',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Selecciona una sección estandarizada para garantizar orden en el menú:',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(height: 14),

                    // Selector: Catálogo Estándar vs Personalizado
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Catálogo Estandarizado'),
                          selected: !isCustom,
                          onSelected: (val) => setModalState(() => isCustom = !val),
                          selectedColor: const Color(0xFFE25822),
                          labelStyle: TextStyle(color: !isCustom ? Colors.white : Colors.white70),
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Personalizada'),
                          selected: isCustom,
                          onSelected: (val) => setModalState(() => isCustom = val),
                          selectedColor: const Color(0xFFE25822),
                          labelStyle: TextStyle(color: isCustom ? Colors.white : Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (!isCustom) ...[
                      // Lista de Categorías Estandarizadas con Grupos
                      Expanded(
                        child: ListView.separated(
                          itemCount: MenuCategory.masterTaxonomy.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final tax = MenuCategory.masterTaxonomy[index];
                            final isPicked = selectedTaxonomy?.id == tax.id;

                            return InkWell(
                              onTap: () => setModalState(() => selectedTaxonomy = tax),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isPicked
                                      ? const Color(0xFFE25822).withOpacity(0.18)
                                      : const Color(0xFF252A32),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isPicked ? const Color(0xFFE25822) : const Color(0xFF2D323A),
                                    width: isPicked ? 1.8 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipOval(
                                      child: Image.network(
                                        tax.imageUrl,
                                        width: 38,
                                        height: 38,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Text(tax.emoji ?? '🍽️', style: const TextStyle(fontSize: 20)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tax.name,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (tax.group != null)
                                            Text(
                                              tax.group!,
                                              style: GoogleFonts.plusJakartaSans(
                                                color: const Color(0xFFE25822),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (isPicked)
                                      const Icon(Icons.check_circle, color: Color(0xFFE25822), size: 22),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      // Formulario Personalizado
                      TextField(
                        controller: customNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nombre de la Categoría',
                          labelStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: const Color(0xFF131518),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: customIconController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'URL de Imagen Ilustrativa (Opcional)',
                          labelStyle: const TextStyle(color: Colors.white60),
                          filled: true,
                          fillColor: const Color(0xFF131518),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const Spacer(),
                    ],

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final catName = isCustom ? customNameController.text.trim() : (selectedTaxonomy?.name ?? '');
                        final iconUrl = isCustom ? customIconController.text.trim() : (selectedTaxonomy?.imageUrl ?? '');

                        if (catName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor escribe o selecciona un nombre de categoría')),
                          );
                          return;
                        }

                        Navigator.pop(ctx);
                        await _createCategoryOnBackend(name: catName, iconUrl: iconUrl);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE25822),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Guardar Sección en Menú',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
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

  Future<void> _createCategoryOnBackend({required String name, required String iconUrl}) async {
    setState(() => _isLoading = true);
    String lastError = 'sin respuesta del servidor';
    for (final base in _baseEndpoints) {
      try {
        final resp = await ApiClient.post(
          '$base/category',
          body: {
            'restaurantId': widget.restaurantId,
            'name': name,
            'iconUrl': iconUrl,
            'sortOrder': _categories.length + 1,
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Categoría "$name" agregada con éxito'), backgroundColor: Colors.green),
            );
          }
          await _fetchMenu();
          return;
        }
        lastError = _readApiError(resp);
      } catch (e) {
        lastError = e.toString();
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo crear la categoría: $lastError'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  // DIÁLOGO: CREAR / EDITAR PLATILLO O BEBIDA (CON INGREDIENTES EXTRA DINÁMICOS)
  void _showDishEditorDialog({DishItem? existingDish}) {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero da de alta al menos una categoría.')),
      );
      return;
    }

    final nameController = TextEditingController(text: existingDish?.name ?? '');
    final descController = TextEditingController(text: existingDish?.description ?? '');
    final priceController = TextEditingController(text: existingDish != null ? existingDish.price.toStringAsFixed(2) : '');
    final imageController = TextEditingController(text: existingDish?.imageUrl ?? '');
    String categoryId = existingDish?.categoryId ?? _selectedCategoryId;
    if (!_categories.any((c) => c.id == categoryId)) {
      categoryId = _categories.first.id;
    }

    bool isAvailable = existingDish?.isAvailable ?? true;
    final List<ExtraIngredient> extras = List.from(existingDish?.availableExtras ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E2228),
      barrierColor: Colors.black.withOpacity(0.75),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existingDish == null ? 'Nuevo Platillo / Bebida' : 'Editar Producto',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selector de Categoría
                            Text('Sección / Categoría:', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131518),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF2D323A)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: categoryId,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1E2228),
                                  items: _categories.map((c) {
                                    return DropdownMenuItem(
                                      value: c.id,
                                      child: Row(
                                        children: [
                                          Text(c.emoji ?? '🍽️', style: const TextStyle(fontSize: 16)),
                                          const SizedBox(width: 10),
                                          Text(c.name, style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => categoryId = val);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Nombre del Platillo
                            TextField(
                              controller: nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Nombre del Platillo / Bebida (Ej. Burrito de Arrachera)',
                                labelStyle: const TextStyle(color: Colors.white60),
                                filled: true,
                                fillColor: const Color(0xFF131518),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Precio Base
                            TextField(
                              controller: priceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Precio Base (\$ MXN / USD)',
                                prefixText: '\$ ',
                                prefixStyle: const TextStyle(color: Color(0xFFE25822), fontWeight: FontWeight.bold),
                                labelStyle: const TextStyle(color: Colors.white60),
                                filled: true,
                                fillColor: const Color(0xFF131518),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Descripción y Características
                            TextField(
                              controller: descController,
                              maxLines: 2,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Descripción / Características (Ingredientes, tamaño)',
                                labelStyle: const TextStyle(color: Colors.white60),
                                filled: true,
                                fillColor: const Color(0xFF131518),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Imagen URL y Vista Previa
                            TextField(
                              controller: imageController,
                              onChanged: (_) => setModalState(() {}),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'URL de Imagen del Platillo',
                                labelStyle: const TextStyle(color: Colors.white60),
                                filled: true,
                                fillColor: const Color(0xFF131518),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Fotos rápidas recomendadas
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Text('Sugeridas: ', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 11)),
                                  _buildPhotoChip('Burrito', 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600&q=80', imageController, setModalState),
                                  _buildPhotoChip('Tacos', 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=600&q=80', imageController, setModalState),
                                  _buildPhotoChip('Pizza', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&q=80', imageController, setModalState),
                                  _buildPhotoChip('Hamburguesa', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80', imageController, setModalState),
                                  _buildPhotoChip('Corte', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&q=80', imageController, setModalState),
                                  _buildPhotoChip('Bebida', 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600&q=80', imageController, setModalState),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // SECCIÓN DE INGREDIENTES EXTRA
                            Container(
                              padding: const EdgeInsets.all(14),
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
                                      Text(
                                        'Ingredientes Extra & Opciones',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          _showAddExtraDialog(context, (newExtra) {
                                            setModalState(() {
                                              extras.add(newExtra);
                                            });
                                          });
                                        },
                                        icon: const Icon(Icons.add, color: Color(0xFFE25822), size: 18),
                                        label: Text(
                                          '+ Agregar Extra',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFFE25822),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (extras.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Text(
                                        'Sin extras agregados (ej. Queso Extra +\$2.50, Guacamole +\$3.00)',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 12),
                                      ),
                                    )
                                  else
                                    ...extras.asMap().entries.map((entry) {
                                      final idx = entry.key;
                                      final ex = entry.value;
                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E2228),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(ex.name, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
                                            Row(
                                              children: [
                                                Text(
                                                  '+ \$${ex.extraPrice.toStringAsFixed(2)}',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: const Color(0xFFE25822),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                InkWell(
                                                  onTap: () => setModalState(() => extras.removeAt(idx)),
                                                  child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Switch de Disponibilidad
                            SwitchListTile(
                              value: isAvailable,
                              onChanged: (val) => setModalState(() => isAvailable = val),
                              title: Text(
                                isAvailable ? 'Producto Disponible' : 'Pausado / Agotado',
                                style: GoogleFonts.plusJakartaSans(
                                  color: isAvailable ? const Color(0xFF10B981) : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              activeColor: const Color(0xFF10B981),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                        final desc = descController.text.trim();
                        final img = imageController.text.trim();

                        if (name.isEmpty || price <= 0.0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor completa el nombre y un precio válido.')),
                          );
                          return;
                        }

                        Navigator.pop(ctx);
                        await _saveDishOnBackend(
                          id: existingDish?.id,
                          categoryId: categoryId,
                          name: name,
                          description: desc,
                          price: price,
                          imageUrl: img,
                          isAvailable: isAvailable,
                          extras: extras,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE25822),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        existingDish == null ? 'Guardar en el Menú' : 'Actualizar Producto',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
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

  Widget _buildPhotoChip(String label, String url, TextEditingController controller, StateSetter setModalState) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        backgroundColor: const Color(0xFF1E2228),
        onPressed: () => setModalState(() => controller.text = url),
      ),
    );
  }

  void _showAddExtraDialog(BuildContext context, Function(ExtraIngredient) onAdd) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2228),
          title: Text('Añadir Ingrediente Extra', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Nombre del Extra (Ej. Queso Extra)', labelStyle: TextStyle(color: Colors.white60)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Costo Adicional (\$)', labelStyle: TextStyle(color: Colors.white60)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: () {
                final exName = nameCtrl.text.trim();
                final exPrice = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                if (exName.isNotEmpty) {
                  onAdd(ExtraIngredient(
                    id: 'ex-${DateTime.now().microsecondsSinceEpoch}',
                    name: exName,
                    extraPrice: exPrice,
                  ));
                }
                Navigator.pop(dCtx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE25822)),
              child: const Text('Añadir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDishOnBackend({
    String? id,
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isAvailable,
    required List<ExtraIngredient> extras,
  }) async {
    setState(() => _isLoading = true);
    String lastError = 'sin respuesta del servidor';

    for (final base in _baseEndpoints) {
      try {
        final isEdit = id != null && id.isNotEmpty;
        final url = isEdit ? '$base/item/$id' : '$base/item';

        final payload = {
          'restaurantId': widget.restaurantId,
          'categoryId': categoryId,
          'name': name,
          'description': description,
          'price': price,
          'imageUrl': imageUrl,
          'isAvailable': isAvailable,
          'extras': extras.map((e) => e.toJson()).toList(),
        };

        final resp = isEdit
            ? await ApiClient.patch(url, body: payload)
            : await ApiClient.post(url, body: payload);

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isEdit ? 'Producto actualizado' : 'Producto agregado con éxito'), backgroundColor: Colors.green),
            );
          }
          await _fetchMenu();
          return;
        }
        // Antes el fallo se tragaba en silencio y el usuario solo veía que el
        // producto no aparecía, sin ninguna explicación.
        lastError = _readApiError(resp);
      } catch (e) {
        lastError = e.toString();
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar el producto: $lastError'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  /// Extrae el mensaje de error del backend para mostrarlo al usuario.
  static String _readApiError(dynamic resp) {
    try {
      final body = resp.body?.toString() ?? '';
      final data = jsonDecode(body);
      if (data is Map && data['error'] != null) return data['error'].toString();
      return 'HTTP ${resp.statusCode}';
    } catch (_) {
      return 'HTTP ${resp.statusCode}';
    }
  }

  Future<void> _toggleAvailability(DishItem dish) async {
    final nextState = !dish.isAvailable;
    String lastError = 'sin respuesta del servidor';
    for (final base in _baseEndpoints) {
      try {
        final resp = await ApiClient.patch(
          '$base/item/${dish.id}',
          body: {
            'isAvailable': nextState,
            'restaurantId': widget.restaurantId,
          },
        );
        if (resp.statusCode == 200) {
          await _fetchMenu();
          return;
        }
        lastError = _readApiError(resp);
      } catch (e) {
        lastError = e.toString();
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cambiar la disponibilidad: $lastError'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _deleteDish(DishItem dish) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: const Color(0xFF1E2228),
        title: const Text('¿Eliminar producto?', style: TextStyle(color: Colors.white)),
        content: Text('¿Deseas eliminar "${dish.name}" permanentemente?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            onPressed: () => Navigator.pop(d, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    String lastError = 'sin respuesta del servidor';
    for (final base in _baseEndpoints) {
      try {
        final url = '$base/item/${dish.id}?restaurantId=${widget.restaurantId}';
        final resp = await ApiClient.delete(url);
        if (resp.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Producto eliminado'), backgroundColor: Colors.orange),
            );
          }
          await _fetchMenu();
          return;
        }
        lastError = _readApiError(resp);
      } catch (e) {
        lastError = e.toString();
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar el producto: $lastError'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDishes = _dishesByCategory[_selectedCategoryId] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF131518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2228),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestión de Menú & Carta',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            Text(
              widget.restaurantName,
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFFE25822), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Recargar Carta',
            onPressed: _fetchMenu,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE25822)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de Acciones Rápidas del Menú
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFF181B20),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _showAddCategoryDialog,
                        icon: const Icon(Icons.category, size: 16),
                        label: Text('+ Sección / Categoría', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2228),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF2D323A)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => _showDishEditorDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('+ Nuevo Platillo / Bebida', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE25822),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selector Horizontal de Categorías
                if (_categories.isNotEmpty) ...[
                  Container(
                    height: 52,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = cat.id == _selectedCategoryId;

                        return InkWell(
                          onTap: () => setState(() => _selectedCategoryId = cat.id),
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE25822).withOpacity(0.2) : const Color(0xFF1E2228),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFE25822) : const Color(0xFF2D323A),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (cat.imageUrl.isNotEmpty)
                                  ClipOval(
                                    child: Image.network(
                                      cat.imageUrl,
                                      width: 26,
                                      height: 26,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Text(cat.emoji ?? '🍽️', style: const TextStyle(fontSize: 16)),
                                    ),
                                  )
                                else
                                  Text(cat.emoji ?? '🍽️', style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  cat.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Lista de Platillos de la Categoría Seleccionada
                Expanded(
                  child: _categories.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.restaurant_menu, color: Colors.white24, size: 56),
                                const SizedBox(height: 14),
                                Text(
                                  'Aún no hay categorías en este restaurante',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Agrega secciones desde el catálogo estandarizado para empezar a crear platillos y bebidas.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 13),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: _showAddCategoryDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar Primera Sección'),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE25822)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : currentDishes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.fastfood_outlined, color: Colors.white24, size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No hay productos en esta sección',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 14),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    onPressed: () => _showDishEditorDialog(),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Agregar Platillo o Bebida'),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE25822)),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: currentDishes.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final dish = currentDishes[index];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E2228),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: dish.isAvailable ? const Color(0xFF2D323A) : Colors.redAccent.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Imagen del Platillo
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          dish.imageUrl,
                                          width: 68,
                                          height: 68,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 68,
                                            height: 68,
                                            color: const Color(0xFF131518),
                                            child: const Icon(Icons.restaurant, color: Colors.white24),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Datos del Platillo
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    dish.name,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '\$${dish.price.toStringAsFixed(2)}',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: const Color(0xFFE25822),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              dish.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 12),
                                            ),
                                            const SizedBox(height: 6),
                                            if (dish.availableExtras.isNotEmpty)
                                              Text(
                                                '${dish.availableExtras.length} extras disponibles',
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: const Color(0xFF10B981),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Acciones: Disponibilidad, Editar, Eliminar
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              dish.isAvailable ? Icons.check_circle : Icons.pause_circle_filled,
                                              color: dish.isAvailable ? const Color(0xFF10B981) : Colors.redAccent,
                                              size: 24,
                                            ),
                                            tooltip: dish.isAvailable ? 'Disponible (clic para pausar)' : 'Pausado (clic para activar)',
                                            onPressed: () => _toggleAvailability(dish),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                                                tooltip: 'Editar',
                                                onPressed: () => _showDishEditorDialog(existingDish: dish),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                                tooltip: 'Eliminar',
                                                onPressed: () => _deleteDish(dish),
                                              ),
                                            ],
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
            ),
    );
  }
}
