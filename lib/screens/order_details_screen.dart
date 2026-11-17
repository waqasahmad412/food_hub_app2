import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../utils/app_colors.dart';

/// Shows a single placed order with a visual status stepper.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final Order order;

  static const _statusSteps = <OrderStatusStep>[
    OrderStatusStep(
      key: 'Pending',
      label: 'Order Placed',
      icon: Icons.receipt_long,
    ),
    OrderStatusStep(
      key: 'Preparing',
      label: 'Preparing',
      icon: Icons.restaurant,
    ),
    OrderStatusStep(
      key: 'On the way',
      label: 'On the way',
      icon: Icons.delivery_dining,
    ),
    OrderStatusStep(
      key: 'Delivered',
      label: 'Delivered',
      icon: Icons.check_circle,
    ),
  ];

  int get _currentStepIndex {
    var idx = _statusSteps.indexWhere((s) => s.key == order.status);
    if (idx < 0) idx = 0;
    return idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusTracker(context),
          const SizedBox(height: 20),
          _buildRestaurantCard(context),
          const SizedBox(height: 16),
          _buildItemsCard(context),
          const SizedBox(height: 16),
          _buildDetailsCard(context),
          const SizedBox(height: 16),
          _buildTotalCard(context),
        ],
      ),
    );
  }

  Widget _buildStatusTracker(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.fieldBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 0; i < _statusSteps.length; i++) ...[
                  _buildStatusDot(context, i),
                  if (i < _statusSteps.length - 1) _buildStatusLine(i),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < _statusSteps.length; i++)
                  SizedBox(
                    width: 70,
                    child: Text(
                      _statusSteps[i].label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: i <= _currentStepIndex
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: i <= _currentStepIndex
                            ? AppColors.heading
                            : AppColors.body,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot(BuildContext context, int index) {
    final reached = index <= _currentStepIndex;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: reached ? AppColors.primary : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: reached ? AppColors.primary : AppColors.fieldBorder,
          width: 2,
        ),
      ),
      child: Icon(
        _statusSteps[index].icon,
        size: 14,
        color: reached ? Colors.white : AppColors.body,
      ),
    );
  }

  Widget _buildStatusLine(int index) {
    final reached = index < _currentStepIndex;
    return Expanded(
      child: Container(
        height: 2,
        color: reached ? AppColors.primary : AppColors.fieldBorder,
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.fieldBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.restaurantName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.heading)),
                  const SizedBox(height: 2),
                  Text(
                      order.orderId.length > 8
                          ? 'Order #${order.orderId.substring(0, 8)}'
                          : order.orderId.isNotEmpty
                              ? 'Order #$order.orderId'
                              : 'Order placed',
                      style:
                          const TextStyle(fontSize: 12, color: AppColors.body)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.fieldBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading)),
            const SizedBox(height: 12),
            for (final item in order.items) _buildItemRow(item),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    final name = item['menuItemName'] as String? ?? '';
    final priceLabel = item['priceLabel'] as String? ?? '';
    final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
    final subtotalLabel = item['formattedSubtotal'] as String? ?? priceLabel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text('$quantity',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.heading)),
                Text(priceLabel,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.body)),
              ],
            ),
          ),
          Text(subtotalLabel,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading)),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    final date = order.createdAt.toDate();
    final formatted =
        '${_months[date.month - 1]} ${date.day}, ${date.year} - ${_formatTime(date)}';
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.fieldBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Details',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading)),
            const SizedBox(height: 12),
            _detailRow(Icons.person, 'Customer', order.userName),
            _detailRow(Icons.email, 'Email', order.userEmail),
            _detailRow(
                Icons.location_on, 'Delivery Address', order.deliveryAddress),
            _detailRow(Icons.payment, 'Payment', order.paymentMethod),
            _detailRow(Icons.access_time, 'Placed At', formatted),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.body)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.heading)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading)),
            Text(order.formattedTotalPrice,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  static const _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$displayHour:$minute $period';
  }
}

/// One step of the order status tracker shown on the details screen.
class OrderStatusStep {
  const OrderStatusStep({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}
