import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:order_app/constants.dart';
import 'package:order_app/models/product.dart';

class ProductService {
  static Future<List<Product>> fetchProductData() async {
    const String apiUrl = 'http://$ip:3000/api/v1/products';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((productJson) => Product.fromJson(productJson)).toList();
    } else {
      throw Exception('Failed to load product data');
    }
  }

  static Future<List<Product>> searchProducts(String keyword) async {
    final String apiUrl =
        'http://$ip:3000/api/v1/products/search?keyword=$keyword';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((productJson) => Product.fromJson(productJson)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> fetchProductsByType(String productType) async {
    final String apiUrl = 'http://$ip:3000/api/v1/products/search/$productType';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((productJson) => Product.fromJson(productJson)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
