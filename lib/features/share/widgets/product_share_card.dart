import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/models.dart';
import '../providers/share_product_provider.dart';
import '../services/native_share_service.dart';
import 'group_progress_bar.dart';
import 'product_image_widget.dart';

class ProductShareCard extends ConsumerWidget {
  final Product product;

  const ProductShareCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shareState = ref.watch(shareProductProvider(product));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header with Points Badge
          Stack(
            children: [
              ProductImageWidget(
                imageUrl: product.imageUrl,
                height: 180,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB7701),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFB7701).withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${product.pointsValue} pts / vente',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (product.isGrouped)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF251912).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Offre Groupe',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF251912),
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${product.price.toStringAsFixed(0)} DH',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFB7701),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Realtime Product Group Progress Section
                if (shareState.productGroup != null) ...[
                  GroupProgressBar(group: shareState.productGroup!),
                  const SizedBox(height: 16),
                ],

                // Action Buttons (Copy Link & Share)
                if (shareState.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFB7701)),
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      // Copy Link Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: shareState.referralUrl == null
                              ? null
                              : () async {
                                  await NativeShareService.copyToClipboard(shareState.referralUrl!);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Lien de parrainage copié !',
                                          style: GoogleFonts.plusJakartaSans(),
                                        ),
                                        backgroundColor: const Color(0xFF2E7D32),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF8A461E)),
                          label: Text(
                            'Copier',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8A461E),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0D5CB), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Native Share Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: shareState.referralUrl == null
                              ? null
                              : () {
                                  NativeShareService.shareReferralLink(
                                    productName: product.name,
                                    referralUrl: shareState.referralUrl!,
                                  );
                                },
                          icon: const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                          label: Text(
                            'Partager le produit',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFB7701),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
