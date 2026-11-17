import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../utils/app_colors.dart';
import 'order_details_screen.dart';

/// Order history screen showing the signed-in user's past orders.
///
/// Reads Firestore's `orders` collection (filtered by the current user's uid,
/// newest first) and listens via a [StreamBuilder] so the list updates in
/// real-time when an order's status changes. A dropdown lets the user filter
/// orders by payment status: All, Pending or Paid.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  /// 'All', 'Pending' or 'Paid'.
  String _filter = 'All';

  /// Dropdown menu choices.
  static const _filterOptions = <String, IconData>{
    'All': Icons.all_inclusive,
    'Pending': Icons.pending_actions,
    'Paid': Icons.paid,
  };

  /// Stream of the current user's orders, ordered most-recent first.
  /// Returns an empty stream on the rare occasion no user is logged in.
  Stream<QuerySnapshot> _userOrders() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream<QuerySnapshot>.empty();
    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style:
              TextStyle(fontWeight: FontWeight.w800, color: AppColors.heading),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildFilterDropdown(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _userOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return _buildMessage(
              icon: Icons.error_outline,
              message: 'Could not load orders. Please try again.',
            );
          }
          final docs = snapshot.data?.docs ?? <QueryDocumentSnapshot>[];
          if (docs.isEmpty) {
            return _buildEmptyState(context);
          }
          final orders = docs
              .map((d) => Order.fromDocument(
                  d as DocumentSnapshot<Map<String, dynamic>>))
              .toList();
          final filtered = _filter == 'All'
              ? orders
              : orders.where((o) {
                  return o.paymentStatus == _filter;
                }).toList();
          if (filtered.isEmpty) {
            return _buildFilteredEmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _OrderCard(order: filtered[index]),
          );
        },
      ),
    );
  }

  /// Dropdown button in the app bar to filter by payment status.
  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filter,
          isDense: true,
          items: _filterOptions.keys
              .map((key) => DropdownMenuItem<String>(
                    value: key,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_filterOptions[key],
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(key,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _filter = value);
          },
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
        ),
      ),
    );
  }

  /// Empty state shown when a specific filter (Pending/Paid) has no orders.
  Widget _buildFilteredEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.filter_list,
                  size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('No $_filter orders',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading)),
            const SizedBox(height: 6),
            const Text('There are no orders matching this filter.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.body)),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => setState(() => _filter = 'All'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(180, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Show all orders',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('No orders yet',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.heading)),
            const SizedBox(height: 6),
            const Text('Browse restaurants and place your first order!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.body)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Browse Restaurants',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.body),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.body)),
          ],
        ),
      ),
    );
  }
}

/// A single order row shown in the orders list.
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  Color _statusColor(String status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.onTheWay:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      default:
        return AppColors.body;
    }
  }

  String _formattedDate(Timestamp ts) {
    final dt = ts.toDate();
    final months = <String>[
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
    final hour = dt.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} - $displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = order.items.fold<int>(
        0, (total, item) => total + ((item['quantity'] as num?)?.toInt() ?? 0));
    final statusColor = _statusColor(order.status);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.fieldBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.restaurant,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(order.restaurantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.heading)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(order.status,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.paymentStatus == 'Paid'
                          ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                          : Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        order.paymentStatus == 'Paid'
                            ? Icons.check_circle
                            : Icons.schedule,
                        size: 13,
                        color: order.paymentStatus == 'Paid'
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFB45309),
                      ),
                      const SizedBox(width: 4),
                      Text(order.paymentStatus,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: order.paymentStatus == 'Paid'
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFB45309))),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.body),
                const SizedBox(width: 4),
                Text(_formattedDate(order.createdAt),
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.body)),
              ]),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined,
                      size: 16, color: AppColors.body),
                  const SizedBox(width: 4),
                  Text('$itemCount item${itemCount == 1 ? '' : 's'}',
                      style:
                          const TextStyle(fontSize: 12, color: AppColors.body)),
                  const Spacer(),
                  Text(order.formattedTotalPrice,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
