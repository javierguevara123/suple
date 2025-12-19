import 'orderdetail.dart';

class Order {
  final int orderId;
  final String customerName;
  final String customerId;
  final DateTime orderDate;
  final double totalAmount;
  final List<OrderDetail> details;
  final String shipAddress; 
  final String shipCity;
  

  Order({
    required this.orderId,
    required this.customerName,
    required this.customerId,
    required this.orderDate,
    required this.totalAmount,
    required this.details,
    this.shipAddress = '',
    this.shipCity = '',
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['orderDetails'] as List? ?? [];
    return Order(
      orderId: json['orderId'] ?? 0,
      customerName: json['customerName'] ?? 'Cliente',
      customerId: json['customerId'] ?? '',
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : DateTime.now(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      details: list.map((i) => OrderDetail.fromJson(i)).toList(),
      shipAddress: json['shipAddress'] ?? '',
      shipCity: json['shipCity'] ?? '',
    );
  }
}