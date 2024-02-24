import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_app/models/cart_item.dart';
import 'package:order_app/models/product.dart';
import 'package:order_app/providers/cart_provider.dart';
import 'package:order_app/screens/product_detail_screen.dart';
import 'package:order_app/services/api/product_service.dart';
import 'package:provider/provider.dart';

class ProductTypeListScreen extends StatefulWidget {
  final String type;

  const ProductTypeListScreen({Key? key, required this.type}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductTypeListScreen> {
  List<Product> products = [];
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    fetchProductsByType();
  }

  Future<void> fetchProductsByType() async {
    try {
      final List<Product> data =
          await ProductService.fetchProductsByType(widget.type);
      setState(() {
        products = data;
      });
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách ${widget.type}'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.73,
        ),
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          Product product = products[index];
          return _buildProductItem(product);
        },
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      shadowColor: Colors.grey[400],
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              child: Image.network(
                product.img,
                height: 130.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    currencyFormat.format(product.price),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      CartProvider cartProvider = context.read<CartProvider>();

                      CartItem cartItem = CartItem(
                        productId: product.id,
                        productName: product.name,
                        price: product.price,
                        image: product.img,
                        quantity: 1,
                      );

                      cartProvider.addToCart(cartItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${product.name} đã được thêm vào giỏ hàng.'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Thêm vào đơn hàng'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
