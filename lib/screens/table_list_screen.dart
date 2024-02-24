import 'package:flutter/material.dart';
import 'package:order_app/models/table.dart';
import 'package:order_app/providers/cart_provider.dart';
import 'package:order_app/services/api/table_service.dart';
import 'package:provider/provider.dart';

class TableListScreen extends StatefulWidget {
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableListScreen> {
  List<MyTable> tables = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final List<MyTable> data = await TableService.fetchTableData();
      setState(() {
        tables = data;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _showConfirmationDialog(int tableNumber) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: Text('Bạn chắc chắn muốn chọn bàn số $tableNumber chứ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Provider.of<CartProvider>(context, listen: false)
                    .setTableRoom(tableNumber);
                await TableService.occupyTable(tableNumber);
                Navigator.pushReplacementNamed(context, '/productList');
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bàn'),
      ),
      body: ListView.builder(
        itemCount: tables.length,
        itemBuilder: (context, index) {
          MyTable table = tables[index];
          bool isAvailable = table.status == 'available';

          return Card(
            color: isAvailable ? Colors.green[100] : Colors.grey[300],
            child: ListTile(
              title: Text(
                'Bàn số ${table.tableNumber}',
                style: TextStyle(
                  color: isAvailable ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Trạng thái: ${isAvailable ? 'Có thể đặt bàn' : (table.status == 'reserved' ? 'Bàn đã được đặt trước' : 'Bàn đang được đặt')}',
                style: TextStyle(
                  color: isAvailable ? Colors.green : Colors.grey,
                ),
              ),
              onTap: isAvailable
                  ? () {
                      _showConfirmationDialog(table.tableNumber);
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
