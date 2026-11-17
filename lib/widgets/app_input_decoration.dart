import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Shared [InputDecoration] used by the app's text fields so every
/// text field looks consistent (rounded corners, icons, brand colors).
InputDecoration appInputDecoration({
  required String label,
  required IconData prefixIcon,
  String? hint,
  String? helperText,
  Widget? suffixIcon,
}) {
  const radius = BorderRadius.all(Radius.circular(14));

  OutlineInputBorder border(Color color, [double width = 1.0]) =>
      OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helperText,
    prefixIcon: Icon(prefixIcon, color: AppColors.primary),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(AppColors.fieldBorder),
    enabledBorder: border(AppColors.fieldBorder),
    focusedBorder: border(AppColors.primary, 1.6),
    errorBorder: border(Colors.redAccent),
    focusedErrorBorder: border(Colors.redAccent, 1.6),
  );
}
