class CartItem {
  final String productId;
  final String productName;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.image,
    required this.quantity, 
  });
}
