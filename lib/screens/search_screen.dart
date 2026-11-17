import 'dart:async';

import 'package:flutter/material.dart';

import '../data/dummy_restaurants.dart';
import '../models/restaurant_model.dart';
import '../utils/app_colors.dart';
import 'restaurant_details_screen.dart';

/// A matching dish result: the menu item plus the restaurant it belongs to.
class _DishMatch {
  const _DishMatch(this.restaurant, this.item);

  final Restaurant restaurant;
  final MenuItem item;
}

/// Full-screen search experience with live filtering as the user types.
///
/// Matches against restaurant names, cuisine types and individual menu item
/// names, grouped into "Restaurants" and "Dishes" sections. A short debounce
/// keeps typing responsive.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  static const _recentSearches = <String>[
    'Pizza',
    'Biryani',
    'Burger',
    'Mango Shake',
  ];

  List<Restaurant> get _matchedRestaurants {
    final q = _query;
    if (q.isEmpty) return const <Restaurant>[];
    return dummyRestaurants
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.cuisineType.toLowerCase().contains(q))
        .toList();
  }

  List<_DishMatch> get _matchedDishes {
    final q = _query;
    if (q.isEmpty) return const <_DishMatch>[];
    final dishes = <_DishMatch>[];
    for (final r in dummyRestaurants) {
      for (final item in dummyMenuFor(r)) {
        if (item.name.toLowerCase().contains(q) ||
            (item.description?.toLowerCase().contains(q) ?? false)) {
          dishes.add(_DishMatch(r, item));
        }
      }
    }
    return dishes;
  }

  void _scheduleSearch(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _query = '';
      setState(() {});
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _query = trimmed.toLowerCase();
      setState(() {});
    });
  }

  void _useQuery(String value) {
    _debounce?.cancel();
    _query = value.trim().toLowerCase();
    setState(() {});
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    _query = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _scheduleSearch,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            hintText: 'Search restaurants or dishes...',
            hintStyle: const TextStyle(color: AppColors.body),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.fieldBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.fieldBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: _clear,
                    icon: const Icon(Icons.close, color: AppColors.body),
                  ),
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.heading,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      return _buildSuggestions();
    }
    final restaurants = _matchedRestaurants;
    final dishes = _matchedDishes;
    if (restaurants.isEmpty && dishes.isEmpty) {
      return _buildNoResults();
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        if (restaurants.isNotEmpty) ...[
          const Text(
            'Restaurants',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.heading),
          ),
          const SizedBox(height: 10),
          ...restaurants.map(_buildRestaurantCard),
          const SizedBox(height: 14),
        ],
        if (dishes.isNotEmpty) ...[
          const Text(
            'Dishes',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.heading),
          ),
          const SizedBox(height: 10),
          ...dishes.map(_buildDishTile),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      children: [
        Icon(Icons.manage_search,
            size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
        const SizedBox(height: 12),
        const Text(
          'Search for your favorite food',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.heading),
        ),
        const SizedBox(height: 6),
        Text(
          'Try restaurant names, cuisines or dishes',
          style: TextStyle(
              fontSize: 13, color: AppColors.body.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 26),
        const Text(
          'Recent Searches',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.heading),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _recentSearches.map((s) {
            return ActionChip(
              label: Text(s, style: const TextStyle(color: AppColors.heading)),
              avatar:
                  const Icon(Icons.history, size: 18, color: AppColors.primary),
              visualDensity: VisualDensity.comfortable,
              onPressed: () {
                _controller.text = s;
                _useQuery(s);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 56, color: AppColors.body.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              "No results found for '$_query'",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading),
            ),
            const SizedBox(height: 6),
            Text(
              'Try different keywords or check the spelling',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.body.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
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
              child: Image.network(
                restaurant.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.restaurant, color: AppColors.primary),
                ),
              ),
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
                      style:
                          const TextStyle(color: AppColors.body, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text('${restaurant.rating}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    const Icon(Icons.delivery_dining,
                        color: AppColors.primary, size: 16),
                    Text(restaurant.deliveryTime,
                        style: const TextStyle(
                            color: AppColors.body, fontSize: 12)),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildDishTile(_DishMatch match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    RestaurantDetailsScreen(restaurant: match.restaurant))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lunch_dining, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(match.item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.storefront,
                        size: 14, color: AppColors.body),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(match.restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.body)),
                    ),
                  ]),
                ],
              ),
            ),
            Text(match.item.price,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
        ),
      ),
    );
  }
}
