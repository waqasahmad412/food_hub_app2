#!/usr/bin/env python3
"""Create add_post_screen.dart for FoodDash app."""
import pathlib

content = """import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/dummy_restaurants.dart';
import '../utils/app_colors.dart';

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
    return 'rp_' +
        DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        (Random().nextInt(99999).toString().padLeft(5, '0'));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _imageUrlCtrl.dispose();
    _cuisineCtrl.dispose();
    _deliveryTimeCtrl.dispose();
    super.dispose();
  }
"""
pathlib.Path('write_funcs.py').write_text(content)
print("PART 1 WRITTEN")
