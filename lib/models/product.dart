// lib/models/product.dart
class Product {
  final int id;
  final int productCode;
  final String productName;
  final String details;
  final double price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.details,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Debug: Print what we're receiving
    print('📦 Parsing JSON: $json');

    // Safely parse ID with default value
    final id = _parseInt(json['id']) ?? 0;

    // Safely parse product_code (handle both 'product_code' and 'productCode')
    final productCode =
        _parseInt(json['product_code']) ?? _parseInt(json['productCode']) ?? 0;

    // Safely parse product_name
    final productName =
        json['product_name']?.toString() ??
        json['productName']?.toString() ??
        json['name']?.toString() ??
        '';

    // Safely parse details
    final details =
        json['details']?.toString() ?? json['description']?.toString() ?? '';

    // Safely parse price (handle int, double, or string)
    final price = _parseDouble(json['price']) ?? 0.0;

    // Safely parse dates
    final createdAt = _parseDateTime(json['created_at'] ?? json['createdAt']);
    final updatedAt = _parseDateTime(json['updated_at'] ?? json['updatedAt']);

    print(
      '✅ Parsed: id=$id, code=$productCode, name=$productName, price=$price',
    );

    return Product(
      id: id,
      productCode: productCode,
      productName: productName,
      details: details,
      price: price,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      'product_code': productCode,
      'product_name': productName,
      'details': details,
      'price': price,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedProductCode => productCode.toString().padLeft(6, '0');
}
