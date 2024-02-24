import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_app/models/cart_item.dart';
import 'package:order_app/providers/cart_provider.dart';
import 'package:order_app/services/api/order_service.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider = context.watch<CartProvider>();

    if (cartProvider.cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Đơn hàng của bàn ${cartProvider.tableRoom}'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(50),
          child: Text(
            'Giỏ hàng của bạn đang trống. Hãy thêm sản phẩm vào giỏ hàng!',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng của bàn ${cartProvider.tableRoom}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                CartItem cartItem = cartProvider.cartItems[index];
                return _buildCartItem(context, cartItem);
              },
            ),
          ),
          _buildTotalAndOrderButton(context),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem) {
    TextEditingController quantityController =
        TextEditingController(text: cartItem.quantity.toString());

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8.0),
        leading: SizedBox(
          width: 80,
          height: 80,
          child: Image.network(
            cartItem.image,
            fit: BoxFit.cover,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cartItem.productName,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Giá: ${currencyFormat.format(cartItem.price)}',
              style: const TextStyle(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _updateQuantity(context, cartItem, -1),
              child: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 30.0,
              child: TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                controller: quantityController,
                onEditingComplete: () {
                  int newQuantity = int.tryParse(quantityController.text) ??
                      cartItem.quantity;
                  int change = newQuantity - cartItem.quantity;

                  _updateQuantity(context, cartItem, change);
                },
              ),
            ),
            GestureDetector(
              onTap: () => _updateQuantity(context, cartItem, 1),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: () => _removeCartItem(context, cartItem),
          child: const Icon(Icons.delete),
        ),
      ),
    );
  }

  Widget _buildTotalAndOrderButton(BuildContext context) {
    CartProvider cartProvider = context.watch<CartProvider>();
    double totalAmount = cartProvider.calculateTotalAmount();

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tổng cộng: ${currencyFormat.format(totalAmount)}',
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              await OrderService.placeOrder(context, cartProvider);
            },
            child: const Text('Đặt Món'),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(BuildContext context, CartItem cartItem, int change) {
    Provider.of<CartProvider>(context, listen: false)
        .updateQuantity(cartItem, change);
  }

  void _removeCartItem(BuildContext context, CartItem cartItem) {
    Provider.of<CartProvider>(context, listen: false).removeFromCart(cartItem);
  }
}
