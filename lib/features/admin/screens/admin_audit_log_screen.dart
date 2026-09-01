import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);

class AdminAuditLogScreen extends StatefulWidget {
  const AdminAuditLogScreen({super.key});

  @override
  State<AdminAuditLogScreen> createState() => _AdminAuditLogScreenState();
}

class _AdminAuditLogScreenState extends State<AdminAuditLogScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Map<String, String> _targetNames = {};

  Future<void> _fetchLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await Supabase.instance.client
          .from('admin_audit_log')
          .select('id, action, target_type, target_id, metadata, created_at, admins(full_name)')
          .order('created_at', ascending: false)
          .limit(50);
          
      // Fetch target names
      final ambassadorIds = <String>{};
      final groupIds = <String>{};
      for (final row in (response as List)) {
        final type = row['target_type'] as String?;
        final id = row['target_id'] as String?;
        if (id != null) {
          if (type == 'ambassador') ambassadorIds.add(id);
          if (type == 'deal_group') groupIds.add(id);
        }
      }

      final newNames = <String, String>{};
      if (ambassadorIds.isNotEmpty) {
        final ambResp = await Supabase.instance.client
            .from('ambassadors')
            .select('id, full_name')
            .inFilter('id', ambassadorIds.toList());
        for (final a in ambResp) {
          newNames[a['id']] = a['full_name'] as String? ?? 'Ambassadeur';
        }
      }
      if (groupIds.isNotEmpty) {
        final grpResp = await Supabase.instance.client
            .from('deal_groups')
            .select('id, product_name')
            .inFilter('id', groupIds.toList());
        for (final g in grpResp) {
          newNames[g['id']] = g['product_name'] as String? ?? 'Groupe';
        }
      }

      if (mounted) {
        setState(() {
          _targetNames = newNames;
          _logs = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Impossible de charger les logs : $e';
          _isLoading = false;
        });
      }
    }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: GoogleFonts.inter()),
            TextButton(onPressed: _fetchLogs, child: const Text('Réessayer'))
          ],
        ),
      );
    }
    
    if (_logs.isEmpty) {
      return const Center(child: Text('Aucune entrée dans le journal.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _logs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final entry = _logs[i];
        final targetId = entry['target_id'] as String?;
        final targetName = targetId != null ? _targetNames[targetId] : null;
        return _AuditEntryRow(entryData: entry, targetName: targetName);
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Journal d\'audit',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _onBackground,
            ),
          ),
          if (!_isLoading)
            Text(
              '${_logs.length} entrées récentes',
              style: GoogleFonts.inter(fontSize: 13, color: _onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

// ── Audit Entry Row ───────────────────────────────────────────────────────

class _AuditEntryRow extends StatelessWidget {
  final Map<String, dynamic> entryData;
  final String? targetName;
  const _AuditEntryRow({required this.entryData, this.targetName});

  void _showInfoDialog(BuildContext context, Map<String, dynamic> metadata) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Détails', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: metadata.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('${e.key}: ${e.value}', style: GoogleFonts.inter(fontSize: 14)),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse data
    final action = entryData['action'] as String? ?? 'Action Inconnue';
    final targetType = entryData['target_type'] as String? ?? '';
    final metadata = entryData['metadata'] as Map<String, dynamic>? ?? {};
    
    // Map icons and readable action names based on action code
    IconData icon = Icons.info_outline;
    String actionLabel = action;
    
    if (action == 'set_ambassador_status' || action == 'accept_ambassador') {
      if (metadata['status'] == 'active' || action == 'accept_ambassador') {
        icon = Icons.person_add_rounded;
        actionLabel = 'Ambassadeur accepté';
      } else if (metadata['status'] == 'rejected') {
        icon = Icons.person_remove_rounded;
        actionLabel = 'Ambassadeur refusé';
      } else if (metadata['status'] == 'paused') {
        icon = Icons.block_rounded;
        actionLabel = 'Ambassadeur suspendu';
      } else {
        icon = Icons.person_outline_rounded;
        actionLabel = 'Statut ambassadeur modifié';
      }
    } else if (action == 'assign_commission') {
      icon = Icons.payments_outlined;
      actionLabel = 'Commission assignée';
    } else if (action == 'create_invite_code') {
      icon = Icons.link_rounded;
      actionLabel = 'Invitation créée';
    } else if (action == 'revoke_invite_code') {
      icon = Icons.link_off_rounded;
      actionLabel = 'Invitation révoquée';
    } else if (action == 'admin_set_group_members') {
      icon = Icons.build_rounded;
      actionLabel = 'Compteur corrigé';
    } else if (action == 'create_payout') {
      icon = Icons.payments_rounded;
      actionLabel = 'Paiement effectué';
    }
    
    String target = targetType;
    if (targetType == 'ambassador' && targetName != null) {
      target = '👤 $targetName';
    } else if (targetType == 'deal_group' && targetName != null) {
      target = '📦 $targetName';
    } else if (targetType == 'invite_code') {
      target = '🔗 Invitation';
    }
    
    String detailText = '';
    
    // Formatting details according to mapping
    if (action == 'set_ambassador_status') {
      if (metadata['status'] == 'active') {
        detailText = 'Statut changé: pending → active';
      } else if (metadata['status'] == 'rejected' || metadata['status'] == 'paused') {
        detailText = 'Raison: ${metadata['reason']}';
      }
    } else if (action == 'assign_commission') {
      detailText = 'assign_commission exécuté • ${metadata['amount'] ?? metadata['montant']} DH';
    } else if (action == 'create_invite_code') {
      detailText = 'Ville: ${metadata['city']} • Expire: ${metadata['expires_at']}';
    } else if (action == 'revoke_invite_code') {
      detailText = 'Code: ${metadata['code']}';
    } else if (action == 'admin_set_group_members') {
      detailText = '${metadata['old_count']} → ${metadata['new_count']}';
    } else if (action == 'create_payout') {
      if (metadata.containsKey('method')) detailText += 'Méthode: ${metadata['method']} ';
      if (metadata.containsKey('reference') && metadata['reference'] != null) detailText += 'Réf: ${metadata['reference']} ';
      if (metadata.containsKey('amount')) detailText += 'Montant: ${metadata['amount']} DH';
    }
    
    detailText = detailText.trim();

    String formattedDate = '';
    if (entryData['created_at'] != null) {
      final date = DateTime.tryParse(entryData['created_at']);
      if (date != null) {
         formattedDate = "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E6),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: _primary, size: 18),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        actionLabel,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _onBackground,
                        ),
                      ),
                    ),
                    if (metadata.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showInfoDialog(context, metadata),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.info_outline, size: 16, color: _primary),
                        ),
                      ),
                    Text(
                      formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  target,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
                if (detailText.isNotEmpty)
                  Text(
                    detailText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _onSurfaceVariant,
                      height: 1.3,
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
