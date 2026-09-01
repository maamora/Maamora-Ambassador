import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/admin_status_badge.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/navigation/app_routes.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);
const Color _errorColor = Color(0xFFB3261E);

// ── Modèle ───────────────────────────────────────────────────────────────
class AmbassadorData {
  final String id;
  final String fullName;
  final String initials;
  final String city;
  final String status; 
  final String level;
  final int totalValidatedMembers;
  final String createdAt;

  AmbassadorData({
    required this.id,
    required this.fullName,
    required this.initials,
    required this.city,
    required this.status,
    required this.level,
    required this.totalValidatedMembers,
    required this.createdAt,
  });

  factory AmbassadorData.fromMap(Map<String, dynamic> map) {
    final fullName = map['full_name'] ?? 'Inconnu';
    final parts = fullName.split(' ');
    String initials = '';
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials += parts[0][0].toUpperCase();
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      initials += parts[1][0].toUpperCase();
    }

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
          formattedDate = DateFormat('MMM yyyy').format(date);
        }
      }
    }

    // Capitalize level if it comes lowercased from DB
    String rawLevel = map['level'] ?? 'bronze';
    String capitalizedLevel = rawLevel.isNotEmpty ? '${rawLevel[0].toUpperCase()}${rawLevel.substring(1)}' : 'Bronze';

    return AmbassadorData(
      id: map['id']?.toString() ?? '',
      fullName: fullName,
      initials: initials,
      city: map['city'] ?? 'Inconnue',
      status: map['status'] ?? 'pending',
      level: capitalizedLevel,
      totalValidatedMembers: map['total_validated_members'] ?? 0,
      createdAt: formattedDate,
    );
  }
}

class AdminAmbassadorsListScreen extends StatefulWidget {
  const AdminAmbassadorsListScreen({super.key});

  @override
  State<AdminAmbassadorsListScreen> createState() =>
      _AdminAmbassadorsListScreenState();
}

class _AdminAmbassadorsListScreenState
    extends State<AdminAmbassadorsListScreen> {
  // Filter state — UI only, logic to be implemented later if needed
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

  List<AmbassadorData> _ambassadors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAmbassadors();
  }

  Future<void> _fetchAmbassadors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client
          .from('ambassadors')
          .select('id, full_name, city, created_at, status, level, total_validated_members')
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      setState(() {
        _ambassadors = data.map((e) => AmbassadorData.fromMap(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des ambassadeurs : $e');
      setState(() {
        _errorMessage = 'Impossible de charger la liste. Veuillez vérifier votre connexion ou vos droits d\'accès.';
        _isLoading = false;
      });
    }
  }

  // Very basic local filtering for demo purposes based on selected dropdowns
  List<AmbassadorData> get _displayed {
    return _ambassadors.where((a) {
      if (_filterStatus != 'Tous' && a.status.toLowerCase() != _filterStatus.toLowerCase()) return false;
      if (_filterLevel != 'Tous' && a.level.toLowerCase() != _filterLevel.toLowerCase()) return false;
      if (_filterCity != 'Toutes' && a.city.toLowerCase() != _filterCity.toLowerCase()) return false;
      return true;
    }).toList();
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
            const SizedBox(height: 12),
            _buildFilters(),
            const SizedBox(height: 8),
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
                onPressed: _fetchAmbassadors,
                style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
                child: const Text('Réessayer'),
              )
            ],
          ),
        ),
      );
    }
    
    final displayedList = _displayed;
    
    if (displayedList.isEmpty) {
      return Center(
        child: Text(
          'Aucun ambassadeur trouvé.',
          style: GoogleFonts.inter(color: _onSurfaceVariant, fontSize: 14),
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8),
      itemCount: displayedList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) =>
          _AmbassadorRow(ambassador: displayedList[i]),
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
          if (!_isLoading && _errorMessage == null)
            Text(
              '${_displayed.length} ambassadeur(s)',
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
  final AmbassadorData ambassador;
  const _AmbassadorRow({required this.ambassador});

  Color _levelColor(String level) {
    switch (level.toLowerCase()) {
      case 'gold':
        return const Color(0xFFD4AF37);
      case 'silver':
        return const Color(0xFFB0B0B8);
      case 'platinum':
        return const Color(0xFF7DE3E8);
      default:
        return const Color(0xFFCD7F32); // Bronze
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('${AppRoutes.adminAmbassadorDetails}/${ambassador.id}');
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
      ),
    );
  }
}
