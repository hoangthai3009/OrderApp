class OrderItem {
  final String id;
  final List<Map<String, dynamic>> items;
  final int tableNumber;
  final String status;

  OrderItem({
    required this.id,
    required this.items,
    required this.tableNumber,
    required this.status,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'],
      items: List<Map<String, dynamic>>.from(json['items']),
      tableNumber: json['tableNumber'],
      status: json['status'],
    );
  }
}
