import 'package:flutter/material.dart';

/// Brand colors shared across the FoodDash app.
class AppColors {
  AppColors._();

  /// Primary brand orange (buttons, links, highlights).
  static const Color primary = Color(0xFFFF6B35);

  /// Deeper orange for gradients / pressed states.
  static const Color primaryDark = Color(0xFFE8541F);

  /// Warm amber used in ratings, stars, etc.
  static const Color amber = Color(0xFFFFB300);

  /// Lighter warm tone used in gradients alongside primary.
  static const Color accent = Color(0xFFFFC529);
  /// Default scaffold background.
  static const Color background = Color(0xFFFAFAFA);

  /// Dark headings.
  static const Color heading = Color(0xFF1F2937);

  /// Secondary body text.
  static const Color body = Color(0xFF6B7280);

  /// Default text field border.
  static const Color fieldBorder = Color(0xFFE5E7EB);
}
