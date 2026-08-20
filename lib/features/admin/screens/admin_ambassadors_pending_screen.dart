import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);
const Color _success = Color(0xFF2E7D32);
const Color _errorColor = Color(0xFFB3261E);

// ── Modèle ───────────────────────────────────────────────────────────────
class Candidate {
  final String id;
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
    final fullName = map['full_name'] ?? 'Inconnu';
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
          formattedDate = 'Aujourd\'hui, ${DateFormat('HH:mm').format(date)}';
        } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != date.day)) {
          formattedDate = 'Hier';
        } else {
          formattedDate = DateFormat('MMM d').format(date);
        }
      }
    }

    return Candidate(
      id: map['id']?.toString() ?? '',
      fullName: fullName,
      initials: initials,
      city: map['city'] ?? 'Inconnue',
      createdAt: formattedDate,
      phone: map['phone'],
    );
  }
}

class AdminAmbassadorsPendingScreen extends StatefulWidget {
  const AdminAmbassadorsPendingScreen({super.key});

  @override
  State<AdminAmbassadorsPendingScreen> createState() =>
      _AdminAmbassadorsPendingScreenState();
}

class _AdminAmbassadorsPendingScreenState
    extends State<AdminAmbassadorsPendingScreen> {
  int? _expandedIndex;
  
  List<Candidate> _candidates = [];
  bool _isLoading = true;
  String? _errorMessage;

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
      setState(() {
        _candidates = data.map((e) => Candidate.fromMap(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des candidatures : $e');
      setState(() {
        _errorMessage = 'Impossible de charger les candidatures. Veuillez vérifier votre connexion ou vos droits d\'accès.';
        _isLoading = false;
      });
    }
  }

  Future<void> _accept(Candidate candidate) async {
    try {
      await Supabase.instance.client.rpc('admin_set_ambassador_status', params: {
        'p_ambassador_id': candidate.id,
        'p_status': 'active',
        'p_reason': null,
      });

      setState(() {
        _candidates.removeWhere((c) => c.id == candidate.id);
        _expandedIndex = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${candidate.fullName} accepté(e)'),
            backgroundColor: _success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur acceptation : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de l\'acceptation.'),
            backgroundColor: _errorColor,
          ),
        );
      }
    }
  }

  void _showRejectDialog(Candidate candidate) {
    showDialog(
      context: context,
      builder: (ctx) => _RejectDialog(
        candidate: candidate,
        onConfirm: (reason) async {
          Navigator.of(ctx).pop();
          
          try {
            await Supabase.instance.client.rpc('admin_set_ambassador_status', params: {
              'p_ambassador_id': candidate.id,
              'p_status': 'rejected',
              'p_reason': reason.isNotEmpty ? reason : 'Candidature refusée',
            });

            setState(() {
              _candidates.removeWhere((c) => c.id == candidate.id);
              _expandedIndex = null;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${candidate.fullName} refusé(e)'),
                  backgroundColor: _errorColor,
                ),
              );
            }
          } catch (e) {
             debugPrint('Erreur rejet : $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Erreur lors du refus.'),
                  backgroundColor: _errorColor,
                ),
              );
            }
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
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: _errorColor, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: _onBackground, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchPendingCandidates,
                style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
                child: const Text('Réessayer'),
              )
            ],
          ),
        ),
      );
    }
    
    if (_candidates.isEmpty) {
      return Center(
        child: Text(
          'Aucune candidature en attente.',
          style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 14),
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _candidates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final candidate = _candidates[index];
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
          if (!_isLoading && _errorMessage == null)
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
                    '${_candidates.length}\npending',
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
            ),        ],
      ),
    );
  }
}

// ── Candidate Card ────────────────────────────────────────────────────────

class _CandidateCard extends StatelessWidget {
  final Candidate candidate;
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
                  if (candidate.phone != null)
                    _DetailRow(label: 'Phone', value: candidate.phone!),
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
  final Candidate candidate;
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
            'Raison du refus (obligatoire)',
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
          onPressed: () {
            final reason = _reasonController.text.trim();
            if (reason.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Veuillez saisir un motif de refus.'),
                  backgroundColor: _errorColor,
                )
              );
              return;
            }
            widget.onConfirm(reason);
          },
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
