class OrderDetail {
  final int productId;
  final String productName;
  final double unitPrice;
  int quantity;
  
  // ✅ 1. CAMBIO: Agregamos este campo para validar en el carrito
  final int maxStock; 

  double get subtotal => unitPrice * quantity;

  OrderDetail({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.maxStock = 9999, // ✅ 2. Valor por defecto alto (para no bloquear si no tenemos el dato)
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      productId: json['productId'],
      productName: json['productName'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      quantity: json['quantity'],
      // En historial de órdenes no suele venir el stock, así que usamos el default
      maxStock: 9999, 
    );
  }

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "unitPrice": unitPrice,
    "quantity": quantity,
    // ⚠️ NO enviamos maxStock al backend, solo se usa en la app
  };
}