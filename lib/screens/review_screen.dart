import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:order_app/constants.dart';
import 'package:order_app/models/review.dart';
import 'package:order_app/services/api/review_service.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  double _rating = 0.0;
  List<Review> _reviews = [];
  bool _isAddingReview = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      List<Review> reviews = await _reviewService.getReviews();
      for (var review in reviews) {
        final emotion = await _reviewService.predictEmotion(review.comment);
        review.emotion = emotion;
      }
      setState(() {
        _reviews = reviews;
      });
    } catch (e) {
      print('Error loading reviews: $e');
    }
  }

  Future<void> _postReview() async {
    try {
      await _reviewService.postReview(
        customer: _nameController.text,
        comment: _commentController.text,
        rating: _rating.toInt(),
      );

      _nameController.clear();
      _commentController.clear();
      _rating = 0.0;

      await _loadReviews();
    } catch (e) {
      print('Error posting review: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đánh giá'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                Review review = _reviews[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      review.customerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(review.comment),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Đánh giá: '),
                            RatingBarIndicator(
                              rating: review.rating.toDouble(),
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction: Axis.horizontal,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: _buildEmotionIcon(review.emotion.toString()),
                  ),
                );
              },
            ),
          ),
          _isAddingReview
              ? _buildAddReviewForm()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isAddingReview = true;
                      });
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmotionIcon(String emotion) {
    switch (emotion) {
      case 'Negative':
        return const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red);
      case 'Positive':
        return const Icon(Icons.sentiment_very_satisfied, color: Colors.green);
      case 'Neutral':
        return const Icon(Icons.sentiment_neutral, color: Colors.blue);
      default:
        return const Icon(Icons.sentiment_neutral,
            color: Colors.grey); // Xử lý trường hợp mặc định
    }
  }

  Widget _buildAddReviewForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nhập tên của bạn',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Nhập đánh giá',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
              ),
            ),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30.0,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isAddingReview = false;
                    });
                    _postReview();
                  },
                  child: const Text('Đánh giá'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isAddingReview = false;
                    });
                  },
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
