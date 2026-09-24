import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class RatingBadge extends StatelessWidget {
  final double rating;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const RatingBadge({
    super.key,
    required this.rating,
    this.fontSize = 12,
    this.iconSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(190),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.goldAccent.withAlpha(100), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            color: AppTheme.goldAccent,
            size: iconSize,
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
