/// Data model for one row of the shopping cart.
///
/// A [CartItem] remembers which restaurant the item came from so the cart
/// can enforce the "one restaurant per cart" rule. The numeric unit price
/// is kept next to the display label so subtotals never depend on parsing
/// formatted strings at render time.
library;

/// Extracts the numeric value out of a display price such as
/// `'PKR 1,199'` → `1199.0`. Used when moving menu items into the cart;
/// once the menu comes from Firestore this will be replaced by a real
/// numeric field.
double parsePriceValue(String displayPrice) {
  return double.tryParse(
        displayPrice.replaceAll(RegExp(r'[^0-9.]'), ''),
      ) ??
      0;
}

/// Formats an amount as a PKR label with thousands separators,
/// e.g. `1199` → `'PKR 1,199'`.
String formatPKR(num amount) {
  final digits = amount.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  return 'PKR $buffer';
}

class CartItem {
  const CartItem({
    required this.menuItemName,
    required this.priceLabel,
    required this.priceValue,
    required this.quantity,
    required this.restaurantName,
    required this.restaurantId,
  });

  /// Name of the menu item, e.g. `'Chicken Tikka Pizza'`.
  final String menuItemName;

  /// Pre-formatted unit price shown in the UI, e.g. `'PKR 1,499'`.
  final String priceLabel;

  /// Numeric unit price used for math (parsed from [priceLabel] for now).
  final double priceValue;

  /// How many of this item are in the cart.
  final int quantity;

  final String restaurantName;
  final String restaurantId;

  /// Subtotal for this line item: unit price × quantity.
  double get subtotal => priceValue * quantity;

  /// Subtotal formatted for display, e.g. `'PKR 2,998'`.
  String get formattedSubtotal => formatPKR(subtotal);

  CartItem copyWith({int? quantity}) => CartItem(
        menuItemName: menuItemName,
        priceLabel: priceLabel,
        priceValue: priceValue,
        quantity: quantity ?? this.quantity,
        restaurantName: restaurantName,
        restaurantId: restaurantId,
      );
}
