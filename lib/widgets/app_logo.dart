import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Placeholder logo + app name shown at the top of the auth screens.
///
/// Replace the icon container with an [Image.asset] once real branding
/// assets are available.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 88, this.showTagline = true});

  /// Diameter of the logo badge.
  final double size;

  /// Whether to show the tagline below the app name.
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.lunch_dining,
            color: Colors.white,
            size: size * 0.55,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'FoodDash',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.heading,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'Delicious food, delivered fast',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.body),
          ),
        ],
      ],
    );
  }
}

/// Compact horizontal brand mark for use in AppBars (e.g. the Home/Dashboard
/// header). Shows a small orange badge beside the "FoodDash" wordmark so it
/// fits cleanly in an app bar row.
class AppLogoBar extends StatelessWidget {
  const AppLogoBar({super.key, this.iconSize = 26, this.textSize = 20});

  /// Size of the orange logo badge (square).
  final double iconSize;

  /// Font size of the "FoodDash" wordmark.
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize + 8,
          height: iconSize + 8,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular((iconSize + 8) * 0.3),
          ),
          child: Icon(
            Icons.lunch_dining,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'FoodDash',
          style: TextStyle(
            color: AppColors.heading,
            fontWeight: FontWeight.w800,
            fontSize: textSize,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
