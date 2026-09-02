import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/navigation/app_routes.dart';
import '../providers/my_groups_provider.dart';

// Colors matched with dashboard
const Color _primaryContainer = Color(0xFFFB7701);
const Color _surface = Color(0xFFFFF8F5);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF251912);
const Color _onSurfaceVariant = Color(0xFF584236);
const Color _outlineVariant = Color(0xFFE0C0B0);

class MyGroupsScreen extends ConsumerWidget {
  const MyGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(myGroupsProvider);

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
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _onBackground, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'My Groups',
                    style: GoogleFonts.plusJakartaSans(
                      color: _onBackground,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: _onSurfaceVariant),
                    onPressed: () => ref.read(myGroupsProvider.notifier).refresh(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: groupsAsync.when(
                  data: (groups) {
                    if (groups.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.group_outlined,
                                size: 64, color: _outlineVariant),
                            const SizedBox(height: 16),
                            Text(
                              'No groups yet',
                              style: GoogleFonts.plusJakartaSans(
                                color: _onBackground,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Share a product to create your first group!',
                              style: GoogleFonts.inter(
                                color: _onSurfaceVariant,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: groups.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        final g = groups[index];
                        return _GroupOrderCard(
                          imageUrl: g.productImageUrl ?? '',
                          title: g.productName,
                          membersCount: g.membersCount,
                          membersTotal: g.seatsTotal,
                          statut: g.status.name,
                          progressRatio: g.progressRatio,
                          isConfirmed: g.commissionAssigned,
                          prixGroupe: g.pricePerPerson,
                          originalPrice: g.pricePerPerson,
                          onTap: () {
                            // TODO: Add new flow for order details if needed
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order details not available in this version.')),
                            );
                          },
                          onInvite: () {
                            // TODO: Implement direct share logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Share functionality coming soon.')),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: _primaryContainer),
                  ),
                  error: (err, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load groups',
                          style: GoogleFonts.inter(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(myGroupsProvider.notifier).refresh(),
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

class _GroupOrderCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final int membersCount;
  final int membersTotal;
  final String statut;
  final double progressRatio;
  final bool isConfirmed;
  final double? prixGroupe;
  final double originalPrice;
  final VoidCallback onTap;
  final VoidCallback onInvite;

  const _GroupOrderCard({
    required this.imageUrl,
    required this.title,
    required this.membersCount,
    required this.membersTotal,
    required this.statut,
    required this.progressRatio,
    required this.isConfirmed,
    required this.originalPrice,
    this.prixGroupe,
    required this.onTap,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product image small
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                height: 64,
                color: const Color(0xFFF5EDE4),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 24,
                          color: _outlineVariant,
                        ))
                    : const Icon(Icons.image_not_supported_outlined,
                        size: 24, color: _outlineVariant),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _onBackground,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_alt_outlined,
                          size: 14, color: _onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '$membersCount/$membersTotal filled',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isConfirmed ? const Color(0xFF198754).withValues(alpha: 0.1) : _outlineVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isConfirmed ? 'Confirmed' : 'Pending',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isConfirmed ? const Color(0xFF198754) : _onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
