import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../data/dummy_restaurants.dart';
import '../../models/restaurant_model.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_logo.dart';
import 'restaurant_details_screen.dart';
import 'add_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  List<Restaurant> _getRestaurantsForCategory(
      String cat, List<Restaurant> firestoreList) {
    final allDummy = _getDummyForCategory(cat);
    if (cat == 'All') {
      final result = List<Restaurant>.from(allDummy);
      result.addAll(firestoreList);
      return result;
    }
    return firestoreList.where((r) => r.category == cat).toList()
      ..addAll(allDummy.where((r) => r.category == cat).toList());
  }

  List<Restaurant> _getDummyForCategory(String cat) {
    if (cat == 'All') return dummyRestaurants;
    return dummyRestaurants.where((r) => r.category == cat).toList();
  }

  /// Number of places shown in the browse section title for the current
  /// category (based on the local dummy data for now).
  int _getCount([List<Restaurant> firestoreList = const []]) {
    final count = _getRestaurantsForCategory(_selectedCategory, firestoreList).length;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const AppLogoBar(),
        actions: [_buildOrdersButton(context), _buildCartButton(context)],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeMessage(user),
                  const SizedBox(height: 20),
                  _buildSearchBar(context),
                  const SizedBox(height: 24),
                  _buildCategoriesSection(),
                  const SizedBox(height: 16),
                  _buildBrowseSection(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddPostScreen())),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildWelcomeMessage(User? user) {
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'Guest';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, $name! \u2728',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.heading, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('What would you like to eat today?',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.body)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: const Row(children: [
          Icon(Icons.search, color: AppColors.body),
          SizedBox(width: 12),
          Text('Search restaurants or dishes...',
              style: TextStyle(color: AppColors.body, fontSize: 15)),
        ]),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: foodCategories.map((cat) => _buildCategoryChip(cat)).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = category == _selectedCategory;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.fieldBorder,
              width: isSelected ? 0 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]
                : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(_categoryIcon(category),
                size: 18, color: isSelected ? Colors.white : AppColors.primary),
            const SizedBox(width: 6),
            Text(
              category == 'Fast Food' ? 'Fast' : category,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Pizza':
        return Icons.local_pizza;
      case 'Burger':
        return Icons.fastfood;
      case 'Biryani':
        return Icons.kitchen;
      case 'Chinese':
        return Icons.rice_bowl;
      case 'Desi':
        return Icons.coffee;
      case 'Fast Food':
        return Icons.local_drink;
      case 'Desserts':
        return Icons.cake;
      case 'Drinks':
        return Icons.water_drop;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildBrowseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Popular Restaurants',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.heading, fontWeight: FontWeight.w700)),
            Text('${_getCount()} places',
                style: TextStyle(color: AppColors.body.withValues(alpha: 0.7))),
          ],
        ),
        const SizedBox(height: 12),
        _buildRestaurantListStream(),
      ],
    );
  }

  Widget _buildRestaurantListStream() {
    final stream = FirebaseFirestore.instance
        .collection('restaurants')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final firestoreList = <Restaurant>[];
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final map = doc.data() as Map<String, dynamic>;
            final r = Restaurant(
              id: doc.id,
              name: map['name']?.toString() ?? '',
              imageUrl: map['imageUrl']?.toString() ?? '',
              cuisineType: map['cuisineType']?.toString() ?? '',
              rating: (map['rating'] ?? 4.0).toDouble(),
              deliveryTime: map['deliveryTime']?.toString() ?? '',
              category: map['category']?.toString() ?? 'Fast Food',
            );
            if (_selectedCategory == 'All' || r.category == _selectedCategory) {
              firestoreList.add(r);
            }
          }
        }
        final combined =
            _getRestaurantsForCategory(_selectedCategory, firestoreList);
        combined.sort((a, b) => b.rating.compareTo(a.rating));

        if (combined.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Icon(Icons.restaurant_menu,
                        size: 48, color: AppColors.body),
                  ),
                  SizedBox(height: 12),
                  Text('No restaurants in this category',
                      style: TextStyle(color: AppColors.body)),
                ],
              ),
            ),
          );
        }

        return Column(
          children: combined.map((r) => _buildRestaurantCard(r)).toList(),
        );
      },
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    RestaurantDetailsScreen(restaurant: restaurant))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(restaurant.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.restaurant,
                          color: AppColors.primary))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(restaurant.cuisineType,
                        style: const TextStyle(
                            color: AppColors.body, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text('${restaurant.rating}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      const Icon(Icons.delivery_dining,
                          color: AppColors.primary, size: 16),
                      Text(restaurant.deliveryTime,
                          style: const TextStyle(
                              color: AppColors.body, fontSize: 12)),
                    ]),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildOrdersButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.receipt_long, size: 26),
      onPressed: () => Navigator.pushNamed(context, '/orders'),
    );
  }

  Widget _buildCartButton(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final count = provider.totalItemCount;
    return Stack(children: [
      IconButton(
        icon: const Icon(Icons.shopping_cart, size: 26),
        onPressed: () => Navigator.pushNamed(context, '/cart'),
      ),
      if (count > 0)
        Positioned(
          top: 2,
          right: 2,
          child: Container(
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              count > 9 ? '9+' : '$count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ),
    ]);
  }
}
