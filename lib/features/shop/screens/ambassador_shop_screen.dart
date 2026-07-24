import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/models.dart';
import '../../share/providers/share_product_provider.dart';

// ─── Design tokens ───────────────────────────────────────────────────────────
const Color _kOrange = Color(0xFFFB7701);
const Color _kSurface = Color(0xFFFFF8F5);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kOnBg = Color(0xFF251912);
const Color _kOnSurfaceVariant = Color(0xFF584236);
const Color _kOutlineVariant = Color(0xFFE0C0B0);
const Color _kSurfaceContainer = Color(0xFFFBE3D8);
const Color _kSurfaceContainerHigh = Color(0xFFFBE3D8);

class AmbassadorShopScreen extends ConsumerWidget {
  final Product product;

  const AmbassadorShopScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shareState = ref.watch(shareProductProvider(product));
    final group = shareState.productGroup;
    final int current = group?.compteurActuel ?? 0;
    final int target = group?.seuilMin ?? 5;
    final int remaining = (target - current).clamp(0, target);
    final double progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final bool isUnlocked = group?.isUnlocked ?? false;
    final double groupPrice = group?.prixGroupe ?? product.price * 0.85;
    final int discountPct =
        product.price > 0 ? ((1 - groupPrice / product.price) * 100).round() : 15;

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kWhite,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: _kOnBg),
        ),
        title: Text(
          'MAAMORA',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1A2433),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: _kOnSurfaceVariant),
                onPressed: () {},
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _kOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: _kWhite, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ──────────────────────────────────────────────
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF4EDE4),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported_outlined,
                              size: 64, color: _kOutlineVariant),
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          size: 64, color: _kOutlineVariant),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Product Header ───────────────────────────────────────
                  Text(
                    product.type.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: _kOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: GoogleFonts.plusJakartaSans(
                      color: _kOnBg,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Partagez ce produit avec votre réseau et débloquez une réduction groupe de $discountPct% dès $target membres.',
                    style: GoogleFonts.inter(
                      color: _kOnSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (shareState.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              shareState.errorMessage!,
                              style: GoogleFonts.inter(
                                color: Colors.red.shade900,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Group Progress Card ──────────────────────────────────
                  _GroupProgressCard(
                    isLoading: shareState.isLoading,
                    current: current,
                    target: target,
                    remaining: remaining,
                    progress: progress,
                    isUnlocked: isUnlocked,
                    groupPrice: groupPrice,
                    originalPrice: product.price,
                    discountPct: discountPct,
                  ),

                  const SizedBox(height: 24),

                  // ── Action Buttons ───────────────────────────────────────
                  // "Join Group" = share the referral link so others join
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _kOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      onPressed: shareState.isLoading || shareState.referralUrl == null
                          ? null
                          : () {
                              Share.share(
                                '🎉 Rejoignez mon groupe pour ${product.name} et économisez $discountPct% ! '
                                '${shareState.referralUrl}',
                              );
                            },
                      child: shareState.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Join Group',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // "Start New Group" = explicit create (force new group creation)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _kOnSurfaceVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: shareState.isLoading
                          ? null
                          : () {
                              // Refresh provider — triggers getOrCreateProductGroup again
                              // and opens share dialogue once referralUrl is ready
                              ref
                                  .read(shareProductProvider(product).notifier)
                                  .initialize();
                            },
                      child: Text(
                        'Start New Group',
                        style: GoogleFonts.inter(
                          color: _kOnSurfaceVariant,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Group Progress Card ──────────────────────────────────────────────────────
class _GroupProgressCard extends StatelessWidget {
  final bool isLoading;
  final int current;
  final int target;
  final int remaining;
  final double progress;
  final bool isUnlocked;
  final double groupPrice;
  final double originalPrice;
  final int discountPct;

  const _GroupProgressCard({
    required this.isLoading,
    required this.current,
    required this.target,
    required this.remaining,
    required this.progress,
    required this.isUnlocked,
    required this.groupPrice,
    required this.originalPrice,
    required this.discountPct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2433).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(color: _kOrange),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: avatars + joined badge ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Stacked avatar circles
                    _StackedAvatars(count: current),
                    // Joined badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kWhite,
                        border: Border.all(color: _kOutlineVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$current/$target JOINED',
                        style: GoogleFonts.inter(
                          color: _kOnSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Progress bar ─────────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: _kSurfaceContainer,
                    color: _kOrange,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Label row ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isUnlocked ? Icons.lock_open_outlined : Icons.lock_outline,
                          size: 14,
                          color: _kOnSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isUnlocked
                              ? 'Groupe débloqué!'
                              : '$remaining more to unlock -$discountPct%',
                          style: GoogleFonts.inter(
                            color: _kOnSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Target: $target',
                      style: GoogleFonts.inter(
                        color: _kOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                // ── Pricing ──────────────────────────────────────────────
                const SizedBox(height: 16),
                const Divider(color: _kSurfaceContainer, height: 1),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${groupPrice.toStringAsFixed(2)} DH',
                      style: GoogleFonts.plusJakartaSans(
                        color: _kOnBg,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '${originalPrice.toStringAsFixed(2)} DH',
                        style: GoogleFonts.inter(
                          color: _kOnSurfaceVariant,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kSurfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Save $discountPct%',
                        style: GoogleFonts.inter(
                          color: _kOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

// ─── Stacked Avatar Circles ───────────────────────────────────────────────────
class _StackedAvatars extends StatelessWidget {
  final int count;

  const _StackedAvatars({required this.count});

  // Placeholder avatar colors when no real photos are available
  static const List<Color> _colors = [
    Color(0xFFFB7701),
    Color(0xFF1B6194),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
  ];

  @override
  Widget build(BuildContext context) {
    final int shown = count.clamp(0, 3);
    final int extra = (count - 3).clamp(0, 99);
    final double overlap = -10.0;

    return Row(
      children: [
        for (int i = 0; i < shown; i++)
          Transform.translate(
            offset: Offset(i * overlap, 0),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _colors[i % _colors.length],
                border: Border.all(color: _kWhite, width: 2),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        if (extra > 0)
          Transform.translate(
            offset: Offset(shown * overlap, 0),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kSurfaceContainer,
                border: Border.all(color: _kWhite, width: 2),
              ),
              child: Center(
                child: Text(
                  '+$extra',
                  style: GoogleFonts.inter(
                    color: _kOnSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
