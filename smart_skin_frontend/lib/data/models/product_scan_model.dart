class ProductScanRequestModel {
  final String productName;
  final String? brand;
  final String? barcode;
  final String ingredients;

  ProductScanRequestModel({
    required this.productName,
    this.brand,
    this.barcode,
    required this.ingredients,
  });

  Map<String, dynamic> toJson() => {
    "productName": productName,
    "brand": brand,
    "barcode": barcode,
    "ingredients": ingredients,
  };
}

class ProductScanModel {
  final int? id;
  final String? productName;
  final String? brand;
  final String? ingredients;
  final int? compatibilityScore;
  final String? safetyRating;
  final String? summary;
  final List<String> beneficialIngredients;
  final List<String> harmfulIngredients;
  final String? scannedAt;
  ProductScanModel({
    this.id, this.productName, this.brand, this.ingredients,
    this.compatibilityScore, this.safetyRating, this.summary,
    this.beneficialIngredients = const [], this.harmfulIngredients = const [], this.scannedAt,
  });
  factory ProductScanModel.fromJson(Map<String, dynamic> json) => ProductScanModel(
    id: json['id'], productName: json['productName'], brand: json['brand'],
    ingredients: json['ingredients'], compatibilityScore: json['compatibilityScore'],
    safetyRating: json['safetyRating'], summary: json['summary'],
    beneficialIngredients: List<String>.from(json['beneficialIngredients'] ?? []),
    harmfulIngredients: List<String>.from(json['harmfulIngredients'] ?? []),
    scannedAt: json['scannedAt'],
  );
}
