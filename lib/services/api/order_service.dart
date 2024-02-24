import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:order_app/constants.dart';
import 'package:order_app/models/order_item.dart';
import 'package:order_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class OrderService {
  static Future<void> placeOrder(
      BuildContext context, CartProvider cartProvider) async {
    String apiUrl = 'http://$ip:3000/api/v1/order';

    // Prepare data from cartProvider
    Map<String, dynamic> orderData = {
      'items': cartProvider.cartItems
          .map((item) => {
                'productId': item.productId,
                'quantity': item.quantity,
              })
          .toList(),
      'tableNumber': cartProvider.tableRoom,
    };
    String jsonData = json.encode(orderData);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 201) {
        print('Order placed successfully');
        cartProvider.cartItems.clear();
        Navigator.pop(context);
      } else {
        print('Failed to place order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during HTTP request: $e');
    }
  }

  static Future<List<OrderItem>> fetchOrders(BuildContext context) async {
    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    String apiUrl =
        'http://$ip:3000/api/v1/order/table-number/${cartProvider.tableRoom}';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<OrderItem>.from(data.map((item) => OrderItem.fromJson(item)));
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<void> cancelledOrder(String id) async {
    final url = Uri.parse('http://$ip:3000/api/v1/order/$id/change-status?status=cancelled');

    try {
      final response = await http.put(url);

      if (response.statusCode == 200) {
        // Successful API response
        print('Hủy thành công');
      } else {
        // Handle API error
        print('Failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
    }
  }
}
