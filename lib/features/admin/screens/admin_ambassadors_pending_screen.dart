import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/admin_status_badge.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);
const Color _success = Color(0xFF2E7D32);
const Color _successContainer = Color(0xFFDCEEE3);
const Color _errorColor = Color(0xFFB3261E);
const Color _errorContainer = Color(0xFFF9DEDC);

// ── données factices, à remplacer ─────────────────────────────────────────
class _MockCandidate {
  final String fullName;
  final String initials;
  final String city;
  final String phone;
  final String inviteCode;
  final String invitedBy;
  final bool ndaSigned;
  final String createdAt;

  const _MockCandidate({
    required this.fullName,
    required this.initials,
    required this.city,
    required this.phone,
    required this.inviteCode,
    required this.invitedBy,
    required this.ndaSigned,
    required this.createdAt,
  });
}

final _mockCandidates = <_MockCandidate>[
  const _MockCandidate(
    fullName: 'Fatima Zahra',
    initials: 'FZ',
    city: 'Salé',
    phone: '+212 6 12 34 56 78',
    inviteCode: 'SALE-7F3K',
    invitedBy: 'Youssef T.',
    ndaSigned: true,
    createdAt: 'Aujourd\'hui, 10:42',
  ),
  const _MockCandidate(
    fullName: 'Karim Alaoui',
    initials: 'KA',
    city: 'Casablanca',
    phone: '+212 6 98 76 54 32',
    inviteCode: 'CASA-2B8M',
    invitedBy: 'Admin',
    ndaSigned: false,
    createdAt: 'Hier',
  ),
  const _MockCandidate(
    fullName: 'Sara Benali',
    initials: 'SB',
    city: 'Rabat',
    phone: '+212 6 55 44 33 22',
    inviteCode: 'RABA-9C1X',
    invitedBy: 'Amine B.',
    ndaSigned: true,
    createdAt: 'Oct 24',
  ),
];

class AdminAmbassadorsPendingScreen extends StatefulWidget {
  const AdminAmbassadorsPendingScreen({super.key});

  @override
  State<AdminAmbassadorsPendingScreen> createState() =>
      _AdminAmbassadorsPendingScreenState();
}

class _AdminAmbassadorsPendingScreenState
    extends State<AdminAmbassadorsPendingScreen> {
  int? _expandedIndex;

  void _accept(_MockCandidate candidate) {
    // TODO: brancher sur admin_set_ambassador_status(p_ambassador_id, 'active', null)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${candidate.fullName} accepté(e) — (mock)'),
        backgroundColor: _success,
      ),
    );
  }

  void _showRejectDialog(_MockCandidate candidate) {
    showDialog(
      context: context,
      builder: (ctx) => _RejectDialog(
        candidate: candidate,
        onConfirm: (reason) {
          Navigator.of(ctx).pop();
          // TODO: brancher sur admin_set_ambassador_status(p_ambassador_id, 'rejected', reason)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${candidate.fullName} refusé(e) — (mock)'),
              backgroundColor: _errorColor,
            ),
          );
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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: _mockCandidates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final candidate = _mockCandidates[index];
                  final isExpanded = _expandedIndex == index;
                  return _CandidateCard(
                    candidate: candidate,
                    isExpanded: isExpanded,
                    onToggle: () {
                      setState(() {
                        _expandedIndex = isExpanded ? null : index;
                      });
                    },
                    onAccept: () => _accept(candidate),
                    onReject: () => _showRejectDialog(candidate),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Candidatures',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _onBackground,
                  ),
                ),
                Text(
                  'Examiner les demandes d\'ambassadeurs',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Pending count badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  '${_mockCandidates.length}\npending',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.notifications_rounded,
                    color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Candidate Card ────────────────────────────────────────────────────────

class _CandidateCard extends StatelessWidget {
  final _MockCandidate candidate;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _CandidateCard({
    required this.candidate,
    required this.isExpanded,
    required this.onToggle,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────────
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFE8DDD3),
                    child: Text(
                      candidate.initials,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              candidate.fullName,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _onBackground,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              candidate.createdAt,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: _onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 12, color: _onSurfaceVariant),
                            const SizedBox(width: 2),
                            Text(
                              candidate.city,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Expand chevron
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded detail ──────────────────────────────────────────
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFEDE8E4)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _DetailRow(
                      label: 'Phone', value: candidate.phone),
                  _DetailRow(
                      label: 'Invite Code',
                      value: candidate.inviteCode,
                      valueColor: _primary),
                  _DetailRow(
                      label: 'Invited By', value: candidate.invitedBy),
                  _DetailRow(
                    label: 'NDA Signed',
                    value: candidate.ndaSigned ? 'Verified' : 'Not signed',
                    valueColor:
                        candidate.ndaSigned ? _success : _errorColor,
                    valueIcon: candidate.ndaSigned
                        ? Icons.verified_rounded
                        : Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 14),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _onBackground,
                            side:
                                const BorderSide(color: _cardBorder, width: 1.5),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Reject',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: _onBackground,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onAccept,
                          icon: const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 16),
                          label: Text(
                            'Accept',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _success,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? valueIcon;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF5F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (valueIcon != null)
              Icon(valueIcon, size: 14, color: valueColor ?? _onBackground),
            if (valueIcon != null) const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor ?? _onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reject Dialog ─────────────────────────────────────────────────────────

class _RejectDialog extends StatefulWidget {
  final _MockCandidate candidate;
  final void Function(String reason) onConfirm;

  const _RejectDialog({
    required this.candidate,
    required this.onConfirm,
  });

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Refuser ${widget.candidate.fullName}',
        style: GoogleFonts.plusJakartaSans(
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
            'Raison du refus (optionnel)',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ex: Profil incomplet, zone non couverte...',
              hintStyle:
                  GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF5EDE4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: GoogleFonts.inter(fontSize: 14, color: _onBackground),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Annuler',
            style: GoogleFonts.inter(
              color: _onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => widget.onConfirm(_reasonController.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: _errorColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Confirmer le refus',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
