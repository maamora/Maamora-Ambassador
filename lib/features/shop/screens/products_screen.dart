import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../share/providers/product_catalog_provider.dart';
import '../../share/widgets/product_image_widget.dart';

const Color _surface = Color(0xFFFFF8F5);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF251912);
const Color _onSurfaceVariant = Color(0xFF584236);

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _filter = 'All';

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _filter = label;
          });
        }
      },
      selectedColor: const Color(0xFFFB7701).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFFFB7701),
      labelStyle: GoogleFonts.inter(
        color: isSelected ? const Color(0xFFFB7701) : _onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFFFB7701) : const Color(0xFFE0C0B0),
        ),
      ),
      backgroundColor: _surfaceContainerLowest,
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(productCatalogProvider);

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products',
                    style: GoogleFonts.plusJakartaSans(
                      color: _onBackground,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: _onSurfaceVariant),
                    onPressed: () => ref.read(productCatalogProvider.notifier).refresh(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Grouped'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Single'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: catalogAsync.when(
                  data: (products) {
                    final filteredProducts = products.where((p) {
                      if (_filter == 'Grouped') return p.isGrouped;
                      if (_filter == 'Single') return !p.isGrouped;
                      return true;
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No products available',
                          style: GoogleFonts.inter(color: _onSurfaceVariant),
                        ),
                      );
                    }
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _ProductGridItem(
                          imageUrl: product.imageUrl,
                          title: product.name,
                          price: '${product.price.toStringAsFixed(0)} DH',
                          isGrouped: product.isGrouped,
                          onTap: () => context.push(AppRoutes.ambassadorShop, extra: product),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFB7701)),
                  ),
                  error: (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Failed to load products', style: GoogleFonts.inter(color: Colors.red)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => ref.read(productCatalogProvider.notifier).refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final bool isGrouped;
  final VoidCallback onTap;

  const _ProductGridItem({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.isGrouped,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ProductImageWidget(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isGrouped 
                            ? const Color(0xFF251912).withValues(alpha: 0.85)
                            : const Color(0xFFFB7701).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isGrouped ? 'Groupe' : 'Single',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: _onBackground,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: GoogleFonts.plusJakartaSans(
                      color: _onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
