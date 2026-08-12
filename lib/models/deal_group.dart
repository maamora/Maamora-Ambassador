enum DealGroupStatus { open, waitingAdminValidation, closed, cancelled }

extension DealGroupStatusExtension on DealGroupStatus {
  static DealGroupStatus fromString(String status) {
    switch (status) {
      case 'open':
        return DealGroupStatus.open;
      case 'waiting_admin_validation':
        return DealGroupStatus.waitingAdminValidation;
      case 'closed':
        return DealGroupStatus.closed;
      case 'cancelled':
        return DealGroupStatus.cancelled;
      default:
        return DealGroupStatus.open;
    }
  }

  String get value {
    switch (this) {
      case DealGroupStatus.open:
        return 'open';
      case DealGroupStatus.waitingAdminValidation:
        return 'waiting_admin_validation';
      case DealGroupStatus.closed:
        return 'closed';
      case DealGroupStatus.cancelled:
        return 'cancelled';
    }
  }
}

class DealGroup {
  final String id;
  final String ambassadorId;
  final String productName;
  final String? productDescription;
  final String? productImageUrl;
  final double pricePerPerson;
  final int seatsTotal;
  final int membersCount;
  final DealGroupStatus status;
  final String shareSlug;
  final int tapsCount;
  final bool commissionAssigned;
  final DateTime? commissionAssignedAt;
  final String? commissionAssignedByAdminId;
  final DateTime? createdAt;

  const DealGroup({
    required this.id,
    required this.ambassadorId,
    required this.productName,
    this.productDescription,
    this.productImageUrl,
    required this.pricePerPerson,
    required this.seatsTotal,
    this.membersCount = 0,
    this.status = DealGroupStatus.open,
    required this.shareSlug,
    this.tapsCount = 0,
    this.commissionAssigned = false,
    this.commissionAssignedAt,
    this.commissionAssignedByAdminId,
    this.createdAt,
  });

  bool get isComplete => membersCount >= seatsTotal;
  int get seatsRemaining => seatsTotal > membersCount ? seatsTotal - membersCount : 0;
  double get progressRatio => seatsTotal > 0 ? (membersCount / seatsTotal).clamp(0.0, 1.0) : 0.0;
  double get estimatedTotalValue => pricePerPerson * membersCount;

  factory DealGroup.fromJson(Map<String, dynamic> json) {
    return DealGroup(
      id: json['id'] as String,
      ambassadorId: json['ambassador_id'] as String,
      productName: json['product_name'] as String? ?? 'Produit',
      productDescription: json['product_description'] as String?,
      productImageUrl: json['product_image_url'] as String?,
      pricePerPerson: (json['price_per_person'] as num?)?.toDouble() ?? 0.0,
      seatsTotal: (json['seats_total'] as num?)?.toInt() ?? 0,
      membersCount: (json['members_count'] as num?)?.toInt() ?? 0,
      status: DealGroupStatusExtension.fromString(json['status'] as String? ?? 'open'),
      shareSlug: json['share_slug'] as String? ?? '',
      tapsCount: (json['taps_count'] as num?)?.toInt() ?? 0,
      commissionAssigned: json['commission_assigned'] as bool? ?? false,
      commissionAssignedAt: json['commission_assigned_at'] != null ? DateTime.tryParse(json['commission_assigned_at'] as String) : null,
      commissionAssignedByAdminId: json['commission_assigned_by_admin_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ambassador_id': ambassadorId,
      'product_name': productName,
      'product_description': productDescription,
      'product_image_url': productImageUrl,
      'price_per_person': pricePerPerson,
      'seats_total': seatsTotal,
      'members_count': membersCount,
      'status': status.value,
      'share_slug': shareSlug,
      'taps_count': tapsCount,
      'commission_assigned': commissionAssigned,
      'commission_assigned_at': commissionAssignedAt?.toIso8601String(),
      'commission_assigned_by_admin_id': commissionAssignedByAdminId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
