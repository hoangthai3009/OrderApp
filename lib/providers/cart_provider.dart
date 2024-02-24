import 'package:flutter/material.dart';
import 'package:order_app/models/cart_item.dart';

// cart_provider.dart
class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];
  int _tableRoom = 0;

  List<CartItem> get cartItems => _cartItems;
  int get tableRoom => _tableRoom;

  void addToCart(CartItem cartItem) {
    int existingIndex =
        _cartItems.indexWhere((item) => item.productId == cartItem.productId);

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += cartItem.quantity;
    } else {
      _cartItems.add(cartItem);
    }

    notifyListeners();
  }

  void updateQuantity(CartItem cartItem, int change) {
    int index = _cartItems.indexOf(cartItem);
    if (index != -1) _cartItems[index].quantity += change;
    if (_cartItems[index].quantity <= 0) _cartItems.removeAt(index);

    notifyListeners();
  }

  void removeFromCart(CartItem cartItem) {
    _cartItems.remove(cartItem);
    notifyListeners();
  }

  void setTableRoom(int tableRoom) {
    _tableRoom = tableRoom;
    notifyListeners();
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;

    for (CartItem cartItem in _cartItems) {
      totalAmount += cartItem.price * cartItem.quantity;
    }

    return totalAmount;
  }
}
