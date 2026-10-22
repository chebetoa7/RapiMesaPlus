import 'dart:convert';

class MenuCategory {
  final String id;
  final String name;
  final String imageUrl;
  final String? emoji;
  final String? group;

  const MenuCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.emoji,
    this.group,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'emoji': emoji,
    'group': group,
  };

  factory MenuCategory.fromDataConnect(Map<String, dynamic> json) {
    final catName = json['name']?.toString() ?? '';
    return MenuCategory(
      id: json['id']?.toString() ?? '',
      name: catName,
      imageUrl: json['iconUrl']?.toString() ?? '',
      emoji: _suggestEmoji(catName),
    );
  }

  static String _suggestEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('taco') || lower.contains('burrito') || lower.contains('antojito')) return '🌯';
    if (lower.contains('entrada') || lower.contains('botana') || lower.contains('alita') || lower.contains('papas')) return '🍟';
    if (lower.contains('pizza')) return '🍕';
    if (lower.contains('pasta') || lower.contains('lasa')) return '🍝';
    if (lower.contains('corte') || lower.contains('carne') || lower.contains('steak')) return '🥩';
    if (lower.contains('hamburguesa') || lower.contains('burger')) return '🍔';
    if (lower.contains('pollo') || lower.contains('boneless')) return '🍗';
    if (lower.contains('marisco') || lower.contains('pescado') || lower.contains('ceviche')) return '🍤';
    if (lower.contains('ensalada') || lower.contains('sopa') || lower.contains('bowl')) return '🥗';
    if (lower.contains('guarnicion') || lower.contains('extra')) return '🍚';
    if (lower.contains('postre') || lower.contains('pastel') || lower.contains('helado')) return '🍰';
    if (lower.contains('café') || lower.contains('cafe')) return '☕';
    if (lower.contains('cerveza') || lower.contains('vino')) return '🍷';
    if (lower.contains('coctel') || lower.contains('bebida') || lower.contains('trago')) return '🍹';
    if (lower.contains('desayuno') || lower.contains('huevo') || lower.contains('hotcake')) return '🥞';
    if (lower.contains('infantil') || lower.contains('kid')) return '🧒';
    return '🍽️';
  }

  // Catálogo Maestro Estandarizado de 17 Secciones Gastronómicas
  static const List<MenuCategory> masterTaxonomy = [
    MenuCategory(
      id: 'tacos_burritos',
      name: 'Tacos, Burritos & Antojitos',
      group: 'Tradición & Antojitos',
      imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=300&q=80',
      emoji: '🌯',
    ),
    MenuCategory(
      id: 'entradas_botanas',
      name: 'Entradas & Botanas',
      group: 'Aperitivos & Inicio',
      imageUrl: 'https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=300&q=80',
      emoji: '🍟',
    ),
    MenuCategory(
      id: 'pizzas',
      name: 'Pizzas Artesanales',
      group: 'Platos Fuertes',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300&q=80',
      emoji: '🍕',
    ),
    MenuCategory(
      id: 'pastas_risottos',
      name: 'Pastas & Risottos',
      group: 'Platos Fuertes',
      imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281724?w=300&q=80',
      emoji: '🍝',
    ),
    MenuCategory(
      id: 'hamburguesas_sandwiches',
      name: 'Hamburguesas & Sandwiches',
      group: 'Platos Fuertes',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&q=80',
      emoji: '🍔',
    ),
    MenuCategory(
      id: 'cortes_carnes',
      name: 'Cortes & Carnes',
      group: 'Platos Fuertes',
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=300&q=80',
      emoji: '🥩',
    ),
    MenuCategory(
      id: 'aves_pollo',
      name: 'Aves & Pollo',
      group: 'Platos Fuertes',
      imageUrl: 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=300&q=80',
      emoji: '🍗',
    ),
    MenuCategory(
      id: 'pescados_mariscos',
      name: 'Pescados & Mariscos',
      group: 'Platos Fuertes',
      imageUrl: 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=300&q=80',
      emoji: '🍤',
    ),
    MenuCategory(
      id: 'ensaladas_sopas',
      name: 'Ensaladas & Sopas',
      group: 'Ligeros & Saludables',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=300&q=80',
      emoji: '🥗',
    ),
    MenuCategory(
      id: 'guarniciones_extras',
      name: 'Guarniciones & Extras',
      group: 'Acompañamientos',
      imageUrl: 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=300&q=80',
      emoji: '🍚',
    ),
    MenuCategory(
      id: 'postres',
      name: 'Postres & Repostería',
      group: 'Dulces & Final',
      imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=300&q=80',
      emoji: '🍰',
    ),
    MenuCategory(
      id: 'aguas_refrescos',
      name: 'Aguas Frescas & Refrescos',
      group: 'Bebidas Sin Alcohol',
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=300&q=80',
      emoji: '🥤',
    ),
    MenuCategory(
      id: 'cafeteria_te',
      name: 'Cafetería & Té',
      group: 'Cafetería & Calientes',
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=300&q=80',
      emoji: '☕',
    ),
    MenuCategory(
      id: 'cervezas_vinos',
      name: 'Cervezas & Vinos',
      group: 'Bebidas Con Alcohol',
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=300&q=80',
      emoji: '🍷',
    ),
    MenuCategory(
      id: 'cocteleria_tragos',
      name: 'Coctelería & Tragos',
      group: 'Bebidas Con Alcohol',
      imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=300&q=80',
      emoji: '🍹',
    ),
    MenuCategory(
      id: 'desayunos_brunch',
      name: 'Desayunos & Brunch',
      group: 'Menús Especiales',
      imageUrl: 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=300&q=80',
      emoji: '🥞',
    ),
    MenuCategory(
      id: 'menu_infantil',
      name: 'Menú Infantil (Kids)',
      group: 'Menús Especiales',
      imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=300&q=80',
      emoji: '🧒',
    ),
  ];

  static const List<MenuCategory> sampleCategories = [
    MenuCategory(
      id: 'Pizzas',
      name: 'Pizzas',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&q=80',
      emoji: '🍕',
    ),
    MenuCategory(
      id: 'Pastas',
      name: 'Pastas',
      imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281724?w=200&q=80',
      emoji: '🍝',
    ),
    MenuCategory(
      id: 'Cortes & Carnes',
      name: 'Cortes & Carnes',
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=200&q=80',
      emoji: '🥩',
    ),
    MenuCategory(
      id: 'Ensaladas',
      name: 'Ensaladas',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200&q=80',
      emoji: '🥗',
    ),
    MenuCategory(
      id: 'Postres',
      name: 'Postres',
      imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=200&q=80',
      emoji: '🍰',
    ),
    MenuCategory(
      id: 'Bebidas',
      name: 'Bebidas',
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=200&q=80',
      emoji: '🍹',
    ),
  ];
}

class ExtraIngredient {
  final String id;
  final String name;
  final double extraPrice;

  const ExtraIngredient({
    required this.id,
    required this.name,
    this.extraPrice = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'extraPrice': extraPrice,
  };

  factory ExtraIngredient.fromJson(Map<String, dynamic> json) {
    return ExtraIngredient(
      id: json['id']?.toString() ?? 'ex-${DateTime.now().microsecondsSinceEpoch}',
      name: json['name']?.toString() ?? '',
      extraPrice: (json['extraPrice'] ?? json['price'] ?? 0.0).toDouble(),
    );
  }
}

class DishItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String imageUrl;
  final bool isAvailable;
  final List<ExtraIngredient> availableExtras;

  const DishItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.imageUrl,
    this.isAvailable = true,
    this.availableExtras = const [],
  });

  factory DishItem.fromDataConnect(Map<String, dynamic> json, {required String categoryId}) {
    final rawDescription = json['description']?.toString() ?? '';
    String cleanDescription = rawDescription;
    List<ExtraIngredient> extras = [];

    if (rawDescription.contains('__EXTRAS__:')) {
      final parts = rawDescription.split('__EXTRAS__:');
      cleanDescription = parts[0].trim();
      try {
        final decoded = jsonDecode(parts[1]);
        if (decoded is List) {
          extras = decoded.map((e) => ExtraIngredient.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }

    return DishItem(
      id: json['id']?.toString() ?? '',
      categoryId: categoryId,
      name: json['name']?.toString() ?? '',
      description: cleanDescription,
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      isAvailable: json['isAvailable'] == null ? true : (json['isAvailable'] == true),
      availableExtras: extras,
    );
  }

  static const List<DishItem> sampleDishes = [
    // Pizzas
    DishItem(
      id: 'p1',
      categoryId: 'Pizzas',
      name: 'Pizza Artesanal Rústica',
      description: 'Masa madre, salsa pomodoro San Marzano, mozzarella di bufala y albahaca fresca.',
      price: 18.50,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&q=80',
      availableExtras: [
        ExtraIngredient(id: 'e1', name: 'Queso Extra Fundido', extraPrice: 2.50),
        ExtraIngredient(id: 'e2', name: 'Prosciutto San Daniele', extraPrice: 3.50),
        ExtraIngredient(id: 'e3', name: 'Aceite de Trufa Italiana', extraPrice: 2.00),
      ],
    ),
    DishItem(
      id: 'p2',
      categoryId: 'Pizzas',
      name: 'Pizza Cuatro Quesos & Miel',
      description: 'Mozzarella, gorgonzola, parmesano reggiano y ricotta con toque de miel de romero.',
      price: 21.00,
      imageUrl: 'https://images.unsplash.com/photo-1573821663912-569905455b1c?w=600&q=80',
      availableExtras: [
        ExtraIngredient(id: 'e4', name: 'Nueces caramelizadas', extraPrice: 1.50),
        ExtraIngredient(id: 'e4b', name: 'Masa delgada crujiente', extraPrice: 0.00),
      ],
    ),
    // Pastas
    DishItem(
      id: 'pa1',
      categoryId: 'Pastas',
      name: 'Tagliatelle al Tartufo',
      description: 'Pasta fresca hecha a mano, crema de trufa negra y lascas de parmesano de 24 meses.',
      price: 24.00,
      imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281724?w=600&q=80',
      availableExtras: [
        ExtraIngredient(id: 'e5', name: 'Hongo Porcini extra', extraPrice: 4.00),
        ExtraIngredient(id: 'e5b', name: 'Queso Parmesano extra', extraPrice: 2.00),
      ],
    ),
    DishItem(
      id: 'pa2',
      categoryId: 'Pastas',
      name: 'Ravioli de Espinaca & Ricotta',
      description: 'Bañados en mantequilla clarificada con salvia crujiente.',
      price: 19.50,
      imageUrl: 'https://images.unsplash.com/photo-1587740908075-9e245070dfaa?w=600&q=80',
      availableExtras: [
        ExtraIngredient(id: 'e5c', name: 'Salsa Pomodoro adicional', extraPrice: 2.00),
      ],
    ),
    // Cortes
    DishItem(
      id: 'c1',
      categoryId: 'Cortes & Carnes',
      name: 'Ribeye Black Angus (400g)',
      description: 'Sellado al grill con mantequilla de hierbas, acompañado de papas rústicas al romero.',
      price: 36.00,
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&q=80',
      availableExtras: [
        ExtraIngredient(id: 'e6', name: 'Espárragos salteados al grill', extraPrice: 4.50),
        ExtraIngredient(id: 'e7', name: 'Salsa Pimienta Negra', extraPrice: 2.00),
      ],
    ),
    // Ensaladas
    DishItem(
      id: 'e1',
      categoryId: 'Ensaladas',
      name: 'Ensalada Burrata & Higos',
      description: 'Mix de hojas orgánicas, higos caramelizados, reducción balsámica y nuez pecana.',
      price: 16.00,
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      availableExtras: [
        ExtraIngredient(id: 'e8', name: 'Pechuga a la plancha extra', extraPrice: 3.50),
        ExtraIngredient(id: 'e9', name: 'Aderezo Balsámico aparte', extraPrice: 0.00),
      ],
    ),
    // Postres
    DishItem(
      id: 'd1',
      categoryId: 'Postres',
      name: 'Tiramisú Tradicional de la Casa',
      description: 'Mascarpone artesanal, savoiardi embebidos en espresso Illy y cacao amargo.',
      price: 9.50,
      imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=600&q=80',
      availableExtras: [
        ExtraIngredient(id: 'e10', name: 'Bola de helado de vainilla', extraPrice: 2.50),
      ],
    ),
    // Bebidas
    DishItem(
      id: 'b1',
      categoryId: 'Bebidas',
      name: 'Mocktail Frutos Rojos & Menta',
      description: 'Infusión artesanal de zarzamora, limón persa y agua con gas San Pellegrino.',
      price: 6.50,
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600&q=80',
      availableExtras: [
        ExtraIngredient(id: 'e11', name: 'Extra hielo frappé', extraPrice: 0.00),
        ExtraIngredient(id: 'e12', name: 'Sin endulzante', extraPrice: 0.00),
      ],
    ),
  ];
}

class OrderCartLine {
  final DishItem dish;
  int quantity;
  final List<ExtraIngredient> selectedExtras;
  final String kitchenNotes;

  OrderCartLine({
    required this.dish,
    this.quantity = 1,
    this.selectedExtras = const [],
    this.kitchenNotes = '',
  });

  double get unitPrice {
    final extrasCost = selectedExtras.fold<double>(0.0, (sum, extra) => sum + extra.extraPrice);
    return dish.price + extrasCost;
  }

  double get totalLinePrice => unitPrice * quantity;
}
