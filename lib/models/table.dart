class MyTable {
  final String id;
  final int tableNumber;
  final String status;

  MyTable({
    required this.id,
    required this.tableNumber,
    required this.status,
  });

  factory MyTable.fromJson(Map<String, dynamic> json) {
    return MyTable(
      id: json['_id'],
      tableNumber: json['tableNumber'],
      status: json['status'],
    );
  }
}
