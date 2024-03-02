import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
        title: const Text('Đánh giá'),
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
                    title: Text(review.customerName),
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

  Widget _buildAddReviewForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên của bạn'),
            ),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Bình luận'),
            ),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 40.0,
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
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isAddingReview = false;
                    });
                    _postReview();
                  },
                  child: const Text('Bình luận'),
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
