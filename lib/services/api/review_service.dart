import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:order_app/constants.dart';
import 'package:order_app/models/review.dart';

class ReviewService {
  Future<List<Review>> getReviews() async {
    final response = await http.get(Uri.parse('http://$ip:3000/api/v1/review'));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Review.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> postReview({
    required String customer,
    required String comment,
    required int rating,
  }) async {
    final response = await http.post(
      Uri.parse('http://$ip:3000/api/v1/review'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'customer': customer,
        'comment': comment,
        'rating': rating,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post review');
    }
  }
}
