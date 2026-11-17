// `Order` is hidden so it cannot clash with our own Order model below.
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../utils/app_colors.dart';

/// Checkout screen: order summary, delivery address and payment method.
///
/// Placing an order writes a document to the Firestore `orders` collection
/// (status `Pending`, server `createdAt`), clears the cart and shows a
/// success confirmation. On failure the cart stays intact so the user can
/// simply retry.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();

  String _paymentMethod = 'Cash on Delivery';
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  String? _validateAddress(String? value) {
    final address = value?.trim() ?? '';
    if (address.isEmpty) {
      return 'Please enter your delivery address';
    }
    if (address.length < 10) {
      return 'Address must be at least 10 characters';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _handlePlaceOrder() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final user = FirebaseAuth.instance.currentUser;

    // Safety net: checkout requires items and a signed-in user.
    if (!cart.hasItems) {
      _showError('Your cart is empty.');
      return;
    }
    if (user == null) {
      _showError('You are not logged in. Please log in and try again.');
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final order = Order(
        orderId: '',
        userId: user.uid,
        userName: user.displayName ?? (user.email ?? '').split('@').first,
        userEmail: user.email ?? '',
        restaurantName: cart.restaurantName ?? '',
        restaurantId: cart.restaurantId ?? '',
        items: cart.items
            .map(
              (CartItem item) => <String, dynamic>{
                'menuItemName': item.menuItemName,
                'priceLabel': item.priceLabel,
                'priceValue': item.priceValue,
                'quantity': item.quantity,
                'subtotal': item.subtotal,
              },
            )
            .toList(),
        totalPrice: cart.totalPrice,
        deliveryAddress: _addressController.text.trim(),
        status: OrderStatus.pending,
        createdAt: Timestamp.now(),
        paymentMethod: _paymentMethod,
        paymentStatus: _paymentMethod == 'Card' ? 'Paid' : 'Pending',
      );

      // Swap in a server timestamp so order time comes from Firestore.
      final orderMap = order.toMap()
        ..['createdAt'] = FieldValue.serverTimestamp();

      final docRef =
          await FirebaseFirestore.instance.collection('orders').add(orderMap);

      // Success: empty the cart only after the write succeeded.
      if (!mounted) return;
      cart.clearCart();
      setState(() => _isPlacingOrder = false);

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _buildSuccessDialog(docRef.id),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      _showError(
        e.code == 'permission-denied'
            ? 'You are not allowed to place this order. Please log in again.'
            : 'Could not place your order: ${e.message ?? e.code}',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      _showError('Something went wrong. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  /// Big reassuring confirmation with an animated checkmark and order id.
  Widget _buildSuccessDialog(String orderId) {
    final shortId =
        orderId.substring(0, orderId.length.clamp(0, 12)).toUpperCase();
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pop-in checkmark animation on first frame.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, value, child) =>
                Transform.scale(scale: value.clamp(0, 1.15), child: child),
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Order Placed Successfully!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your food is being prepared.\nOrder ID: $shortId…',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.body,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Close dialog, then jump straight to the Home/Dashboard with a
              // fresh navigation stack (cart + checkout are removed).
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = FirebaseAuth.instance.currentUser;

    // Edge cases: cannot checkout without items or a signed-in user.
    if (!cart.hasItems) {
      return _buildGuardScaffold(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        message: 'Add some delicious items before checking out.',
      );
    }
    if (user == null) {
      return _buildGuardScaffold(
        icon: Icons.lock_outline,
        title: 'Please log in',
        message: 'You need to be logged in to place an order.',
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.heading,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOrderSummaryCard(cart),
                    const SizedBox(height: 18),
                    _buildAddressField(),
                    const SizedBox(height: 18),
                    _buildPaymentSelector(),
                    const SizedBox(height: 26),
                    _buildPlaceOrderButton(cart),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Simple guard screen for empty-cart / logged-out edge cases.
  Widget _buildGuardScaffold({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.heading,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 56),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.body),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// White card listing every cart line with quantity and subtotal.
  Widget _buildOrderSummaryCard(CartProvider cart) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.fieldBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.storefront,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cart.restaurantName ?? 'Restaurant',
                    style: const TextStyle(
                      color: AppColors.heading,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 22),
            ...cart.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '×${item.quantity}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.menuItemName,
                        style: const TextStyle(color: AppColors.heading),
                      ),
                    ),
                    Text(
                      item.formattedSubtotal,
                      style: const TextStyle(
                        color: AppColors.body,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: AppColors.heading,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  cart.formattedTotalPrice,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Delivery address field (required, min 10 characters).
  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      maxLines: 2,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.streetAddress,
      validator: _validateAddress,
      decoration: InputDecoration(
        labelText: 'Delivery Address',
        hintText: 'House #, street, area, city',
        helperText: 'Include house number and street for faster delivery',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 34),
          child: Icon(Icons.location_on_outlined, color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
        ),
      ),
    );
  }

  /// Payment method picker — UI only for now (no real processing).
  Widget _buildPaymentSelector() {
    const options = <(String, IconData)>[
      ('Cash on Delivery', Icons.payments_outlined),
      ('Card', Icons.credit_card),
    ];
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.fieldBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6, bottom: 4),
              child: Text(
                'Payment Method',
                style: TextStyle(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            RadioGroup<String>(
              groupValue: _paymentMethod,
              onChanged: (value) =>
                  setState(() => _paymentMethod = value ?? _paymentMethod),
              child: Column(
                children: options
                    .map(
                      (option) => RadioListTile<String>(
                        value: option.$1,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Icon(option.$2, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              option.$1,
                              style: const TextStyle(color: AppColors.heading),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            if (_paymentMethod == 'Card')
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 6),
                child: Text(
                  'Card payment will be integrated soon — you will pay on '
                  'delivery for now.',
                  style: TextStyle(color: AppColors.body, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Primary CTA with a loading spinner while the Firestore write runs.
  Widget _buildPlaceOrderButton(CartProvider cart) {
    return ElevatedButton(
      onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: _isPlacingOrder
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Text(
              'Place Order • ${cart.formattedTotalPrice}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
    );
  }
}
