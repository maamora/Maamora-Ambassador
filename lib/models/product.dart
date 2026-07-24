class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String type; // 'single' or 'grouped'
  final int pointsValue;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.type = 'single',
    int? pointsValue,
    int? pointsPerSale,
  }) : pointsValue = pointsValue ?? pointsPerSale ?? 0;

  int get pointsPerSale => pointsValue;

  bool get isGrouped => type == 'grouped';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String? ?? '',
      type: json['type'] as String? ?? 'single',
      pointsValue: (json['points_value'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'type': type,
      'points_value': pointsValue,
    };
  }
}
