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
    int totalOrders = 6;
    String nextLevelName = 'Bronze Tier';
    
    if (ambassador.level == AmbassadorLevel.neutral) {
      totalOrders = 6;
      nextLevelName = 'Bronze Tier';
    } else if (ambassador.level == AmbassadorLevel.bronze) {
      totalOrders = 27;
      nextLevelName = 'Silver Tier';
    } else if (ambassador.level == AmbassadorLevel.silver) {
      totalOrders = 360; // 6 groups of 60+ orders
      nextLevelName = 'Gold Tier';
    } else if (ambassador.level == AmbassadorLevel.gold) {
      totalOrders = ambassador.totalValidatedMembers > 0 ? ambassador.totalValidatedMembers : 1; 
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
              if (ambassador.level != AmbassadorLevel.gold)
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: _primary, size: 16),
                    const SizedBox(width: 4),
                    Builder(
                      builder: (context) {
                        int daysLeft = 0;
                        if (ambassador.activatedAt != null) {
                          final now = DateTime.now();
                          final diff = now.difference(ambassador.activatedAt!).inDays;
                          if (diff <= 7) {
                            daysLeft = 7 - diff;
                          } else {
                            final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
                            daysLeft = daysInMonth - now.day;
                          }
                        }
                        return Text(
                          '$daysLeft days left',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        );
                      }
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
                ambassador.level == AmbassadorLevel.gold 
                    ? 'Max rank achieved' 
                    : '${(totalOrders - completedOrders).clamp(0, totalOrders)} orders needed',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _onSurfaceVariant,
                ),
              ),
              Text(
                ambassador.level == AmbassadorLevel.gold 
                    ? '$completedOrders'
                    : '$completedOrders/$totalOrders',
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

class _ActiveGroupsSection extends ConsumerWidget {
  final AsyncValue<List<DealGroup>> groupsAsync;

  const _ActiveGroupsSection({required this.groupsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambassadorState = ref.watch(ambassadorStateProvider);
    final commissionRate = ambassadorState.ambassador?.level.commissionRate ?? 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My groups',
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
            final activeGroups = groups.where((g) => g.status != DealGroupStatus.cancelled).take(2).toList();
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
                  groupId: g.id,
                  productEmoji: '🛍️', // Use emoji fallback
                  name: g.productName,
                  seatsFilled: g.membersCount,
                  totalSeats: g.seatsTotal,
                  timeRemaining: 'Active',
                  isCountdown: false,
                  productPrice: g.pricePerPerson.toInt(),
                  estimatedEarnings: (g.pricePerPerson * g.seatsTotal * commissionRate).toInt(),
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

class _GroupCard extends ConsumerStatefulWidget {
  final String groupId;
  final String productEmoji;
  final String name;
  final int seatsFilled;
  final int totalSeats;
  final String timeRemaining;
  final bool isCountdown;
  final int productPrice;
  final int estimatedEarnings;

  const _GroupCard({
    required this.groupId,
    required this.productEmoji,
    required this.name,
    required this.seatsFilled,
    required this.totalSeats,
    required this.timeRemaining,
    required this.isCountdown,
    required this.productPrice,
    required this.estimatedEarnings,
  });

  @override
  ConsumerState<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends ConsumerState<_GroupCard> {
  bool _isAddingMember = false;

  bool get _isFull => widget.seatsFilled >= widget.totalSeats;

  Future<void> _handleAddMember() async {
    if (_isFull) return;

    // Show the bottom sheet and wait for the chosen count
    final count = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMembersSheet(
        groupName: widget.name,
        available: widget.totalSeats - widget.seatsFilled,
      ),
    );

    if (count == null || count <= 0) return;

    setState(() => _isAddingMember = true);
    try {
      await ref.read(myGroupsProvider.notifier).addParticipant(
        widget.groupId,
        count: count,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              count == 1 ? '1 member added ✓' : '$count members added ✓',
            ),
            backgroundColor: const Color(0xFF198754),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add members: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingMember = false);
    }
  }

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
                child: Text(widget.productEmoji, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isFull ? '${widget.name} · closed ✓' : widget.name,
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
                          _isFull 
                              ? '${widget.seatsFilled} of ${widget.totalSeats} seats'
                              : '${widget.seatsFilled}/${widget.totalSeats} filled',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _onSurfaceVariant,
                          ),
                        ),
                        if (!_isFull) ...[
                          const SizedBox(width: 12),
                          Icon(
                            widget.isCountdown
                                ? Icons.timer_outlined
                                : Icons.access_time_rounded,
                            size: 14,
                            color: widget.isCountdown ? Colors.red.shade400 : _onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.timeRemaining,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: widget.isCountdown
                                  ? Colors.red.shade400
                                  : _onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_isFull)
                Text(
                  '+${widget.estimatedEarnings} DH',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF198754),
                  ),
                )
              else
                _AddMemberButton(
                  isFull: _isFull,
                  isLoading: _isAddingMember,
                  onPressed: _handleAddMember,
                ),
            ],
          ),
          if (!_isFull) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFEDE8E4), height: 1),
            const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Price',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${widget.productPrice} DH',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _onBackground,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                    '${widget.estimatedEarnings} DH',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A5FAD),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ],
        ],
      ),
    );
  }
}

// ── Add Member Button ────────────────────────────────────────────────────────

class _AddMemberButton extends StatelessWidget {
  final bool isFull;
  final bool isLoading;
  final VoidCallback onPressed;

  const _AddMemberButton({
    required this.isFull,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isFull || isLoading;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: disabled ? const Color(0xFFF5EDE4) : _orangeLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: disabled ? _cardBorder : _primary),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
                    )
                  : Icon(
                      Icons.group_add_rounded,
                      size: 14,
                      color: disabled ? _onSurfaceVariant : _primary,
                    ),
              const SizedBox(width: 6),
              Text(
                isFull ? 'Full' : 'Add Members',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: disabled ? _onSurfaceVariant : _primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add Members Bottom Sheet ────────────────────────────────────────────────

class _AddMembersSheet extends StatefulWidget {
  final String groupName;
  final int available; // max seats left

  const _AddMembersSheet({
    required this.groupName,
    required this.available,
  });

  @override
  State<_AddMembersSheet> createState() => _AddMembersSheetState();
}

class _AddMembersSheetState extends State<_AddMembersSheet> {
  int _count = 1;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setCount(int v) {
    final clamped = v.clamp(1, widget.available.clamp(1, 9999));
    setState(() => _count = clamped);
    _controller.text = '$clamped';
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: _cardBorder,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Title
          Text(
            'How many members joined?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.groupName,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 28),
          // Stepper row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrement
              _StepBtn(
                icon: Icons.remove_rounded,
                enabled: _count > 1,
                onTap: () => _setCount(_count - 1),
              ),
              const SizedBox(width: 16),
              // Number input
              Container(
                width: 80,
                decoration: BoxDecoration(
                  color: _orangeLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _cardBorder),
                ),
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: _onBackground,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (v) {
                    final parsed = int.tryParse(v);
                    if (parsed != null) _setCount(parsed);
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Increment
              _StepBtn(
                icon: Icons.add_rounded,
                enabled: _count < widget.available,
                onTap: () => _setCount(_count + 1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.available} seat${widget.available == 1 ? '' : 's'} remaining',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          // Quick select chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [5, 10, 20, 50]
                .where((n) => n <= widget.available)
                .map(
                  (n) => GestureDetector(
                    onTap: () => _setCount(n),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _count == n ? _primary : _orangeLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _count == n ? _primary : _cardBorder,
                        ),
                      ),
                      child: Text(
                        '+$n',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _count == n ? Colors.white : _primary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 28),
          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_count),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _count == 1 ? 'Add 1 Member' : 'Add $_count Members',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? _primary : const Color(0xFFEDE8E4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : _onSurfaceVariant,
          size: 22,
        ),
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
