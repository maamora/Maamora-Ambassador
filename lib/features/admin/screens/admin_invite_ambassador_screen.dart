import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/admin_status_badge.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);
const Color _orangeLight = Color(0xFFFFF0E6);
const Color _whatsappGreen = Color(0xFF25D366);

// ── Modèle de données ──────────────────────────────────────────────────────
class _InviteCode {
  final String code;
  final String status; // unused | used | expired | revoked
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? usedAt;

  const _InviteCode({
    required this.code,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.usedAt,
  });

  factory _InviteCode.fromMap(Map<String, dynamic> map) {
    return _InviteCode(
      code: map['code'] as String,
      status: map['status'] as String? ?? 'unused',
      createdAt: DateTime.parse(map['created_at'] as String),
      expiresAt: map['expires_at'] != null
          ? DateTime.tryParse(map['expires_at'] as String)
          : null,
      usedAt: map['used_at'] != null
          ? DateTime.tryParse(map['used_at'] as String)
          : null,
    );
  }
}

class AdminInviteAmbassadorScreen extends StatefulWidget {
  const AdminInviteAmbassadorScreen({super.key});

  @override
  State<AdminInviteAmbassadorScreen> createState() =>
      _AdminInviteAmbassadorScreenState();
}

class _AdminInviteAmbassadorScreenState
    extends State<AdminInviteAmbassadorScreen> {
  final _cityController = TextEditingController(); // visuel uniquement, non envoyé en DB
  DateTime? _selectedExpiry;
  String? _generatedCode;
  bool _isGenerating = false;

  List<_InviteCode> _invites = [];
  bool _isLoadingInvites = true;
  String? _invitesError;

  @override
  void initState() {
    super.initState();
    _fetchInvites();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  String get _generatedLink =>
      'https://maamora.app/join/${_generatedCode ?? ''}';

  // ── Récupération de la liste des invitations ────────────────────────────
  Future<void> _fetchInvites() async {
    setState(() {
      _isLoadingInvites = true;
      _invitesError = null;
    });
    try {
      final adminId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('invite_codes')
          .select('code, status, created_at, expires_at, used_at')
          .eq('created_by_admin_id', adminId)
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((e) => _InviteCode.fromMap(e as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _invites = list;
          _isLoadingInvites = false;
        });
      }
    } catch (e) {
      debugPrint('[AdminInvite] fetchInvites error: $e');
      if (mounted) {
        setState(() {
          _invitesError = 'Erreur lors du chargement des invitations : $e';
          _isLoadingInvites = false;
        });
      }
    }
  }

  // ── Génération d'un nouveau code ────────────────────────────────────────
  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _generatedCode = null;
    });

    try {
      final adminId = Supabase.instance.client.auth.currentUser!.id;

      final response = await Supabase.instance.client
          .from('invite_codes')
          .insert({
            'created_by_admin_id': adminId,
            if (_selectedExpiry != null)
              'expires_at': _selectedExpiry!.toIso8601String(),
          })
          .select('code, status, expires_at, created_at')
          .single();

      if (mounted) {
        setState(() {
          _generatedCode = response['code'] as String;
          _isGenerating = false;
        });
        // Rafraîchir la liste
        _fetchInvites();
      }
    } catch (e) {
      debugPrint('[AdminInvite] generate error: $e');
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedExpiry = picked);
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _generatedCode ?? ''));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copié dans le presse-papiers'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _generatedLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lien copié dans le presse-papiers'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareWhatsApp() {
    // Partage du CODE via un message texte
    // TODO: brancher url_launcher avec le lien WhatsApp
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code à partager : ${_generatedCode ?? ''}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildForm(),
              const SizedBox(height: 16),
              _buildGenerateButton(),
              if (_generatedCode != null) ...[
                const SizedBox(height: 20),
                _buildGeneratedLinkSection(),
              ],
              const SizedBox(height: 24),
              _buildPastInvitesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inviter un ambassadeur',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Générez un code d\'invitation unique.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
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
          // Ville (optionnel, visuel uniquement — non envoyé en DB)
          Text(
            'Ville (optionnel, pour votre référence)',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _onBackground,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cityController,
            decoration: InputDecoration(
              hintText: 'Ex: Casablanca',
              hintStyle: GoogleFonts.inter(color: _onSurfaceVariant),
              filled: true,
              fillColor: const Color(0xFFF5EDE4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            style: GoogleFonts.inter(fontSize: 14, color: _onBackground),
          ),
          const SizedBox(height: 4),
          Text(
            'Note : Ce champ est local uniquement — le code généré n\'est pas lié à une ville en base.',
            style: GoogleFonts.inter(fontSize: 11, color: _onSurfaceVariant),
          ),
          const SizedBox(height: 16),

          // Date d'expiration (optionnel)
          Text(
            'Date d\'expiration (optionnel)',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _onBackground,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EDE4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedExpiry != null
                          ? '${_selectedExpiry!.day}/${_selectedExpiry!.month}/${_selectedExpiry!.year}'
                          : 'Choisir une date',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _selectedExpiry != null
                            ? _onBackground
                            : _onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today_rounded,
                      size: 18, color: _onSurfaceVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generate,
        icon: _isGenerating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.link_rounded, color: Colors.white, size: 20),
        label: Text(
          _isGenerating ? 'Génération...' : 'Générer le code d\'invitation',
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

  Widget _buildGeneratedLinkSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _orangeLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD4A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: _primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'CODE GÉNÉRÉ',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Code seul (à communiquer à l'ambassadeur)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _primary, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _generatedCode ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _primary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _copyCode,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _orangeLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.copy_rounded,
                        color: _primary, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Lien complet (pour partage)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _generatedLink,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _copyLink,
                  child: const Icon(Icons.copy_rounded,
                      color: _onSurfaceVariant, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Bouton partager WhatsApp
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.copy_all_rounded,
                  label: 'Copier le code',
                  onTap: _copyCode,
                  outlined: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.send_rounded,
                  label: 'Partager',
                  onTap: _shareWhatsApp,
                  color: _whatsappGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastInvitesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Invitations envoyées',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _onBackground,
                ),
              ),
            ),
            if (!_isLoadingInvites)
              GestureDetector(
                onTap: _fetchInvites,
                child: const Icon(Icons.refresh_rounded,
                    size: 20, color: _onSurfaceVariant),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (!_isLoadingInvites && _invitesError == null)
          Text(
            '${_invites.length} invitation${_invites.length > 1 ? 's' : ''}',
            style: GoogleFonts.inter(fontSize: 12, color: _onSurfaceVariant),
          ),
        const SizedBox(height: 12),
        if (_isLoadingInvites)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ))
        else if (_invitesError != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _invitesError!,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          )
        else if (_invites.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.mail_outline_rounded,
                      size: 40, color: _onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(
                    'Aucune invitation envoyée',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: _onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else
          ..._invites.map((inv) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _InviteCodeRow(invite: inv),
              )),
      ],
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.outlined = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? _primary;
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: resolvedColor,
          side: BorderSide(color: resolvedColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: resolvedColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Aujourd\'hui, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  if (diff.inDays == 1) return 'Hier, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  return '${dt.day}/${dt.month}/${dt.year}';
}

class _InviteCodeRow extends StatelessWidget {
  final _InviteCode invite;
  const _InviteCodeRow({required this.invite});

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: invite.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              '${invite.code} copié !',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: _primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _copyCode(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            // Code
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        invite.code,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy_rounded, size: 14, color: _onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Créé: ${_formatDate(invite.createdAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _onSurfaceVariant,
                    ),
                  ),
                  if (invite.expiresAt != null)
                    Text(
                      'Expire: ${invite.expiresAt!.day}/${invite.expiresAt!.month}/${invite.expiresAt!.year}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _onSurfaceVariant,
                      ),
                    )
                  else
                    Text(
                      'Pas d\'expiration',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AdminStatusBadge(status: invite.status),
          ],
        ),
      ),
    );
  }
}
