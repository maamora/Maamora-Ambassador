class ReferralLink {
  final String id;
  final String ambassadorId;
  final String productId;
  final String code;
  final int clickCount;

  const ReferralLink({
    required this.id,
    required this.ambassadorId,
    required this.productId,
    required this.code,
    this.clickCount = 0,
  });

  factory ReferralLink.fromJson(Map<String, dynamic> json) {
    return ReferralLink(
      id: json['id'] as String,
      ambassadorId: json['ambassador_id'] as String,
      productId: json['product_id'] as String,
      code: json['code'] as String,
      clickCount: (json['click_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ambassador_id': ambassadorId,
      'product_id': productId,
      'code': code,
      'click_count': clickCount,
    };
  }
}
