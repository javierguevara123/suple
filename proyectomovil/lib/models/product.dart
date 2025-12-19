class Product {
  final int id;
  final String name;
  final double unitPrice;
  final int unitsInStock;
  final String? profilePictureBase64; // ✅ Nuevo campo para la imagen

  Product({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.unitsInStock,
    this.profilePictureBase64,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      unitsInStock: json['unitsInStock'] ?? 0,
      // Mapeamos cualquiera de las dos llaves posibles que mande tu backend
      profilePictureBase64: json['profilePictureBase64'] ?? json['profilePicture'], 
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "unitPrice": unitPrice,
    "unitsInStock": unitsInStock,
    "profilePictureBase64": profilePictureBase64,
  };
}