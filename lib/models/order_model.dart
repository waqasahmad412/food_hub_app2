import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_item_model.dart';

/// Statuses an order moves through after being placed.
class OrderStatus {
  const OrderStatus._();

  static const String pending = 'Pending';
  static const String preparing = 'Preparing';
  static const String onTheWay = 'On the way';
  static const String delivered = 'Delivered';

  /// All statuses in lifecycle order (useful for tracking screens later).
  static const List<String> all = <String>[
    pending,
    preparing,
    onTheWay,
    delivered,
  ];
}

/// One placed order, persisted to the Firestore `orders` collection.
///
/// [items] mirrors the cart line items at the time the order was placed so
/// later price/menu changes never mutate historical orders.
class Order {
  const Order({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.restaurantName,
    required this.restaurantId,
    required this.items,
    required this.totalPrice,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
    this.paymentMethod = 'Cash on Delivery',
    this.paymentStatus = 'Pending',
  });

  /// Firestore document id. Empty before the write assigns one.
  final String orderId;

  /// Firebase Auth uid of the customer.
  final String userId;
  final String userName;
  final String userEmail;

  final String restaurantName;
  final String restaurantId;

  /// Snapshot of the cart items as plain maps for Firestore.
  final List<Map<String, dynamic>> items;

  /// Order total (sum of item subtotals).
  final double totalPrice;

  /// Free-form delivery address typed at checkout.
  final String deliveryAddress;

  /// Lifecycle status, starts at [OrderStatus.pending].
  final String status;

  /// Server timestamp set on create.
  final Timestamp createdAt;

  /// 'Cash on Delivery' or 'Card' (UI-only selection for now).
  final String paymentMethod;

  /// 'Pending' or 'Paid' — how users filter their order history.
  final String paymentStatus;

  /// Formatted total for receipts/summaries, e.g. `'PKR 2,647'`.
  String get formattedTotalPrice => formatPKR(totalPrice);

  Map<String, dynamic> toMap() => <String, dynamic>{
        'orderId': orderId,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'restaurantName': restaurantName,
        'restaurantId': restaurantId,
        'items': items,
        'totalPrice': totalPrice,
        'deliveryAddress': deliveryAddress,
        'status': status,
        'createdAt': createdAt,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
      };

  factory Order.fromMap(Map<String, dynamic> map, {String? documentId}) =>
      Order(
        orderId: map['orderId'] as String? ?? documentId ?? '',
        userId: map['userId'] as String? ?? '',
        userName: map['userName'] as String? ?? '',
        userEmail: map['userEmail'] as String? ?? '',
        restaurantName: map['restaurantName'] as String? ?? '',
        restaurantId: map['restaurantId'] as String? ?? '',
        items: (map['items'] as List<dynamic>? ?? <dynamic>[])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0,
        deliveryAddress: map['deliveryAddress'] as String? ?? '',
        status: map['status'] as String? ?? OrderStatus.pending,
        createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
        paymentMethod: map['paymentMethod'] as String? ?? 'Cash on Delivery',
        paymentStatus: map['paymentStatus'] as String? ?? 'Pending',
      );

  /// Converts a Firestore document snapshot into an [Order].
  factory Order.fromDocument(DocumentSnapshot doc) =>
      Order.fromMap(doc.data()! as Map<String, dynamic>, documentId: doc.id);
}
