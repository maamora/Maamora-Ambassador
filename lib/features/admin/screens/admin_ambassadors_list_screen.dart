import 'package:flutter/material.dart';
import '../../../shared/widgets/design_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/admin_status_badge.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = MaamoraColors.primary;
const Color _background = Colors.white;
const Color _surface = Colors.white;
const Color _onBackground = MaamoraColors.textPrimary;
const Color _onSurfaceVariant = MaamoraColors.textSecondary;
const Color _cardBorder = MaamoraColors.border;
const Color _errorColor = MaamoraColors.danger;

// ── Modèle ───────────────────────────────────────────────────────────────
class AmbassadorData {
  final String id;
  final String fullName;
  final String initials;
  final String city;
  final String status;
  /// Niveau brut tel qu'en base (bronze/silver/gold…) — utilisé pour filtrer
  /// sans dépendre de la langue d'affichage.
  final String rawLevel;
  final String level;
  final int totalValidatedMembers;
  final String createdAt;

  AmbassadorData({
    required this.id,
    required this.fullName,
    required this.initials,
    required this.city,
    required this.status,
    required this.rawLevel,
    required this.level,
    required this.totalValidatedMembers,
    required this.createdAt,
  });

  /// Libellé traduit d'un niveau brut (bronze → dash_tier_bronze…).
  static String levelLabel(BuildContext context, String rawLevel) {
    const tierKeys = {
      'neutral': 'dash_tier_neutral',
      'bronze': 'dash_tier_bronze',
      'silver': 'dash_tier_silver',
      'gold': 'dash_tier_gold',
    };
    final key = tierKeys[rawLevel.toLowerCase()];
    if (key != null) return context.tr(key);
    if (rawLevel.isNotEmpty) {
      return '${rawLevel[0].toUpperCase()}${rawLevel.substring(1)}';
    }
    return 'Bronze';
  }

  factory AmbassadorData.fromMap(Map<String, dynamic> map, {BuildContext? context}) {
    final fullName = map['full_name'] ??
        (context != null ? context.tr('ad_unknown_name') : 'Inconnu');
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
          formattedDate = (context != null)
              ? context.tr('common_today_time', args: {'time': DateFormat('HH:mm').format(date)})
              : DateFormat('dd/MM HH:mm').format(date);
        } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != date.day)) {
          formattedDate = (context != null) ? context.tr('common_yesterday') : 'Hier';
        } else {
          formattedDate = '${date.month.toString().padLeft(2, '0')}'            '/${date.year}';
        }
      }
    }

    final String rawLevel = (map['level'] ?? 'bronze').toString();

    return AmbassadorData(
      id: map['id']?.toString() ?? '',
      fullName: fullName,
      initials: initials,
      city: map['city'] ??
          (context != null ? context.tr('ad_unknown_city') : 'Inconnue'),
      status: map['status'] ?? 'pending',
      rawLevel: rawLevel,
      level: (context != null)
          ? levelLabel(context, rawLevel)
          : rawLevel,
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
  // Filter state — valeurs BRUTES (langue-indépendantes), libellés traduits.
  String _filterStatus = 'all';
  String _filterLevel = 'all';
  String _filterCity = 'all';

  /// Valeurs possibles construites à partir des données réelles.
  static const _statusValues = ['all', 'active', 'pending', 'rejected', 'suspended'];
  List<String> _levelValues = ['all'];
  List<String> _cityValues = ['all'];

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
        _ambassadors = data.map((e) => AmbassadorData.fromMap(e, context: context)).toList();
        // Options dynamiques : uniquement les niveaux/villes réellement
        // présents, pour éviter des filtres qui ne renvoient jamais rien.
        _levelValues = ['all', ..._ambassadors
            .map((a) => a.rawLevel.toLowerCase())
            .where((l) => l.isNotEmpty)
            .toSet()
            .toList()
          ..sort()];
        _cityValues = ['all', ..._ambassadors
            .map((a) => a.city)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort()];
        // Si la sélection courante a disparu des données, on la réinitialise.
        if (!_levelValues.contains(_filterLevel)) _filterLevel = 'all';
        if (!_cityValues.contains(_filterCity)) _filterCity = 'all';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des ambassadeurs : $e');
      setState(() {
        _errorMessage = context.tr('ad_list_err');
        _isLoading = false;
      });
    }
  }

  // Filtrage local sur les valeurs brutes (statut/niveau/ville).
  List<AmbassadorData> get _displayed {
    return _ambassadors.where((a) {
      if (_filterStatus != 'all' && a.status.toLowerCase() != _filterStatus) return false;
      if (_filterLevel != 'all' && a.rawLevel.toLowerCase() != _filterLevel) return false;
      if (_filterCity != 'all' && a.city.toLowerCase() != _filterCity.toLowerCase()) return false;
      return true;
    }).toList();
  }

  // ── Libellés traduits ────────────────────────────────────────────────────
  String _statusLabel(BuildContext context, String raw) {
    switch (raw) {
      case 'all':
        return context.tr('ad_filter_all');
      case 'active':
        return context.tr('ad_badge_active');
      case 'pending':
        return context.tr('ad_pending');
      case 'rejected':
        return context.tr('ad_badge_rejected');
      case 'suspended':
        return context.tr('ad_badge_suspended');
      default:
        return raw;
    }
  }

  String _levelDisplayLabel(BuildContext context, String raw) {
    if (raw == 'all') return context.tr('ad_filter_all');
    return AmbassadorData.levelLabel(context, raw);
  }

  String _cityLabel(BuildContext context, String raw) {
    if (raw == 'all') return context.tr('ad_filter_all_f');
    return raw;
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
      return const AppLoader();
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
                style: GoogleFonts.cairo(color: _onBackground, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchAmbassadors,
                style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
                child: Text(
                  context.tr('common_retry'),
                  style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w700),
                )
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
          context.tr('ad_list_empty'),
          style: GoogleFonts.cairo(color: _onSurfaceVariant, fontSize: 14),
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
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('ad_list_all'),
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _onBackground,
            ),
          ),
          if (!_isLoading && _errorMessage == null)
            Text(
              context.tr('ad_list_count', args: {'n': '${_displayed.length}'}),
              style: GoogleFonts.cairo(fontSize: 13, color: _onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _FilterDropdown(
            label: context.tr('ad_filter_status'),
            value: _filterStatus,
            items: [
              for (final v in _statusValues)
                (value: v, label: _statusLabel(context, v)),
            ],
            onChanged: (v) => setState(() => _filterStatus = v),
          ),
          _FilterDropdown(
            label: context.tr('ad_filter_level'),
            value: _filterLevel,
            items: [
              for (final v in _levelValues)
                (value: v, label: _levelDisplayLabel(context, v)),
            ],
            onChanged: (v) => setState(() => _filterLevel = v),
          ),
          _FilterDropdown(
            label: context.tr('ad_filter_city'),
            value: _filterCity,
            items: [
              for (final v in _cityValues)
                (value: v, label: _cityLabel(context, v)),
            ],
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
  /// Paires (valeur brute, libellé traduit).
  final List<({String value, String label})> items;
  final void Function(String) onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value != items.first.value;
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: isActive ? _primary : _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? _primary : _cardBorder,
        ),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 6, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isActive ? Colors.white : _onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isActive ? Colors.white : _onSurfaceVariant,
              ),
              dropdownColor: _surface,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : _onBackground,
              ),
              items: items
                  .map((it) => DropdownMenuItem(
                        value: it.value,
                        child: Text(
                          it.label,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _onBackground,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
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
        return MaamoraColors.tierGold;
      case 'silver':
        return MaamoraColors.tierSilver;
      case 'platinum':
        return MaamoraColors.tierPlatinum;
      default:
        return MaamoraColors.tierBronze; // Bronze
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
              backgroundColor: MaamoraColors.border,
              child: Text(
                ambassador.initials,
                style: GoogleFonts.cairo(
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
                      Flexible(
                        child: Text(
                          ambassador.fullName,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _onBackground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                          style: GoogleFonts.cairo(
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
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: _onSurfaceVariant),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          ambassador.city,
                          style: GoogleFonts.cairo(
                              fontSize: 12, color: _onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.people_alt_outlined,
                          size: 11, color: _onSurfaceVariant),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '${ambassador.totalValidatedMembers} ${context.tr('lb_members')}',
                          style: GoogleFonts.cairo(
                              fontSize: 12, color: _onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
