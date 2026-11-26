import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';
import '../providers/pending_ambassadors_provider.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = MaamoraColors.primary;
const Color _background = MaamoraColors.scaffold;
const Color _surface = MaamoraColors.surface;
const Color _onBackground = MaamoraColors.textPrimary;
const Color _onSurfaceVariant = MaamoraColors.textSecondary;
const Color _cardBorder = MaamoraColors.border;
const Color _success = MaamoraColors.success;
const Color _errorColor = MaamoraColors.danger;

// ── Modèle ───────────────────────────────────────────────────────────────
class Candidate {
  final String id;

  /// Raw value from the database ('' when missing — the UI shows the
  /// translated "unknown" label, never a hardcoded French word).
  final String fullName;
  final String initials;
  final String city;
  final String createdAt;

  // Champs optionnels qui n'ont peut-être pas été demandés ou qui sont gérés
  final String? phone;

  Candidate({
    required this.id,
    required this.fullName,
    required this.initials,
    required this.city,
    required this.createdAt,
    this.phone,
  });

  factory Candidate.fromMap(Map<String, dynamic> map) {
    final String fullName = (map['full_name'] as String?) ?? '';
    final parts = fullName.split(' ');
    String initials = '';
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials += parts[0][0].toUpperCase();
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      initials += parts[1][0].toUpperCase();
    }

    // Formatage de la date relative
    String formattedDate = '';
    if (map['created_at'] != null) {
      final date = DateTime.tryParse(map['created_at']);
      if (date != null) {
        final now = DateTime.now();
        final difference = now.difference(date);
        if (difference.inDays == 0 && now.day == date.day) {
          formattedDate =
              '${date.day.toString().padLeft(2, '0')}'
              '/${date.month.toString().padLeft(2, '0')} — '
              '${DateFormat('HH:mm').format(date)}';
        } else {
          formattedDate =
              '${date.day.toString().padLeft(2, '0')}'
              '/${date.month.toString().padLeft(2, '0')}';
        }
      }
    }

    return Candidate(
      id: map['id']?.toString() ?? '',
      fullName: fullName,
      initials: initials,
      city: (map['city'] as String?) ?? '',
      createdAt: formattedDate,
      phone: map['phone'],
    );
  }

  String displayName(BuildContext context) =>
      fullName.trim().isEmpty ? context.tr('ad_unknown_name') : fullName;

  String displayCity(BuildContext context) =>
      city.trim().isEmpty ? context.tr('ad_unknown_city') : city;
}

class AdminAmbassadorsPendingScreen extends ConsumerStatefulWidget {
  const AdminAmbassadorsPendingScreen({super.key});

  @override
  ConsumerState<AdminAmbassadorsPendingScreen> createState() =>
      _AdminAmbassadorsPendingScreenState();
}

class _AdminAmbassadorsPendingScreenState
    extends ConsumerState<AdminAmbassadorsPendingScreen> {
  int? _expandedIndex;

  List<Candidate> _candidates = [];
  bool _isLoading = true;
  String? _errorMessage;

  /// Candidates with an RPC in flight: their buttons are disabled so a
  /// double tap can never send the status change twice.
  final Set<String> _processing = {};

  @override
  void initState() {
    super.initState();
    _fetchPendingCandidates();
  }

  Future<void> _fetchPendingCandidates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client
          .from('ambassadors')
          .select('id, full_name, city, created_at, phone')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      if (!mounted) return;
      setState(() {
        _candidates = data.map((e) => Candidate.fromMap(e)).toList();
        _isLoading = false;
      });
      // Synchroniser le badge navbar avec la liste réelle (sinon les deux
      // sources divergent quand une candidature arrive pendant la session).
      ref.invalidate(pendingAmbassadorsCountProvider);
    } catch (e) {
      debugPrint('Erreur lors de la récupération des candidatures : $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = context.tr('ad_list_err');
        _isLoading = false;
      });
    }
  }

  /// Asks before validating: the change is visible to the candidate at once.
  Future<void> _confirmAccept(Candidate candidate) async {
    if (_processing.contains(candidate.id)) return;
    final name = candidate.displayName(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: MaamoraRadius.cardR),
        title: Text(
          ctx.tr('ad_accept_confirm_title'),
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _onBackground,
          ),
        ),
        content: Text(
          ctx.tr('ad_accept_confirm_body', args: {'name': name}),
          style: GoogleFonts.cairo(fontSize: 14, color: _onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              ctx.tr('common_cancel'),
              style: GoogleFonts.cairo(
                color: _onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _success),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.tr('ad_accept_btn')),
          ),
        ],
      ),
    );
    if (ok == true && mounted) await _accept(candidate);
  }

  Future<void> _accept(Candidate candidate) async {
    if (_processing.contains(candidate.id)) return;
    setState(() => _processing.add(candidate.id));
    try {
      await Supabase.instance.client.rpc(
        'admin_set_ambassador_status',
        params: {
          'p_ambassador_id': candidate.id,
          'p_status': 'active',
          'p_reason': null,
        },
      );

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _candidates.removeWhere((c) => c.id == candidate.id);
        _expandedIndex = null;
      });
      ref.invalidate(pendingAmbassadorsCountProvider);

      if (mounted) {
        MaamoraToast.success(
          context,
          context.tr(
            'ad_accepted',
            args: {'name': candidate.displayName(context)},
          ),
        );
      }
    } catch (e) {
      debugPrint('[AdminPending] accept error: $e');
      if (mounted) {
        MaamoraToast.error(context, context.tr('ad_accept_failed'));
      }
    } finally {
      if (mounted) setState(() => _processing.remove(candidate.id));
    }
  }

  void _showRejectDialog(Candidate candidate) {
    if (_processing.contains(candidate.id)) return;
    showDialog(
      context: context,
      builder: (ctx) => _RejectDialog(
        candidate: candidate,
        onConfirm: (reason) async {
          Navigator.of(ctx).pop();
          if (_processing.contains(candidate.id)) return;
          setState(() => _processing.add(candidate.id));

          try {
            await Supabase.instance.client.rpc(
              'admin_set_ambassador_status',
              params: {
                'p_ambassador_id': candidate.id,
                'p_status': 'rejected',
                'p_reason': reason.isNotEmpty
                    ? reason
                    : context.tr('ad_app_refused'),
              },
            );

            if (!mounted) return;
            setState(() {
              _candidates.removeWhere((c) => c.id == candidate.id);
              _expandedIndex = null;
            });
            ref.invalidate(pendingAmbassadorsCountProvider);

            if (mounted) {
              MaamoraToast.info(
                context,
                context.tr(
                  'ad_rejected',
                  args: {'name': candidate.displayName(context)},
                ),
              );
            }
          } catch (e) {
            debugPrint('[AdminPending] reject error: $e');
            if (mounted) {
              MaamoraToast.error(context, context.tr('ad_reject_failed'));
            }
          } finally {
            if (mounted) setState(() => _processing.remove(candidate.id));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: MaamoraMotion.reduced(context)
                    ? Duration.zero
                    : MaamoraDurations.normal,
                child: KeyedSubtree(
                  key: ValueKey(
                    _isLoading
                        ? 'loading'
                        : _errorMessage != null
                        ? 'error'
                        : 'data',
                  ),
                  child: _buildBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(MaamoraSpacing.lg),
        child: MaamoraSkeletonList(count: 4),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(MaamoraSpacing.screen),
          child: MaamoraErrorState(
            title: _errorMessage!,
            onRetry: _fetchPendingCandidates,
          ),
        ),
      );
    }

    if (_candidates.isEmpty) {
      // Pull-to-refresh possible même sur l'état vide (une candidature peut
      // arriver pendant que l'écran est ouvert).
      return RefreshIndicator(
        color: _primary,
        onRefresh: _fetchPendingCandidates,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(MaamoraSpacing.lg),
          children: [
            MaamoraEmptyState(
              icon: MaamoraIcons.checkFilled,
              title: context.tr('ad_apps_empty'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _fetchPendingCandidates,
      child: ListView.separated(
        // AlwaysScrollable : permet le pull-to-refresh même avec peu d'éléments.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: MaamoraSpacing.lg,
          vertical: MaamoraSpacing.md,
        ),
        itemCount: _candidates.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: MaamoraSpacing.md),
        itemBuilder: (context, index) {
          final candidate = _candidates[index];
          final isExpanded = _expandedIndex == index;
          return _CandidateCard(
            candidate: candidate,
            isExpanded: isExpanded,
            isBusy: _processing.contains(candidate.id),
            onToggle: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            onAccept: () => _confirmAccept(candidate),
            onReject: () => _showRejectDialog(candidate),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        MaamoraSpacing.lg,
        MaamoraSpacing.lg,
        MaamoraSpacing.lg,
        MaamoraSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('ad_tab_candidatures'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _onBackground,
                  ),
                ),
                Text(
                  context.tr('ad_apps_screen_title'),
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: _onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Pending count badge
          if (!_isLoading && _errorMessage == null)
            Semantics(
              label: '${_candidates.length} ${context.tr('ad_pending_count')}',
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MaamoraSpacing.md,
                  vertical: MaamoraSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(MaamoraRadius.chip),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.notifications_rounded,
                      color: MaamoraColors.onPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: MaamoraSpacing.xs + 2),
                    Text(
                      '${_candidates.length} ${context.tr('ad_pending_count')}',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: MaamoraColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Candidate Card ────────────────────────────────────────────────────────

class _CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final bool isExpanded;
  final bool isBusy;
  final VoidCallback onToggle;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _CandidateCard({
    required this.candidate,
    required this.isExpanded,
    required this.isBusy,
    required this.onToggle,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final reduced = MaamoraMotion.reduced(context);
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: MaamoraRadius.cardSmR,
        border: Border.all(
          color: isExpanded ? MaamoraColors.primaryHairline : _cardBorder,
        ),
        boxShadow: MaamoraShadows.soft,
      ),
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────────
          Semantics(
            button: true,
            expanded: isExpanded,
            child: InkWell(
              onTap: onToggle,
              borderRadius: MaamoraRadius.cardSmR,
              child: Padding(
                padding: const EdgeInsets.all(MaamoraSpacing.lg),
                child: Row(
                  children: [
                    // Avatar
                    ExcludeSemantics(
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: MaamoraColors.primarySoft,
                        child: Text(
                          candidate.initials,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: MaamoraColors.primaryText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: MaamoraSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  candidate.displayName(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _onBackground,
                                  ),
                                ),
                              ),
                              const SizedBox(width: MaamoraSpacing.sm),
                              Text(
                                candidate.createdAt,
                                textDirection: TextDirection.ltr,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const ExcludeSemantics(
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: MaamoraSpacing.xs),
                              Flexible(
                                child: Text(
                                  candidate.displayCity(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: _onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Expand chevron (rotates instead of swapping icons)
                    ExcludeSemantics(
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: reduced
                            ? Duration.zero
                            : MaamoraDurations.normal,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Expanded detail ──────────────────────────────────────────
          AnimatedSize(
            duration: reduced ? Duration.zero : MaamoraDurations.normal,
            curve: MaamoraMotion.standard,
            alignment: AlignmentDirectional.topStart,
            child: !isExpanded
                ? const SizedBox(width: double.infinity)
                : Column(
                    children: [
                      const Divider(height: 1, color: MaamoraColors.surfaceLow),
                      Padding(
                        padding: const EdgeInsets.all(MaamoraSpacing.lg),
                        child: Column(
                          children: [
                            if (candidate.phone != null) ...[
                              _DetailRow(
                                label: context.tr('ad_phone'),
                                value: candidate.phone!,
                              ),
                              const SizedBox(height: MaamoraSpacing.md),
                            ],
                            // Action buttons: reject (secondary) · accept
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isBusy ? null : onReject,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _errorColor,
                                      minimumSize: const Size.fromHeight(48),
                                      side: const BorderSide(
                                        color: MaamoraColors.dangerEdge,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: MaamoraRadius.inputR,
                                      ),
                                    ),
                                    child: Text(
                                      context.tr('ad_reject'),
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: MaamoraSpacing.md),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: isBusy ? null : onAccept,
                                    icon: isBusy
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: MaamoraColors.onPrimary,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.check_circle_rounded,
                                            size: 16,
                                          ),
                                    label: Text(
                                      context.tr('ad_accept_btn'),
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _success,
                                      foregroundColor: MaamoraColors.onPrimary,
                                      disabledBackgroundColor: _success
                                          .withValues(alpha: 0.6),
                                      disabledForegroundColor:
                                          MaamoraColors.onPrimary,
                                      minimumSize: const Size.fromHeight(48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: MaamoraRadius.inputR,
                                      ),
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
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MaamoraSpacing.md,
        vertical: MaamoraSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: MaamoraColors.surfaceLow,
        borderRadius: BorderRadius.circular(MaamoraSpacing.sm),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 13, color: _onSurfaceVariant),
          ),
          const SizedBox(width: MaamoraSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              textDirection: TextDirection.ltr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reject Dialog ─────────────────────────────────────────────────────────

class _RejectDialog extends StatefulWidget {
  final Candidate candidate;
  final void Function(String reason) onConfirm;

  const _RejectDialog({required this.candidate, required this.onConfirm});

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _reasonController = TextEditingController();

  /// Shown under the field (a SnackBar would render behind the dialog).
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(borderRadius: MaamoraRadius.cardR),
      title: Text(
        context.tr(
          'ad_refuse_btn',
          args: {'name': widget.candidate.displayName(context)},
        ),
        style: GoogleFonts.cairo(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: _onBackground,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('ad_refuse_reason'),
            style: GoogleFonts.cairo(fontSize: 13, color: _onSurfaceVariant),
          ),
          const SizedBox(height: MaamoraSpacing.md),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              hintText: context.tr('ad_refuse_hint'),
              hintStyle: GoogleFonts.cairo(
                color: _onSurfaceVariant,
                fontSize: 13,
              ),
              errorText: _error,
              filled: true,
              fillColor: MaamoraColors.creamIntense,
              border: OutlineInputBorder(
                borderRadius: MaamoraRadius.inputR,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(MaamoraSpacing.md),
            ),
            style: GoogleFonts.cairo(fontSize: 14, color: _onBackground),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            context.tr('common_cancel'),
            style: GoogleFonts.cairo(
              color: _onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = _reasonController.text.trim();
            if (reason.isEmpty) {
              setState(() => _error = context.tr('ad_refuse_required'));
              return;
            }
            widget.onConfirm(reason);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _errorColor,
            foregroundColor: MaamoraColors.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: MaamoraRadius.inputR),
          ),
          child: Text(
            context.tr('ad_refuse_confirm'),
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
