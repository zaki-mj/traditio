import 'package:flutter/material.dart';
import 'package:traditional_gems/theme/app_colors.dart';
import '../models/place.dart';

/// Shows either a network image (when an URL is provided) or a simple
/// category icon placeholder when no image link is available.
class CategoryImage extends StatelessWidget {
  final String? imageUrl;
  final POICategory category;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enableHero;
  final String? heroTag;

  const CategoryImage({super.key, required this.imageUrl, required this.category, this.width, this.height, this.fit = BoxFit.cover, this.borderRadius, this.enableHero = false, this.heroTag});

  // Consider the image present only when a non-empty URL is provided.
  // Null or empty strings will show the fallback icon.
  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  IconData _iconForCategory() {
    switch (category) {
      case POICategory.hotel:
        return Icons.hotel;
      case POICategory.restaurant:
        return Icons.restaurant;
      case POICategory.attraction:
        return Icons.attractions;
      case POICategory.store:
        return Icons.store;
      case POICategory.other:
        return Icons.more_horiz;
      // All enum cases covered above.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child;

    if (_hasImage) {
      child = Image.network(imageUrl!, width: width, height: height, fit: fit, errorBuilder: (c, e, s) => _buildFallback(theme));
    } else {
      child = _buildFallback(theme);
    }

    // Apply border radius if provided
    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }

    if (enableHero && heroTag != null) {
      return Hero(tag: heroTag!, child: child);
    }

    return child;
  }

  Widget _buildFallback(ThemeData theme) {
    final catColor = _colorForCategory();

    return Container(
      width: width,
      height: height,
      color: catColor,
      alignment: Alignment.center,
      child: Icon(_iconForCategory(), size: (height != null ? (height! * 0.4) : 48), color: Colors.white),
    );
  }

  Color _colorForCategory() {
    switch (category) {
      case POICategory.hotel:
        return Colors.blue;
      case POICategory.restaurant:
        return Colors.orange;
      case POICategory.attraction:
        return Colors.green;
      case POICategory.store:
        return Colors.purple;
      case POICategory.other:
        return Colors.grey;
    }
  }
}
