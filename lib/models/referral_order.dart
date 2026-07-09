enum OrderStatus { pending, confirmed, cancelled }

extension OrderStatusInfo on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }
}

class ReferralOrder {
  final String id;
  final String productId;
  final String productName;
  final double amount;
  final int pointsEarned;
  final DateTime date;
  final OrderStatus status;

  const ReferralOrder({
    required this.id,
    required this.productId,
    required this.productName,
    required this.amount,
    required this.pointsEarned,
    required this.date,
    required this.status,
  });
}
