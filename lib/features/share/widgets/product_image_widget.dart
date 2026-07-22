import 'package:flutter/material.dart';
import '../data/repositories/share_repository_impl.dart';

class ProductImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final repo = ShareRepositoryImpl();
    final resolvedUrl = repo.getProductImageUrl(imageUrl);

    Widget imageWidget;

    if (resolvedUrl.isEmpty) {
      imageWidget = Container(
        color: const Color(0xFFF4EDE4),
        child: const Center(
          child: Icon(Icons.shopping_bag_outlined, color: Color(0xFF8A461E), size: 36),
        ),
      );
    } else {
      imageWidget = Image.network(
        resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFF4EDE4),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFFFB7701),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF4EDE4),
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined, color: Color(0xFF8A461E), size: 32),
            ),
          );
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
