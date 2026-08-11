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

// ── données factices, à remplacer ─────────────────────────────────────────
class _MockAmbassador {
  final String fullName;
  final String initials;
  final String city;
  final String phone;
  final String status; // active | pending | rejected | suspended
  final String level; // Bronze | Silver | Gold | Platinum
  final int totalValidatedMembers;
  final String createdAt;

  const _MockAmbassador({
    required this.fullName,
    required this.initials,
    required this.city,
    required this.phone,
    required this.status,
    required this.level,
    required this.totalValidatedMembers,
    required this.createdAt,
  });
}

final _mockAmbassadors = <_MockAmbassador>[
  const _MockAmbassador(
    fullName: 'Youssef Tahiri',
    initials: 'YT',
    city: 'Casablanca',
    phone: '+212 6 11 22 33 44',
    status: 'active',
    level: 'Gold',
    totalValidatedMembers: 87,
    createdAt: 'Mar 2026',
  ),
  const _MockAmbassador(
    fullName: 'Amine Benhammou',
    initials: 'AB',
    city: 'Marrakech',
    phone: '+212 6 55 66 77 88',
    status: 'active',
    level: 'Silver',
    totalValidatedMembers: 45,
    createdAt: 'Avr 2026',
  ),
  const _MockAmbassador(
    fullName: 'Fatima Zahra',
    initials: 'FZ',
    city: 'Salé',
    phone: '+212 6 12 34 56 78',
    status: 'pending',
    level: 'Bronze',
    totalValidatedMembers: 0,
    createdAt: 'Aujourd\'hui',
  ),
  const _MockAmbassador(
    fullName: 'Karim Alaoui',
    initials: 'KA',
    city: 'Casablanca',
    phone: '+212 6 98 76 54 32',
    status: 'pending',
    level: 'Bronze',
    totalValidatedMembers: 0,
    createdAt: 'Hier',
  ),
  const _MockAmbassador(
    fullName: 'Nadia Chraibi',
    initials: 'NC',
    city: 'Fès',
    phone: '+212 6 33 22 11 00',
    status: 'rejected',
    level: 'Bronze',
    totalValidatedMembers: 0,
    createdAt: 'Oct 2025',
  ),
  const _MockAmbassador(
    fullName: 'Hassan Moussaoui',
    initials: 'HM',
    city: 'Tanger',
    phone: '+212 6 77 88 99 00',
    status: 'suspended',
    level: 'Bronze',
    totalValidatedMembers: 12,
    createdAt: 'Jan 2026',
  ),
];

class AdminAmbassadorsListScreen extends StatefulWidget {
  const AdminAmbassadorsListScreen({super.key});

  @override
  State<AdminAmbassadorsListScreen> createState() =>
      _AdminAmbassadorsListScreenState();
}

class _AdminAmbassadorsListScreenState
    extends State<AdminAmbassadorsListScreen> {
  // Filter state — UI only, no real filtering logic yet
  String _filterStatus = 'Tous';
  String _filterLevel = 'Tous';
  String _filterCity = 'Toutes';

  final _statusOptions = ['Tous', 'Active', 'Pending', 'Rejected', 'Suspended'];
  final _levelOptions = ['Tous', 'Bronze', 'Silver', 'Gold', 'Platinum'];
  final _cityOptions = [
    'Toutes',
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Salé',
    'Fès',
    'Tanger',
  ];

  // données factices, à remplacer — no real filter applied
  List<_MockAmbassador> get _displayed => _mockAmbassadors;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildFilters(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: _displayed.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    _AmbassadorRow(ambassador: _displayed[i]),
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
            'Tous les ambassadeurs',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _onBackground,
            ),
          ),
          Text(
            // données factices, à remplacer
            '${_mockAmbassadors.length} ambassadeurs • données factices',
            style: GoogleFonts.inter(fontSize: 13, color: _onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterDropdown(
            label: 'Statut',
            value: _filterStatus,
            options: _statusOptions,
            onChanged: (v) => setState(() => _filterStatus = v),
          ),
          const SizedBox(width: 8),
          _FilterDropdown(
            label: 'Niveau',
            value: _filterLevel,
            options: _levelOptions,
            onChanged: (v) => setState(() => _filterLevel = v),
          ),
          const SizedBox(width: 8),
          _FilterDropdown(
            label: 'Ville',
            value: _filterCity,
            options: _cityOptions,
            onChanged: (v) => setState(() => _filterCity = v),
          ),
        ],
      ),
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final void Function(String) onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value != options.first;
    return Container(
      decoration: BoxDecoration(
        color: isActive ? _primary : _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? _primary : _cardBorder,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: isActive ? Colors.white : _onSurfaceVariant,
          ),
          dropdownColor: _surface,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : _onBackground,
          ),
          items: options
              .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(o),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _AmbassadorRow extends StatelessWidget {
  final _MockAmbassador ambassador;
  const _AmbassadorRow({required this.ambassador});

  Color _levelColor(String level) {
    switch (level) {
      case 'Gold':
        return const Color(0xFFD4AF37);
      case 'Silver':
        return const Color(0xFFB0B0B8);
      case 'Platinum':
        return const Color(0xFF7DE3E8);
      default:
        return const Color(0xFFCD7F32); // Bronze
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8DDD3),
            child: Text(
              ambassador.initials,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ambassador.fullName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _onBackground,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _levelColor(ambassador.level)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ambassador.level,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _levelColor(ambassador.level),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 11, color: _onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text(
                      ambassador.city,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: _onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.people_alt_outlined,
                        size: 11, color: _onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text(
                      '${ambassador.totalValidatedMembers} membres',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: _onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AdminStatusBadge(status: ambassador.status),
        ],
      ),
    );
  }
}
