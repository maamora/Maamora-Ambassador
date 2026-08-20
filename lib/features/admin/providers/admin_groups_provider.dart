import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/deal_group.dart';

// ── Admin Groups Provider ────────────────────────────────────────────────────
// Fetches ALL deal_groups (admin sees everything) joined with ambassador name.
// Groups are considered "complete" when members_count >= seats_total.

class AdminGroupsState {
  final List<AdminGroupItem> groups;
  final bool isLoading;
  final String? error;

  const AdminGroupsState({
    this.groups = const [],
    this.isLoading = false,
    this.error,
  });

  AdminGroupsState copyWith({
    List<AdminGroupItem>? groups,
    bool? isLoading,
    String? error,
  }) =>
      AdminGroupsState(
        groups: groups ?? this.groups,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  int get pendingCommissionCount =>
      groups.where((g) => g.isComplete && !g.commissionAssigned).length;
}

class AdminGroupItem {
  final String id;
  final String productName;
  final double pricePerPerson;
  final int membersCount;
  final int seatsTotal;
  final String ambassadorName;
  final String completedAt;
  final bool commissionAssigned;
  final DealGroupStatus status;

  const AdminGroupItem({
    required this.id,
    required this.productName,
    required this.pricePerPerson,
    required this.membersCount,
    required this.seatsTotal,
    required this.ambassadorName,
    required this.completedAt,
    required this.commissionAssigned,
    required this.status,
  });

  bool get isComplete => membersCount >= seatsTotal;

  factory AdminGroupItem.fromMap(Map<String, dynamic> map) {
    // Ambassador name comes from the join with ambassadors table
    final ambassadorMap = map['ambassadors'] as Map<String, dynamic>?;
    final ambassadorFullName =
        ambassadorMap?['full_name'] as String? ?? 'Inconnu';
    // Shorten to "Prénom N." style
    final parts = ambassadorFullName.trim().split(' ');
    final shortName = parts.length > 1
        ? '${parts[0]} ${parts[1][0].toUpperCase()}.'
        : parts[0];

    // Relative date from created_at
    String formattedDate = '';
    final createdAtStr = map['created_at'] as String?;
    if (createdAtStr != null) {
      final date = DateTime.tryParse(createdAtStr)?.toLocal();
      if (date != null) {
        final now = DateTime.now();
        final diff = now.difference(date);
        if (diff.inDays == 0 && now.day == date.day) {
          final h = date.hour.toString().padLeft(2, '0');
          final m = date.minute.toString().padLeft(2, '0');
          formattedDate = "Aujourd'hui, $h:$m";
        } else if (diff.inDays <= 1) {
          formattedDate = 'Hier';
        } else {
          const months = [
            '_', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
            'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
          ];
          formattedDate = '${months[date.month]} ${date.day}';
        }
      }
    }

    final status = DealGroupStatusExtension.fromString(
        map['status'] as String? ?? 'open');

    return AdminGroupItem(
      id: map['id'] as String? ?? '',
      productName: map['product_name'] as String? ?? 'Produit',
      pricePerPerson: (map['price_per_person'] as num?)?.toDouble() ?? 0.0,
      membersCount: (map['members_count'] as num?)?.toInt() ?? 0,
      seatsTotal: (map['seats_total'] as num?)?.toInt() ?? 0,
      ambassadorName: shortName,
      completedAt: formattedDate,
      commissionAssigned: map['commission_assigned'] as bool? ?? false,
      status: status,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class AdminGroupsNotifier extends StateNotifier<AdminGroupsState> {
  AdminGroupsNotifier() : super(const AdminGroupsState(isLoading: true)) {
    fetchGroups();
  }

  final _client = Supabase.instance.client;

  Future<void> fetchGroups() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client
          .from('deal_groups')
          .select('*, ambassadors(full_name)')
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((e) => AdminGroupItem.fromMap(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        groups: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de charger les groupes: $e',
      );
    }
  }

  Future<void> assignCommission(String groupId) async {
    try {
      await _client.rpc('assign_commission', params: {'p_group_id': groupId});
      await fetchGroups(); // refresh after action
    } catch (e) {
      state = state.copyWith(
          error: "Erreur lors de l'assignation de la commission.");
    }
  }
}

final adminGroupsProvider =
    StateNotifierProvider<AdminGroupsNotifier, AdminGroupsState>(
  (ref) => AdminGroupsNotifier(),
);
