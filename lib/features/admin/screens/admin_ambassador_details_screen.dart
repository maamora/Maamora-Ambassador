import 'package:flutter/material.dart';
import 'admin_profile_screen.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import '../../../shared/widgets/design_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../widgets/admin_status_badge.dart';
import '../../../models/models.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = MaamoraColors.primary;
const Color _background = MaamoraColors.scaffold;
const Color _surface = MaamoraColors.surface;
const Color _onBackground = MaamoraColors.textPrimary;
const Color _onSurfaceVariant = MaamoraColors.textSecondary;
const Color _cardBorder = MaamoraColors.border;
const Color _errorColor = MaamoraColors.danger;
const Color _successColor = MaamoraColors.success;

class AdminAmbassadorDetailsScreen extends StatefulWidget {
  final String ambassadorId;
  const AdminAmbassadorDetailsScreen({super.key, required this.ambassadorId});

  @override
  State<AdminAmbassadorDetailsScreen> createState() =>
      _AdminAmbassadorDetailsScreenState();
}

class _AdminAmbassadorDetailsScreenState
    extends State<AdminAmbassadorDetailsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  Ambassador? _ambassador;
  String? _parentAmbassadorName;
  double _walletBalance = 0.0;
  List<Commission> _commissions = [];
  List<dynamic> _dealGroups = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      final ambResponse = await supabase
          .from('ambassadors')
          .select()
          .eq('id', widget.ambassadorId)
          .single();

      final ambassador = Ambassador.fromJson(ambResponse);

      String? parentName;
      if (ambassador.invitedByAmbassadorId != null) {
        final parentRes = await supabase
            .from('ambassadors')
            .select('full_name')
            .eq('id', ambassador.invitedByAmbassadorId!)
            .maybeSingle();
        if (parentRes != null) {
          parentName = parentRes['full_name'] as String?;
        }
      }

      final commsRes = await supabase
          .from('commissions')
          .select('*, deal_groups(product_name)')
          .eq('ambassador_id', widget.ambassadorId)
          .order('created_at', ascending: false);

      final List<dynamic> commsData = commsRes;
      final commissions = commsData.map((e) => Commission.fromJson(e)).toList();

      double balance = 0.0;
      for (var c in commissions) {
        if (c.status == CommissionStatus.payable) {
          balance += c.amount;
        }
      }

      final groupsRes = await supabase
          .from('deal_groups')
          .select('*, product_name')
          .eq('ambassador_id', widget.ambassadorId)
          .order('created_at', ascending: false);

      setState(() {
        _ambassador = ambassador;
        _parentAmbassadorName = parentName;
        _commissions = commissions;
        _walletBalance = balance;
        _dealGroups = groupsRes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching ambassador details: $e');
      setState(() {
        _errorMessage = context.tr('ad_det_load_err');
        _isLoading = false;
      });
    }
  }

  Future<void> _changeStatus(String newStatus, {String? reason}) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            const Center(child: CircularProgressIndicator(color: _primary)),
      );

      await Supabase.instance.client.rpc(
        'admin_set_ambassador_status',
        params: {
          'p_ambassador_id': widget.ambassadorId,
          'p_status': newStatus,
          'p_reason': reason,
        },
      );

      if (mounted) {
        Navigator.pop(context);
        _fetchDetails();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        _showError(context.tr('ad_status_err', args: {'e': e.toString()}));
      }
    }
  }

  Future<bool> _confirm(
    String title,
    String body,
    Color color,
    String confirmLabel,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: MaamoraRadius.cardR),
        title: Text(
          title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: body.isEmpty ? null : Text(body, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              ctx.tr('common_cancel'),
              style: GoogleFonts.cairo(color: _onSurfaceVariant),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _handleAccept() async {
    final name = _ambassador?.fullName ?? '';
    if (!await _confirm(
      context.tr('ad_accept_confirm_title'),
      context.tr('ad_accept_confirm_body', args: {'name': name}),
      _successColor,
      context.tr('ad_accept_btn'),
    )) {
      return;
    }
    await _changeStatus('active');
  }

  Future<void> _handleReject() async {
    final reason = await _promptReason(context.tr('ad_reason_reject'));
    if (reason != null && reason.isNotEmpty) {
      await _changeStatus('rejected', reason: reason);
    }
  }

  Future<void> _handleSuspend() async {
    final reason = await _promptReason(context.tr('ad_reason_suspend'));
    if (reason != null && reason.isNotEmpty) {
      await _changeStatus('paused', reason: reason);
    }
  }

  Future<void> _handleReactivate() async {
    final name = _ambassador?.fullName ?? '';
    if (!await _confirm(
      context.tr('ad_reactivate_confirm', args: {'name': name}),
      '',
      _successColor,
      context.tr('ad_reactivate'),
    )) {
      return;
    }
    await _changeStatus('active');
  }

  Future<String?> _promptReason(String title) async {
    final tc = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: Text(
          title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: TextField(
          controller: tc,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: context.tr('ad_reason_hint'),
            border: OutlineInputBorder(borderRadius: MaamoraRadius.inputR),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(
              ctx.tr('common_cancel'),
              style: GoogleFonts.cairo(color: _onSurfaceVariant),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: tc,
            builder: (_, value, _) => ElevatedButton(
              onPressed: value.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(ctx, tc.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _errorColor,
                foregroundColor: MaamoraColors.onPrimary,
              ),
              child: Text(ctx.tr('common_confirm')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayout() async {
    String method = 'bank';
    final tcRef = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              backgroundColor: _surface,
              title: Text(
                context.tr('ad_wallet_pay'),
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                      'ad_wallet_amount',
                      args: {'n': _walletBalance.toStringAsFixed(2)},
                    ),
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('ad_method_lbl'),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: _onSurfaceVariant,
                    ),
                  ),
                  DropdownButton<String>(
                    value: method,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: 'bank',
                        child: Text(context.tr('profile_payout_bank')),
                      ),
                      DropdownMenuItem(
                        value: 'cash_pickup',
                        child: Text(context.tr('wallet_tx_cash')),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setStateModal(() => method = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('ad_ref_lbl'),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: _onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tcRef,
                    decoration: InputDecoration(
                      hintText: context.tr('ad_ref_hint'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    ctx.tr('common_cancel'),
                    style: GoogleFonts.cairo(color: _onSurfaceVariant),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successColor,
                    foregroundColor: MaamoraColors.onPrimary,
                  ),
                  child: Text(context.tr('ad_pay_validate')),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      if (!mounted) return;
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              const Center(child: CircularProgressIndicator(color: _primary)),
        );

        await Supabase.instance.client.rpc(
          'admin_create_payout',
          params: {
            'p_ambassador_id': widget.ambassadorId,
            'p_method': method,
            'p_reference': tcRef.text.trim(),
          },
        );

        if (mounted) {
          Navigator.pop(context); // close loading
          MaamoraToast.success(context, context.tr('ad_pay_saved'));
          _fetchDetails(); // refresh balance
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          _showError(context.tr('ad_pay_err', args: {'e': e.toString()}));
        }
      }
    }
  }

  void _showError(String msg) {
    MaamoraToast.error(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: SharedAppBar(
        pageTitle: context.tr('ad_det_title'),
        onAvatarTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AdminProfileScreen())),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(MaamoraSpacing.lg),
        child: Column(
          children: [
            MaamoraSkeletonHero(height: 180),
            SizedBox(height: MaamoraSpacing.lg),
            MaamoraSkeletonList(count: 3),
          ],
        ),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(MaamoraSpacing.screen),
          child: MaamoraErrorState(
            title: _errorMessage!,
            onRetry: _fetchDetails,
          ),
        ),
      );
    }

    if (_ambassador == null) {
      return Center(child: Text(context.tr('ad_det_not_found')));
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _fetchDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(MaamoraSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: MaamoraSpacing.lg),
            if (_ambassador!.status != AmbassadorStatus.rejected)
              _buildActionsCard(),
            const SizedBox(height: MaamoraSpacing.xl),
            _buildCommissionsSection(),
            const SizedBox(height: MaamoraSpacing.xl),
            _buildGroupsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final a = _ambassador!;

    final parts = a.fullName.split(' ');
    String initials = '';
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials += parts[0][0].toUpperCase();
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      initials += parts[1][0].toUpperCase();
    }

    String joinedDate = context.tr('common_na');
    if (a.activatedAt != null) {
      joinedDate = DateFormat('dd/MM/yyyy').format(a.activatedAt!);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: MaamoraShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _cardBorder,
                child: Text(
                  initials,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.fullName,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        AdminStatusBadge(status: a.status.value),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _levelColor(a.level).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            a.level.trLabel(context),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _levelColor(a.level),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.phone_rounded,
            context.tr('ad_phone'),
            a.phone,
            ltr: true,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_outlined,
            context.tr('ad_city'),
            a.city,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            context.tr('ad_date_joined'),
            joinedDate,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.people_alt_rounded,
            context.tr('ad_members_validated'),
            '${a.totalValidatedMembers}',
          ),
          if (_parentAmbassadorName != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.person_add_rounded,
              context.tr('ad_invited_by'),
              _parentAmbassadorName!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool ltr = false,
  }) {
    return Row(
      children: [
        ExcludeSemantics(child: Icon(icon, size: 16, color: _onSurfaceVariant)),
        const SizedBox(width: MaamoraSpacing.sm),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 13, color: _onSurfaceVariant),
        ),
        const SizedBox(width: MaamoraSpacing.md),
        // Long values never push the row off-screen.
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            textDirection: ltr ? TextDirection.ltr : null,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _onBackground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard() {
    final a = _ambassador!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('ad_actions'),
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (a.status == AmbassadorStatus.pending) ...[
                _ActionBtn(
                  label: context.tr('ad_accept_btn'),
                  icon: Icons.check,
                  color: _successColor,
                  onTap: _handleAccept,
                ),
                _ActionBtn(
                  label: context.tr('ad_reject'),
                  icon: Icons.close,
                  color: _errorColor,
                  onTap: _handleReject,
                ),
              ],
              if (a.status == AmbassadorStatus.active)
                _ActionBtn(
                  label: context.tr('ad_suspend'),
                  icon: Icons.pause,
                  color: MaamoraColors.primaryText,
                  onTap: _handleSuspend,
                ),
              if (a.status == AmbassadorStatus.paused)
                _ActionBtn(
                  label: context.tr('ad_reactivate'),
                  icon: Icons.play_arrow,
                  color: _successColor,
                  onTap: _handleReactivate,
                ),
            ],
          ),

          if (_walletBalance > 0) ...[
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('ad_balance'),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: _onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${_walletBalance.toStringAsFixed(2)} DH',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _successColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _handlePayout,
                  icon: const Icon(Icons.account_balance_wallet, size: 18),
                  label: Text(context.tr('ad_wallet_pay')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successColor,
                    foregroundColor: MaamoraColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (a.status != AmbassadorStatus.pending) ...[
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('ad_balance'),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: _onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '0.00 DH',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _onBackground,
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

  Widget _buildCommissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('ad_comm_history'),
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_commissions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                context.tr('ad_comm_empty'),
                style: GoogleFonts.cairo(color: _onSurfaceVariant),
              ),
            ),
          ),
        ..._commissions.map((c) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    c.source == CommissionSource.recruitBonus
                        ? Icons.person_add
                        : Icons.shopping_bag,
                    size: 16,
                    color: _primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.dealGroupName ??
                            (c.source == CommissionSource.recruitBonus
                                ? context.tr('ad_bonus_referral')
                                : 'Commission'),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        c.createdAt != null
                            ? DateFormat('dd/MM/yy HH:mm').format(c.createdAt!)
                            : '',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+${c.amount.toStringAsFixed(2)} DH',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _successColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildCommissionBadge(c.status),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCommissionBadge(CommissionStatus status) {
    Color color;
    String label;
    switch (status) {
      case CommissionStatus.pending:
        color = MaamoraColors.warningDeep;
        label = context.tr('wallet_st_pending');
        break;
      case CommissionStatus.payable:
        color = MaamoraColors.primaryText;
        label = context.tr('wallet_st_payable');
        break;
      case CommissionStatus.paid:
        color = _successColor;
        label = context.tr('wallet_st_paid');
        break;
      case CommissionStatus.voided:
        color = _errorColor;
        label = context.tr('wallet_st_voided');
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MaamoraSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MaamoraRadius.chip),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('ad_groups_created'),
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_dealGroups.isEmpty)
          MaamoraEmptyState(
            icon: MaamoraIcons.users,
            title: context.tr('ad_groups_created_empty'),
          ),
        ..._dealGroups.map((g) {
          final title = g['product_name'] ?? context.tr('ad_group_unknown');
          final members = g['members_count'] ?? 0;
          final maxMembers = g['seats_total'] ?? 0;
          final status = g['status'] ?? 'pending';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        context.tr(
                          'ad_members_fract',
                          args: {'a': '$members', 'b': '$maxMembers'},
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AdminStatusBadge(status: status.toString()),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _levelColor(AmbassadorLevel level) {
    switch (level) {
      case AmbassadorLevel.gold:
        return MaamoraColors.tierGold;
      case AmbassadorLevel.silver:
        return MaamoraColors.tierSilver;
      case AmbassadorLevel.neutral:
        return _onSurfaceVariant;
      case AmbassadorLevel.bronze:
        return MaamoraColors.tierBronze;
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: MaamoraRadius.inputR),
      ),
    );
  }
}
