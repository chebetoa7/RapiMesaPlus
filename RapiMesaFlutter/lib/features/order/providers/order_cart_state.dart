import 'package:flutter/foundation.dart';
import '../models/dish_model.dart';

class OrderCartState extends ChangeNotifier {
  final String tableIdentifier;
  final List<OrderCartLine> _items = [];
  double _tipPercentage = 0.10; // 10% por defecto

  OrderCartState({this.tableIdentifier = 'Mesa 4'});

  List<OrderCartLine> get items => List.unmodifiable(_items);
  double get tipPercentage => _tipPercentage;

  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalLinePrice);

  double get tipAmount => subtotal * _tipPercentage;

  double get totalWithTip => subtotal + tipAmount;

  void addDish(DishItem dish, {List<ExtraIngredient> extras = const [], String notes = ''}) {
    // Si ya existe exactamente el mismo platillo con los mismos extras y notas, incrementamos
    final existingIndex = _items.indexWhere((line) =>
        line.dish.id == dish.id &&
        listEquals(line.selectedExtras, extras) &&
        line.kitchenNotes == notes);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(OrderCartLine(
        dish: dish,
        quantity: 1,
        selectedExtras: extras,
        kitchenNotes: notes,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(int index, int delta) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity += delta;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void setTipPercentage(double percentage) {
    _tipPercentage = percentage;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
