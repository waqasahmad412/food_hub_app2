import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../data/dummy_restaurants.dart';
import '../widgets/app_input_decoration.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _cuisineCtrl = TextEditingController();
  String _category = 'Pizza';
  double _rating = 4.0;
  final _deliveryTimeCtrl = TextEditingController(text: '20-30 min');
  bool _posting = false;

  String _generateId() {
    return 'rp_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999).toString().padLeft(5, '0')}';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _imageUrlCtrl.dispose();
    _cuisineCtrl.dispose();
    _deliveryTimeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Restaurant', style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: appInputDecoration(
                  label: 'Restaurant / Food Name',
                  hint: 'e.g. Pizza Max',
                  prefixIcon: Icons.restaurant,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: appInputDecoration(
                  label: 'Image URL',
                  hint: 'https://example.com/image.jpg',
                  prefixIcon: Icons.image,
                ),
                keyboardType: TextInputType.url,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Image URL is required';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _cuisineCtrl,
                decoration: appInputDecoration(
                  label: 'Cuisine Type',
                  hint: 'e.g. Italian',
                  prefixIcon: Icons.food_bank,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Cuisine is required';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const Text('Category', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: appInputDecoration(
                  label: 'Category',
                  hint: 'Select category',
                  prefixIcon: Icons.category,
                ),
                items: foodCategories.map((String cat) {
                  return DropdownMenuItem<String>(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (String? v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.amber, size: 26),
                  Expanded(
                    child: Slider(
                      value: _rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: AppColors.amber,
                      inactiveColor: AppColors.amber.withValues(alpha: 0.3),
                      onChanged: (double v) => setState(() => _rating = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.amber),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Rate 1 (low) to 5 (high)',
                  style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 14),
              TextFormField(
                controller: _deliveryTimeCtrl,
                decoration: appInputDecoration(
                  label: 'Delivery Time',
                  hint: 'e.g. 20-30 min',
                  prefixIcon: Icons.local_shipping,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Delivery time is required';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _posting ? null : _savePost,
                child: _posting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text(
                        'Post to Restaurants',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to post a restaurant.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _posting = true);
    try {
      final uid = user.uid;
      final docRef = FirebaseFirestore.instance.collection('restaurants').doc(_generateId());

      final menuItems = <Map<String, dynamic>>[];
      for (int i = 1; i <= 5; i++) {
        menuItems.add({'name': 'Dish #$i', 'price': 'PKR 0', 'description': 'Add menu items later'});
      }

      await docRef.set({
        'id': docRef.id,
        'name': _nameCtrl.text.trim(),
        'imageUrl': _imageUrlCtrl.text.trim(),
        'cuisineType': _cuisineCtrl.text.trim(),
        'category': _category,
        'rating': _rating.round(),
        'deliveryTime': _deliveryTimeCtrl.text.trim(),
        'menu': menuItems,
        'createdAt': FieldValue.serverTimestamp(),
        'postedByUid': uid,
        'postedByName': user.displayName ?? 'Anonymous',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restaurant posted successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not post: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }
}
