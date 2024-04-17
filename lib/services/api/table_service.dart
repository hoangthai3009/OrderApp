import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:order_app/constants.dart';
import 'package:order_app/models/table.dart';

class TableService {
  static Future<List<MyTable>> fetchTableData() async {
    final response = await http.get(Uri.parse('http://$ip:3000/api/v1/tables'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((tableJson) => MyTable.fromJson(tableJson)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<void> changeStatusTable(int tableNumber, String status) async {
    final url =
        Uri.parse('http://$ip:3000/api/v1/tables/${tableNumber}/change-status');

    try {
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({"status": status}),
      );

      if (response.statusCode == 200) {
        // Successful API response
        print('Table occupied successfully');
      } else {
        // Handle API error
        print('Failed to occupy table. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error while occupying table: $e');
    }
  }
}
