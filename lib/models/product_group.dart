class ProductGroup {
  final String id;
  final String productId;
  final String ambassadorId;
  final int seuilMin;
  final int compteurActuel;
  final String statut; // 'active', 'unlocked', 'completed', 'expired'
  final double? prixGroupe;

  const ProductGroup({
    required this.id,
    required this.productId,
    required this.ambassadorId,
    required this.seuilMin,
    required this.compteurActuel,
    required this.statut,
    this.prixGroupe,
  });

  bool get isUnlocked => statut == 'débloqué' || compteurActuel >= seuilMin;
  bool get isActive => statut == 'en_attente' && !isUnlocked;
  double get progressRatio => seuilMin > 0 ? (compteurActuel / seuilMin).clamp(0.0, 1.0) : 0.0;

  factory ProductGroup.fromJson(Map<String, dynamic> json) {
    return ProductGroup(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      ambassadorId: json['ambassador_id'] as String,
      seuilMin: (json['seuil_min'] as num?)?.toInt() ?? 5,
      compteurActuel: (json['compteur_actuel'] as num?)?.toInt() ?? 0,
      statut: json['statut'] as String? ?? 'active',
      prixGroupe: json['prix_groupe'] != null ? (json['prix_groupe'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'ambassador_id': ambassadorId,
      'seuil_min': seuilMin,
      'compteur_actuel': compteurActuel,
      'statut': statut,
      'prix_groupe': prixGroupe,
    };
  }

  ProductGroup copyWith({
    String? id,
    String? productId,
    String? ambassadorId,
    int? seuilMin,
    int? compteurActuel,
    String? statut,
    double? prixGroupe,
  }) {
    return ProductGroup(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      ambassadorId: ambassadorId ?? this.ambassadorId,
      seuilMin: seuilMin ?? this.seuilMin,
      compteurActuel: compteurActuel ?? this.compteurActuel,
      statut: statut ?? this.statut,
      prixGroupe: prixGroupe ?? this.prixGroupe,
    );
  }
}
