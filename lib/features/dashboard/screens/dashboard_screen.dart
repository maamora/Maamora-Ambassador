import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ambassador_state_provider.dart';
import '../../../models/models.dart';
import '../../groups/providers/my_groups_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/navigation/app_routes.dart';
import 'package:go_router/go_router.dart';

// ── Design tokens (match project palette) ─────────────────────────────────
const Color _primary = Color(0xFFFB7701); // orange
const Color _secondary = Color(0xFF1A2433); // dark navy
const Color _background = Color(0xFFFAF5F0); // warm cream
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);
const Color _orangeLight = Color(0xFFFFF0E6);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambassadorState = ref.watch(ambassadorStateProvider);
    final groupsAsync = ref.watch(myGroupsProvider);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ambassadorState.isLoading
            ? const Center(child: CircularProgressIndicator(color: _primary))
            : ambassadorState.ambassador == null
                ? Center(child: Text(ambassadorState.errorMessage ?? 'Error'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GreetingHeader(ambassador: ambassadorState.ambassador!),
                        const SizedBox(height: 16),
                        _NextLevelCard(ambassador: ambassadorState.ambassador!),
                        const SizedBox(height: 16),
                        _ShareButton(),
                        const SizedBox(height: 24),
                        _ActiveGroupsSection(groupsAsync: groupsAsync),
                        const SizedBox(height: 16),
                        const _TotalEarnedCard(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
      ),
    );
  }
}
// ── Greeting Header ─────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final Ambassador ambassador;

  const _GreetingHeader({required this.ambassador});

  @override
  Widget build(BuildContext context) {
    final name = ambassador.fullName.split(' ').first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salam, $name 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _onBackground,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here is a quick look at your earnings and active groups.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: _onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _LevelBadge(label: '${ambassador.level.label} · ${(ambassador.level.commissionRate * 100).toInt()}%'),
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String label;
  const _LevelBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.military_tech_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Next Level Card ─────────────────────────────────────────────────────────

class _NextLevelCard extends StatelessWidget {
  final Ambassador ambassador;

  const _NextLevelCard({required this.ambassador});

  @override
  Widget build(BuildContext context) {
    // Logic: threshold for Bronze->Silver is 6, Silver->Gold is 27.
    int totalOrders = 6;
    String nextLevelName = 'Silver Tier';
    
    if (ambassador.level == AmbassadorLevel.silver) {
      totalOrders = 27;
      nextLevelName = 'Gold Tier';
    } else if (ambassador.level == AmbassadorLevel.gold) {
      totalOrders = ambassador.totalValidatedMembers; // max level
      nextLevelName = 'Max Tier';
    }

    final completedOrders = ambassador.totalValidatedMembers;
    final progress = totalOrders > 0 ? (completedOrders / totalOrders).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ambassador.level == AmbassadorLevel.gold ? 'CURRENT LEVEL' : 'NEXT LEVEL',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextLevelName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _onBackground,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: _primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '5 days left',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '12 orders needed',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _onSurfaceVariant,
                ),
              ),
              Text(
                '$completedOrders/$totalOrders',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDE8E4),
              valueColor: const AlwaysStoppedAnimation<Color>(_primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Share Button ─────────────────────────────────────────────────────────────

class _ShareButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => context.push(AppRoutes.createGroup),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          'Propose a new group',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ── Active Groups Section ────────────────────────────────────────────────────

class _ActiveGroupsSection extends StatelessWidget {
  final AsyncValue<List<DealGroup>> groupsAsync;

  const _ActiveGroupsSection({required this.groupsAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Active Groups',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _onBackground,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: _primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See all',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        groupsAsync.when(
          data: (groups) {
            final activeGroups = groups.where((g) => g.status == DealGroupStatus.open).take(2).toList();
            if (activeGroups.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No active groups.'),
              );
            }
            return Column(
              children: activeGroups.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _GroupCard(
                  productEmoji: '🛍️', // Use emoji fallback
                  name: g.productName,
                  seatsFilled: g.membersCount,
                  totalSeats: g.seatsTotal,
                  timeRemaining: 'Active',
                  isCountdown: false,
                  estimatedEarnings: (g.estimatedTotalValue * 0.06).toInt(), // Approximation
                ),
              )).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: _primary)),
          error: (err, _) => Text('Error loading groups: $err'),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String productEmoji;
  final String name;
  final int seatsFilled;
  final int totalSeats;
  final String timeRemaining;
  final bool isCountdown;
  final int estimatedEarnings;

  const _GroupCard({
    required this.productEmoji,
    required this.name,
    required this.seatsFilled,
    required this.totalSeats,
    required this.timeRemaining,
    required this.isCountdown,
    required this.estimatedEarnings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Product image placeholder
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDE4),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(productEmoji, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
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
                          '$seatsFilled/$totalSeats filled',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          isCountdown
                              ? Icons.timer_outlined
                              : Icons.access_time_rounded,
                          size: 14,
                          color: isCountdown ? Colors.red.shade400 : _onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeRemaining,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isCountdown
                                ? Colors.red.shade400
                                : _onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEDE8E4), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Earnings',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _onSurfaceVariant,
                ),
              ),
              Text(
                '$estimatedEarnings DH',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A5FAD),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Total Earned Card ────────────────────────────────────────────────────────

class _TotalEarnedCard extends StatefulWidget {
  const _TotalEarnedCard();

  @override
  State<_TotalEarnedCard> createState() => _TotalEarnedCardState();
}

class _TotalEarnedCardState extends State<_TotalEarnedCard> {
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await supabaseService.getMyWalletBalance();
    if (mounted) setState(() => _balance = balance);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: _orangeLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD4A8)),
      ),
      child: Column(
        children: [
          Text(
            'Total earned',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _onBackground,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${_balance.toStringAsFixed(0)} ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
                TextSpan(
                  text: 'DH',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View rank and history',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _secondary,
                    decoration: TextDecoration.underline,
                    decorationColor: _secondary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 14, color: _secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
