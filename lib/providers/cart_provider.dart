import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';

/// App-wide shopping cart state.
///
/// Enforces the common food-delivery rule that one cart belongs to exactly
/// one restaurant: adding an item from a different restaurant requires the
/// caller to confirm first (see [canAddWithoutClearing]) and then call
/// [replaceCart], which empties the previous cart.
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = <CartItem>[];

  /// Unmodifiable view of the current cart items.
  List<CartItem> get items => List<CartItem>.unmodifiable(_items);

  /// Whether the cart holds at least one line item.
  bool get hasItems => _items.isNotEmpty;

  /// Sum of all item quantities, e.g. 2× Pizza + 1× Drink = 3.
  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Sum of every line item's subtotal.
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  /// Total price formatted for display, e.g. `'PKR 3,697'`.
  String get formattedTotalPrice => formatPKR(totalPrice);

  /// Name of the restaurant the cart currently belongs to (null if empty).
  String? get restaurantName =>
      _items.isEmpty ? null : _items.first.restaurantName;

  /// Id of the restaurant the cart currently belongs to (null if empty).
  String? get restaurantId => _items.isEmpty ? null : _items.first.restaurantId;

  /// Whether [restaurantId] can be added to without wiping anything.
  bool canAddWithoutClearing(String restaurantId) =>
      _items.isEmpty || _items.first.restaurantId == restaurantId;

  /// Current quantity of [menuItemName] in the cart (0 if absent).
  int quantityOf(String menuItemName) {
    for (final item in _items) {
      if (item.menuItemName == menuItemName) return item.quantity;
    }
    return 0;
  }

  /// Adds [item]; bumps the quantity if the same item already exists.
  void addItem(CartItem item) {
    final index = _items.indexWhere(
      (existing) =>
          existing.menuItemName == item.menuItemName &&
          existing.restaurantId == item.restaurantId,
    );
    if (index == -1) {
      _items.add(item);
    } else {
      _items[index] =
          _items[index].copyWith(quantity: _items[index].quantity + 1);
    }
    notifyListeners();
  }

  /// Clears the cart and starts it with [item] (restaurant switch flow).
  void replaceCart(CartItem item) {
    _items
      ..clear()
      ..add(item);
    notifyListeners();
  }

  /// Removes every trace of [menuItemName] from the cart.
  void removeItem(String menuItemName) {
    _items.removeWhere((item) => item.menuItemName == menuItemName);
    notifyListeners();
  }

  /// Increments the quantity of [menuItemName] (no-op if absent).
  void increaseQuantity(String menuItemName) {
    final index =
        _items.indexWhere((item) => item.menuItemName == menuItemName);
    if (index == -1) return;
    _items[index] =
        _items[index].copyWith(quantity: _items[index].quantity + 1);
    notifyListeners();
  }

  /// Decrements the quantity of [menuItemName]; reaching 0 removes the item.
  void decreaseQuantity(String menuItemName) {
    final index =
        _items.indexWhere((item) => item.menuItemName == menuItemName);
    if (index == -1) return;
    final newQuantity = _items[index].quantity - 1;
    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
    }
    notifyListeners();
  }

  /// Empties the cart completely.
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
