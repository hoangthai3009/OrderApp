import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:order_app/constants.dart';
import 'package:order_app/models/review.dart';

class ReviewService {
  Future<List<Review>> getReviews() async {
    final response =
        await http.get(Uri.parse('http://$ip:3000/api/v1/reviews'));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Review.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<String> predictEmotion(String comment) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ip:5000/predict-emotion'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({"text": comment}),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final emotion = decodedResponse['emotion'] as String?;
        if (emotion != null) {
          return emotion;
        } else {
          throw Exception('Emotion is null');
        }
      } else {
        print('Error predicting emotion: ${response.statusCode}');
        throw Exception('Failed to load emotion');
      }
    } catch (e) {
      print('Error predicting emotion: $e');
      throw Exception('Failed to predict emotion');
    }
  }

  Future<void> postReview({
    required String customer,
    required String comment,
    required int rating,
  }) async {
    final response = await http.post(
      Uri.parse('http://$ip:3000/api/v1/reviews'),
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
