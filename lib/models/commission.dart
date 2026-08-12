enum CommissionSource { groupCommission, recruitBonus, adjustment }

extension CommissionSourceExtension on CommissionSource {
  static CommissionSource fromString(String source) {
    switch (source) {
      case 'group_commission':
        return CommissionSource.groupCommission;
      case 'recruit_bonus':
        return CommissionSource.recruitBonus;
      case 'adjustment':
        return CommissionSource.adjustment;
      default:
        return CommissionSource.groupCommission;
    }
  }

  String get value {
    switch (this) {
      case CommissionSource.groupCommission:
        return 'group_commission';
      case CommissionSource.recruitBonus:
        return 'recruit_bonus';
      case CommissionSource.adjustment:
        return 'adjustment';
    }
  }
}

enum CommissionStatus { pending, payable, paid, voided }

extension CommissionStatusExtension on CommissionStatus {
  static CommissionStatus fromString(String status) {
    switch (status) {
      case 'pending':
        return CommissionStatus.pending;
      case 'payable':
        return CommissionStatus.payable;
      case 'paid':
        return CommissionStatus.paid;
      case 'voided':
        return CommissionStatus.voided;
      default:
        return CommissionStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case CommissionStatus.pending:
        return 'pending';
      case CommissionStatus.payable:
        return 'payable';
      case CommissionStatus.paid:
        return 'paid';
      case CommissionStatus.voided:
        return 'voided';
    }
  }
}

class Commission {
  final String id;
  final String ambassadorId;
  final CommissionSource source;
  final String? dealGroupId;
  final String? sourceAmbassadorId;
  final double rateApplied;
  final double amount;
  final CommissionStatus status;
  final String? payoutId;
  final DateTime? createdAt;
  
  // These are often joined from related tables for display purposes
  final String? dealGroupName;

  const Commission({
    required this.id,
    required this.ambassadorId,
    required this.source,
    this.dealGroupId,
    this.sourceAmbassadorId,
    required this.rateApplied,
    required this.amount,
    required this.status,
    this.payoutId,
    this.createdAt,
    this.dealGroupName,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    // Check if deal_groups was joined in the query
    String? joinedDealGroupName;
    if (json['deal_groups'] != null && json['deal_groups'] is Map) {
      joinedDealGroupName = json['deal_groups']['product_name'] as String?;
    }

    return Commission(
      id: json['id'] as String,
      ambassadorId: json['ambassador_id'] as String,
      source: CommissionSourceExtension.fromString(json['source'] as String? ?? 'group_commission'),
      dealGroupId: json['deal_group_id'] as String?,
      sourceAmbassadorId: json['source_ambassador_id'] as String?,
      rateApplied: (json['rate_applied'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: CommissionStatusExtension.fromString(json['status'] as String? ?? 'pending'),
      payoutId: json['payout_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      dealGroupName: joinedDealGroupName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ambassador_id': ambassadorId,
      'source': source.value,
      'deal_group_id': dealGroupId,
      'source_ambassador_id': sourceAmbassadorId,
      'rate_applied': rateApplied,
      'amount': amount,
      'status': status.value,
      'payout_id': payoutId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
