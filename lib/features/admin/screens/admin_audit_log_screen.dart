import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);

// ── données factices, à remplacer ─────────────────────────────────────────
class _MockAuditEntry {
  final String adminName;
  final String action;
  final String target;
  final String detail;
  final String date;
  final IconData icon;

  const _MockAuditEntry({
    required this.adminName,
    required this.action,
    required this.target,
    required this.detail,
    required this.date,
    required this.icon,
  });
}

final _mockAuditLog = <_MockAuditEntry>[
  const _MockAuditEntry(
    adminName: 'Admin',
    action: 'Ambassadeur accepté',
    target: 'Youssef Tahiri',
    detail: 'Statut changé: pending → active',
    date: 'Aujourd\'hui, 11:30',
    icon: Icons.person_add_rounded,
  ),
  const _MockAuditEntry(
    adminName: 'Admin',
    action: 'Commission assignée',
    target: 'Groupe #42 — Dates Box',
    detail: 'assign_commission exécuté • 562.50 DH',
    date: 'Aujourd\'hui, 10:15',
    icon: Icons.payments_outlined,
  ),
  const _MockAuditEntry(
    adminName: 'Admin',
    action: 'Invitation créée',
    target: 'Code AMB-X7K2M',
    detail: 'Ville: Casablanca • Expire: 18 août 2026',
    date: 'Aujourd\'hui, 09:45',
    icon: Icons.link_rounded,
  ),
  const _MockAuditEntry(
    adminName: 'Admin',
    action: 'Ambassadeur refusé',
    target: 'Nadia Chraibi',
    detail: 'Raison: Zone non couverte',
    date: 'Hier, 15:20',
    icon: Icons.person_remove_rounded,
  ),
  const _MockAuditEntry(
    adminName: 'Admin',
    action: 'Commission assignée',
    target: 'Groupe #38 — Tea Set',
    detail: 'assign_commission exécuté • 900.00 DH',
    date: 'Hier, 12:00',
    icon: Icons.payments_outlined,
  ),
  const _MockAuditEntry(
    adminName: 'Admin',
    action: 'Invitation révoquée',
    target: 'Code AMB-T4ZB6',
    detail: 'Statut: unused → revoked',
    date: 'Oct 30',
    icon: Icons.link_off_rounded,
  ),
  const _MockAuditEntry(
    adminName: 'Admin',
    action: 'Ambassadeur suspendu',
    target: 'Hassan Moussaoui',
    detail: 'Raison: Fraude suspectée',
    date: 'Oct 28',
    icon: Icons.block_rounded,
  ),
];

class AdminAuditLogScreen extends StatelessWidget {
  const AdminAuditLogScreen({super.key});

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
                itemCount: _mockAuditLog.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) =>
                    _AuditEntryRow(entry: _mockAuditLog[i]),
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
          Text(
            // données factices, à remplacer — brancher sur admin_audit_log
            '${_mockAuditLog.length} entrées • données factices',
            style: GoogleFonts.inter(fontSize: 13, color: _onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Audit Entry Row ───────────────────────────────────────────────────────

class _AuditEntryRow extends StatelessWidget {
  final _MockAuditEntry entry;
  const _AuditEntryRow({required this.entry});

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
            child: Icon(entry.icon, color: _primary, size: 18),
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
                        entry.action,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _onBackground,
                        ),
                      ),
                    ),
                    Text(
                      entry.date,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  entry.target,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
                Text(
                  entry.detail,
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
