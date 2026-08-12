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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Groups',
                    style: GoogleFonts.plusJakartaSans(
                      color: _onBackground,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
                          isUnlocked: g.isComplete,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createGroup),
        backgroundColor: _primaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
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
  final bool isUnlocked;
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
    required this.isUnlocked,
    required this.originalPrice,
    this.prixGroupe,
    required this.onTap,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmed = isUnlocked;
    final statusLabel = isConfirmed ? 'CONFIRMÉ' : 'EN COURS';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 140,
                width: double.infinity,
                color: const Color(0xFFF6DED2),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: _outlineVariant,
                        ))
                    : const Icon(Icons.image_not_supported_outlined,
                        size: 48, color: _outlineVariant),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: _onBackground,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isConfirmed
                        ? _primaryContainer
                        : const Color(0xFFFBE3D8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isConfirmed ? Icons.check_circle : Icons.circle,
                        color: isConfirmed ? Colors.white : _primaryContainer,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: GoogleFonts.inter(
                          color:
                              isConfirmed ? Colors.white : _onBackground,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: _outlineVariant, height: 1),
            const SizedBox(height: 16),
            if (isConfirmed)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          color: _onSurfaceVariant, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$membersCount/$membersTotal membres',
                        style: GoogleFonts.inter(
                          color: _onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (prixGroupe != null)
                    Text(
                      '${prixGroupe!.toStringAsFixed(0)} DH',
                      style: GoogleFonts.plusJakartaSans(
                        color: _primaryContainer,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      backgroundColor: const Color(0xFFFBE3D8),
                      color: _primaryContainer,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline,
                              color: _onSurfaceVariant, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$membersCount/$membersTotal membres',
                            style: GoogleFonts.inter(
                              color: _onSurfaceVariant,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${membersTotal - membersCount} restants',
                        style: GoogleFonts.inter(
                          color: _onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            // ── Invite Button ───────────────────────────────────────────
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primaryContainer, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onInvite,
                icon: const Icon(Icons.group_add_outlined,
                    color: _primaryContainer, size: 20),
                label: Text(
                  'Invite Friends',
                  style: GoogleFonts.inter(
                    color: _primaryContainer,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
