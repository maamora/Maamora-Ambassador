enum AmbassadorStatus { pending, active, rejected, paused }

extension AmbassadorStatusExtension on AmbassadorStatus {
  static AmbassadorStatus fromString(String status) {
    switch (status) {
      case 'pending':
        return AmbassadorStatus.pending;
      case 'active':
        return AmbassadorStatus.active;
      case 'rejected':
        return AmbassadorStatus.rejected;
      case 'paused':
        return AmbassadorStatus.paused;
      default:
        return AmbassadorStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case AmbassadorStatus.pending:
        return 'pending';
      case AmbassadorStatus.active:
        return 'active';
      case AmbassadorStatus.rejected:
        return 'rejected';
      case AmbassadorStatus.paused:
        return 'paused';
    }
  }
}

enum AmbassadorLevel { neutral, bronze, silver, gold }

extension AmbassadorLevelExtension on AmbassadorLevel {
  static AmbassadorLevel fromString(String level) {
    switch (level) {
      case 'neutral':
        return AmbassadorLevel.neutral;
      case 'bronze':
        return AmbassadorLevel.bronze;
      case 'silver':
        return AmbassadorLevel.silver;
      case 'gold':
        return AmbassadorLevel.gold;
      default:
        return AmbassadorLevel.neutral;
    }
  }

  String get value {
    switch (this) {
      case AmbassadorLevel.neutral:
        return 'neutral';
      case AmbassadorLevel.bronze:
        return 'bronze';
      case AmbassadorLevel.silver:
        return 'silver';
      case AmbassadorLevel.gold:
        return 'gold';
    }
  }

  String get label {
    switch (this) {
      case AmbassadorLevel.neutral:
        return 'Neutral';
      case AmbassadorLevel.bronze:
        return 'Bronze';
      case AmbassadorLevel.silver:
        return 'Silver';
      case AmbassadorLevel.gold:
        return 'Gold';
    }
  }

  double get commissionRate {
    switch (this) {
      case AmbassadorLevel.neutral:
        return 0.03; // 3%
      case AmbassadorLevel.bronze:
        return 0.06; // 6%
      case AmbassadorLevel.silver:
        return 0.09; // 9%
      case AmbassadorLevel.gold:
        return 0.10; // 10%
    }
  }
}

class Ambassador {
  final String id;
  final String? inviteCodeId;
  final String? invitedByAmbassadorId;
  final String fullName;
  final String phone;
  final String city;
  final AmbassadorStatus status;
  final String? rejectionReason;
  final DateTime? activatedAt;
  final DateTime? pausedAt;
  final String? pausedReason;
  final AmbassadorLevel level;
  final int totalValidatedMembers;
  final String referralSlug;
  final String? payoutMethod;
  final String? payoutBankRib;
  final String? payoutCashPoint;

  const Ambassador({
    required this.id,
    this.inviteCodeId,
    this.invitedByAmbassadorId,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.status,
    this.rejectionReason,
    this.activatedAt,
    this.pausedAt,
    this.pausedReason,
    required this.level,
    required this.totalValidatedMembers,
    required this.referralSlug,
    this.payoutMethod,
    this.payoutBankRib,
    this.payoutCashPoint,
  });

  factory Ambassador.fromJson(Map<String, dynamic> json) {
    return Ambassador(
      id: json['id'] as String,
      inviteCodeId: json['invite_code_id'] as String?,
      invitedByAmbassadorId: json['invited_by_ambassador_id'] as String?,
      fullName: json['full_name'] as String? ?? 'Ambassador',
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      status: AmbassadorStatusExtension.fromString(json['status'] as String? ?? 'pending'),
      rejectionReason: json['rejection_reason'] as String?,
      activatedAt: json['activated_at'] != null ? DateTime.tryParse(json['activated_at'] as String) : null,
      pausedAt: json['paused_at'] != null ? DateTime.tryParse(json['paused_at'] as String) : null,
      pausedReason: json['paused_reason'] as String?,
      level: AmbassadorLevelExtension.fromString(json['level'] as String? ?? 'neutral'),
      totalValidatedMembers: (json['total_validated_members'] as num?)?.toInt() ?? 0,
      referralSlug: json['referral_slug'] as String? ?? '',
      payoutMethod: json['payout_method'] as String?,
      payoutBankRib: json['payout_bank_rib'] as String?,
      payoutCashPoint: json['payout_cash_point'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invite_code_id': inviteCodeId,
      'invited_by_ambassador_id': invitedByAmbassadorId,
      'full_name': fullName,
      'phone': phone,
      'city': city,
      'status': status.value,
      'rejection_reason': rejectionReason,
      'activated_at': activatedAt?.toIso8601String(),
      'paused_at': pausedAt?.toIso8601String(),
      'paused_reason': pausedReason,
      'level': level.value,
      'total_validated_members': totalValidatedMembers,
      'referral_slug': referralSlug,
      'payout_method': payoutMethod,
      'payout_bank_rib': payoutBankRib,
      'payout_cash_point': payoutCashPoint,
    };
  }

  Ambassador copyWith({
    String? id,
    String? inviteCodeId,
    String? invitedByAmbassadorId,
    String? fullName,
    String? phone,
    String? city,
    AmbassadorStatus? status,
    String? rejectionReason,
    DateTime? activatedAt,
    DateTime? pausedAt,
    String? pausedReason,
    AmbassadorLevel? level,
    int? totalValidatedMembers,
    String? referralSlug,
    String? payoutMethod,
    String? payoutBankRib,
    String? payoutCashPoint,
  }) {
    return Ambassador(
      id: id ?? this.id,
      inviteCodeId: inviteCodeId ?? this.inviteCodeId,
      invitedByAmbassadorId: invitedByAmbassadorId ?? this.invitedByAmbassadorId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      activatedAt: activatedAt ?? this.activatedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      pausedReason: pausedReason ?? this.pausedReason,
      level: level ?? this.level,
      totalValidatedMembers: totalValidatedMembers ?? this.totalValidatedMembers,
      referralSlug: referralSlug ?? this.referralSlug,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      payoutBankRib: payoutBankRib ?? this.payoutBankRib,
      payoutCashPoint: payoutCashPoint ?? this.payoutCashPoint,
    );
  }
}
