class Product {
  final String id;
  final String name;
  final String description;
  final String img;
  final double price;
  final String type;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.img,
    required this.price,
    required this.type,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      img: json['img'],
      price: json['price'].toDouble(),
      type: json['type'],
    );
  }
}
