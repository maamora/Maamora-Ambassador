import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../widgets/admin_status_badge.dart';
import '../../../models/models.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);
const Color _errorColor = Color(0xFFB3261E);
const Color _successColor = Color(0xFF2E7D32);

class AdminAmbassadorDetailsScreen extends StatefulWidget {
  final String ambassadorId;
  const AdminAmbassadorDetailsScreen({super.key, required this.ambassadorId});

  @override
  State<AdminAmbassadorDetailsScreen> createState() => _AdminAmbassadorDetailsScreenState();
}

class _AdminAmbassadorDetailsScreenState extends State<AdminAmbassadorDetailsScreen> {
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
        _errorMessage = 'Impossible de charger les détails.';
        _isLoading = false;
      });
    }
  }

  Future<void> _changeStatus(String newStatus, {String? reason}) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: _primary)),
      );
      
      await Supabase.instance.client.rpc('admin_set_ambassador_status', params: {
        'p_ambassador_id': widget.ambassadorId,
        'p_status': newStatus,
        'p_reason': reason,
      });
      
      if (mounted) {
        Navigator.pop(context);
        _fetchDetails();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError('Erreur de changement de statut: $e');
    }
  }

  Future<void> _handleAccept() async {
    await _changeStatus('active');
  }

  Future<void> _handleReject() async {
    final reason = await _promptReason('Raison du refus');
    if (reason != null && reason.isNotEmpty) {
      await _changeStatus('rejected', reason: reason);
    }
  }

  Future<void> _handleSuspend() async {
    final reason = await _promptReason('Raison de la suspension');
    if (reason != null && reason.isNotEmpty) {
      await _changeStatus('paused', reason: reason);
    }
  }

  Future<void> _handleReactivate() async {
    await _changeStatus('active');
  }

  Future<String?> _promptReason(String title) async {
    final tc = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          controller: tc,
          decoration: InputDecoration(
            hintText: 'Saisissez la raison...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text('Annuler', style: GoogleFonts.inter(color: _onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, tc.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: _errorColor, foregroundColor: Colors.white),
            child: const Text('Confirmer'),
          )
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
              title: Text('Régler le wallet', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Montant à régler : ${_walletBalance.toStringAsFixed(2)} DH', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Text('Méthode', style: GoogleFonts.inter(fontSize: 12, color: _onSurfaceVariant)),
                  DropdownButton<String>(
                    value: method,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'bank', child: Text('Virement bancaire')),
                      DropdownMenuItem(value: 'cash_pickup', child: Text('Espèces (Cash)')),
                    ],
                    onChanged: (v) {
                      if (v != null) setStateModal(() => method = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Référence (N° virement, capture WhatsApp, etc.)', style: GoogleFonts.inter(fontSize: 12, color: _onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tcRef,
                    decoration: InputDecoration(
                      hintText: 'Ex: VIR-12345',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Annuler', style: GoogleFonts.inter(color: _onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: _successColor, foregroundColor: Colors.white),
                  child: const Text('Valider le paiement'),
                )
              ],
            );
          }
        );
      }
    );

    if (result == true) {
      if (!mounted) return;
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator(color: _primary)),
        );
        
        await Supabase.instance.client.rpc('admin_create_payout', params: {
          'p_ambassador_id': widget.ambassadorId,
          'p_method': method,
          'p_reference': tcRef.text.trim(),
        });
        
        if (mounted) {
          Navigator.pop(context); // close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paiement enregistré avec succès')),
          );
          _fetchDetails(); // refresh balance
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        _showError('Erreur lors du paiement: $e');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(color: Colors.white)), backgroundColor: _errorColor));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: _onBackground),
        title: Text(
          'Fiche Ambassadeur',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _onBackground,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _primary));
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: _errorColor, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: GoogleFonts.inter()),
            TextButton(onPressed: _fetchDetails, child: const Text('Réessayer'))
          ],
        ),
      );
    }

    if (_ambassador == null) return const Center(child: Text('Ambassadeur introuvable.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          if (_ambassador!.status != AmbassadorStatus.rejected) _buildActionsCard(),
          const SizedBox(height: 16),
          _buildCommissionsSection(),
          const SizedBox(height: 16),
          _buildGroupsSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final a = _ambassador!;
    
    final parts = a.fullName.split(' ');
    String initials = '';
    if (parts.isNotEmpty && parts[0].isNotEmpty) initials += parts[0][0].toUpperCase();
    if (parts.length > 1 && parts[1].isNotEmpty) initials += parts[1][0].toUpperCase();

    String joinedDate = 'N/A';
    if (a.activatedAt != null) {
      joinedDate = DateFormat('dd/MM/yyyy').format(a.activatedAt!);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
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
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: _onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.fullName, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: _onBackground)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        AdminStatusBadge(status: a.status.value),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _levelColor(a.level).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            a.level.label,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: _levelColor(a.level)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.phone_rounded, 'Téléphone', a.phone),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_rounded, 'Ville', a.city),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today_rounded, 'Date d\'activation', joinedDate),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.people_alt_rounded, 'Membres validés', '${a.totalValidatedMembers}'),
          if (_parentAmbassadorName != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person_add_rounded, 'Invité par', _parentAmbassadorName!),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: _onSurfaceVariant)),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _onBackground)),
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
          Text('Actions Administratives', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (a.status == AmbassadorStatus.pending) ...[
                _ActionBtn(label: 'Accepter', icon: Icons.check, color: _successColor, onTap: _handleAccept),
                _ActionBtn(label: 'Refuser', icon: Icons.close, color: _errorColor, onTap: _handleReject),
              ],
              if (a.status == AmbassadorStatus.active)
                _ActionBtn(label: 'Suspendre', icon: Icons.pause, color: _primary, onTap: _handleSuspend),
              if (a.status == AmbassadorStatus.paused)
                _ActionBtn(label: 'Réactiver', icon: Icons.play_arrow, color: _successColor, onTap: _handleReactivate),
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
                    Text('Solde disponible', style: GoogleFonts.inter(fontSize: 12, color: _onSurfaceVariant)),
                    Text('${_walletBalance.toStringAsFixed(2)} DH', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: _successColor)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _handlePayout,
                  icon: const Icon(Icons.account_balance_wallet, size: 18),
                  label: const Text('Régler le wallet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            )
          ] else if (a.status != AmbassadorStatus.pending) ...[
             const Divider(height: 32),
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solde disponible', style: GoogleFonts.inter(fontSize: 12, color: _onSurfaceVariant)),
                      Text('0.00 DH', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: _onBackground)),
                    ],
                  ),
                ],
              )
          ]
        ],
      ),
    );
  }

  Widget _buildCommissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Historique des commissions', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_commissions.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Aucune commission.', style: GoogleFonts.inter(color: _onSurfaceVariant)))),
        ..._commissions.map((c) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _cardBorder)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _background, shape: BoxShape.circle),
                  child: Icon(
                    c.source == CommissionSource.recruitBonus ? Icons.person_add : Icons.shopping_bag,
                    size: 16,
                    color: _primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.dealGroupName ?? (c.source == CommissionSource.recruitBonus ? 'Bonus Parrainage' : 'Commission'), style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(c.createdAt != null ? DateFormat('dd/MM/yy HH:mm').format(c.createdAt!) : '', style: GoogleFonts.inter(fontSize: 11, color: _onSurfaceVariant)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('+${c.amount.toStringAsFixed(2)} DH', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: _successColor)),
                    const SizedBox(height: 2),
                    _buildCommissionBadge(c.status),
                  ],
                ),
              ],
            ),
          );
        })
      ],
    );
  }

  Widget _buildCommissionBadge(CommissionStatus status) {
    Color color;
    String label;
    switch (status) {
      case CommissionStatus.pending:
        color = Colors.orange;
        label = 'En attente';
        break;
      case CommissionStatus.payable:
        color = _primary;
        label = 'Payable';
        break;
      case CommissionStatus.paid:
        color = _successColor;
        label = 'Payé';
        break;
      case CommissionStatus.voided:
        color = _errorColor;
        label = 'Annulé';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Groupes créés', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_dealGroups.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Aucun groupe créé.', style: GoogleFonts.inter(color: _onSurfaceVariant)))),
        ..._dealGroups.map((g) {
          final title = g['product_name'] ?? 'Groupe inconnu';
          final members = g['members_count'] ?? 0;
          final maxMembers = g['seats_total'] ?? 0;
          final status = g['status'] ?? 'pending';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _cardBorder)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('$members / $maxMembers membres', style: GoogleFonts.inter(fontSize: 11, color: _onSurfaceVariant)),
                    ],
                  ),
                ),
                Text(status.toString().toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: _primary)),
              ],
            ),
          );
        })
      ],
    );
  }

  Color _levelColor(AmbassadorLevel level) {
    switch (level) {
      case AmbassadorLevel.gold:
        return const Color(0xFFD4AF37);
      case AmbassadorLevel.silver:
        return const Color(0xFFB0B0B8);
      case AmbassadorLevel.neutral:
        return _onSurfaceVariant;
      case AmbassadorLevel.bronze:
        return const Color(0xFFCD7F32);
    }
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
