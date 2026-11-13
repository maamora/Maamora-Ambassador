import 'package:flutter/material.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/my_groups_provider.dart';
import '../../../shared/widgets/design_kit.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

// Colors: charte centralisée (tokens DS)
const Color _surface = MaamoraColors.surface;
const Color _surfaceContainerLowest = MaamoraColors.surface;
const Color _onBackground = MaamoraColors.textPrimary;
const Color _onSurfaceVariant = MaamoraColors.textSecondary;
const Color _outlineVariant = MaamoraColors.border;

class MyGroupsScreen extends ConsumerWidget {
  const MyGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(myGroupsProvider);

    return Scaffold(
      backgroundColor: _surface,
      appBar: const SharedAppBar(),
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
                    context.tr('groups_title'),
                    style: GoogleFonts.cairo(
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
                      return MaamoraEmptyState(
                        icon: MaamoraIcons.users,
                        title: context.tr('groups_empty'),
                        subtitle: context.tr('groups_empty_sub'),
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
                              SnackBar(content: Text(context.tr('groups_order_soon'))),
                            );
                          },
                          onInvite: () {
                            // TODO: Implement direct share logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('groups_share_soon'))),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const AppSkeletonList(count: 4),
                  error: (err, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr('groups_failed'),
                          style: GoogleFonts.cairo(color: MaamoraColors.danger),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(myGroupsProvider.notifier).refresh(),
                          child: Text(context.tr('common_retry')),
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
                color: MaamoraColors.creamIntense,
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
                    style: GoogleFonts.cairo(
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
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ThinProgress(value: progressRatio, height: 6),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isConfirmed ? MaamoraColors.successSoft : _outlineVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isConfirmed ? context.tr('groups_confirmed') : context.tr('groups_pending'),
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isConfirmed ? MaamoraColors.success : _onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
