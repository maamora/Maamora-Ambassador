enum PayoutMethod { bank, cashPickup }

extension PayoutMethodExtension on PayoutMethod {
  static PayoutMethod fromString(String method) {
    switch (method) {
      case 'bank':
        return PayoutMethod.bank;
      case 'cash_pickup':
        return PayoutMethod.cashPickup;
      default:
        return PayoutMethod.bank;
    }
  }

  String get value {
    switch (this) {
      case PayoutMethod.bank:
        return 'bank';
      case PayoutMethod.cashPickup:
        return 'cash_pickup';
    }
  }
}

enum PayoutStatus { pending, paid }

extension PayoutStatusExtension on PayoutStatus {
  static PayoutStatus fromString(String status) {
    switch (status) {
      case 'pending':
        return PayoutStatus.pending;
      case 'paid':
        return PayoutStatus.paid;
      default:
        return PayoutStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case PayoutStatus.pending:
        return 'pending';
      case PayoutStatus.paid:
        return 'paid';
    }
  }
}

class Payout {
  final String id;
  final String ambassadorId;
  final DateTime? weekEndingOn;
  final double amount;
  final PayoutMethod method;
  final PayoutStatus status;
  final DateTime? createdAt;

  const Payout({
    required this.id,
    required this.ambassadorId,
    this.weekEndingOn,
    required this.amount,
    required this.method,
    required this.status,
    this.createdAt,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'] as String,
      ambassadorId: json['ambassador_id'] as String,
      weekEndingOn: json['week_ending_on'] != null ? DateTime.tryParse(json['week_ending_on'] as String) : null,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: PayoutMethodExtension.fromString(json['method'] as String? ?? 'bank'),
      status: PayoutStatusExtension.fromString(json['status'] as String? ?? 'pending'),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ambassador_id': ambassadorId,
      'week_ending_on': weekEndingOn?.toIso8601String(),
      'amount': amount,
      'method': method.value,
      'status': status.value,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
