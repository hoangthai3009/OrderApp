class Review {
  final String id;
  final String customerName;
  final int rating;
  final String comment;
  String? emotion;

  Review({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.emotion,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'],
      customerName: json['customer'],
      rating: json['rating'],
      comment: json['comment'],
      emotion: json['emotion'],
    );
  }
}
