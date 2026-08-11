import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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

// ── données factices, à remplacer ─────────────────────────────────────────
class _MockInviteCode {
  final String code;
  final String status; // unused | used | expired | revoked
  final String createdAt;
  final String expiresAt;
  final String? city;

  const _MockInviteCode({
    required this.code,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.city,
  });
}

final _mockInviteCodes = <_MockInviteCode>[
  const _MockInviteCode(
    code: 'AMB-X7K2M',
    status: 'unused',
    createdAt: 'Aujourd\'hui, 10:15',
    expiresAt: '18 août 2026',
    city: 'Casablanca',
  ),
  const _MockInviteCode(
    code: 'AMB-3NP8Q',
    status: 'used',
    createdAt: 'Hier, 14:30',
    expiresAt: '17 août 2026',
    city: 'Rabat',
  ),
  const _MockInviteCode(
    code: 'AMB-LF9W1',
    status: 'expired',
    createdAt: '5 août 2026',
    expiresAt: '8 août 2026',
    city: null,
  ),
  const _MockInviteCode(
    code: 'AMB-T4ZB6',
    status: 'revoked',
    createdAt: '1 août 2026',
    expiresAt: '15 août 2026',
    city: 'Salé',
  ),
];

class AdminInviteAmbassadorScreen extends StatefulWidget {
  const AdminInviteAmbassadorScreen({super.key});

  @override
  State<AdminInviteAmbassadorScreen> createState() =>
      _AdminInviteAmbassadorScreenState();
}

class _AdminInviteAmbassadorScreenState
    extends State<AdminInviteAmbassadorScreen> {
  final _cityController = TextEditingController();
  DateTime? _selectedExpiry;
  String? _generatedCode; // null = not yet generated
  bool _isGenerating = false;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  String get _generatedLink =>
      'https://maamora.app/join/${_generatedCode ?? ''}';

  void _generate() {
    setState(() => _isGenerating = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        // données factices, à remplacer
        _generatedCode = 'AMB-${DateTime.now().millisecondsSinceEpoch % 90000 + 10000}';
      });
    });
    // TODO: brancher sur invite_codes (INSERT) + bouton Générer -> créer une ligne
    // supabase.from('invite_codes').insert({
    //   'code': generatedCode,
    //   'status': 'unused',
    //   'created_by_admin_id': adminId,
    //   'expires_at': _selectedExpiry?.toIso8601String(),
    // });
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
    // TODO: brancher sur url_launcher + WhatsApp deep link
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partage WhatsApp (à brancher)')),
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
          'Générez un lien d\'invitation unique.',
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
          // City field (optional)
          Text(
            'Ville (optionnel)',
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
          const SizedBox(height: 16),

          // Expiry date (optional)
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
          _isGenerating ? 'Génération...' : 'Générer le lien d\'invitation',
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
          Text(
            'LIEN GÉNÉRÉ',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          // Link display box
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _primary, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _generatedLink,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _onBackground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _copyLink,
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
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.copy_all_rounded,
                  label: 'Copier',
                  onTap: _copyLink,
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
        Text(
          'Invitations envoyées',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          // données factices, à remplacer
          '${_mockInviteCodes.length} invitations • données factices',
          style: GoogleFonts.inter(fontSize: 12, color: _onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        ..._mockInviteCodes.map((inv) => Padding(
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

class _InviteCodeRow extends StatelessWidget {
  final _MockInviteCode invite;
  const _InviteCodeRow({required this.invite});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    if (invite.city != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• ${invite.city}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Créé: ${invite.createdAt}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _onSurfaceVariant,
                  ),
                ),
                Text(
                  'Expire: ${invite.expiresAt}',
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
    );
  }
}
