/// Data models for the "Browse Restaurants" feature.
///
/// [Restaurant] mirrors one document of the future Firestore
/// `restaurants` collection (see [toMap]/[fromMap]); [MenuItem] is one
/// row of a restaurant's menu.
library;

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.cuisineType,
    required this.rating,
    required this.deliveryTime,
    required this.category,
  });

  /// Unique identifier — will become the Firestore document id.
  final String id;

  final String name;

  /// Network image URL (placeholder photos for now).
  final String imageUrl;

  /// Short cuisine description, e.g. "Desi • BBQ & Kebabs".
  final String cuisineType;

  /// Average rating from 4.0 to 4.9 in the dummy data.
  final double rating;

  /// Estimated delivery window, e.g. "25-35 min".
  final String deliveryTime;

  /// Category key used for chip filtering, e.g. "Pizza", "Desi".
  final String category;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'cuisineType': cuisineType,
        'rating': rating,
        'deliveryTime': deliveryTime,
        'category': category,
      };

  factory Restaurant.fromMap(Map<String, dynamic> map) => Restaurant(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        cuisineType: map['cuisineType'] as String? ?? '',
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        deliveryTime: map['deliveryTime'] as String? ?? '',
        category: map['category'] as String? ?? '',
      );
}

/// A single food item shown on the restaurant details screen.
class MenuItem {
  const MenuItem({
    required this.name,
    required this.price,
    this.description,
  });

  final String name;

  /// Pre-formatted price label, e.g. "PKR 1,199".
  final String price;

  final String? description;
}
