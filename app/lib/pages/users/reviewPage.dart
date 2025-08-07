import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:silverskin/constant.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/models/review.dart';

class ReviewPage extends StatefulWidget {
  final int productId;
  final String productName;
  final int orderId;
  final String imageUrl;

  const ReviewPage({
    required this.productId,
    required this.productName,
    required this.orderId,
    required this.imageUrl,
    super.key,
  });

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final GetDataController _dataController = Get.find<GetDataController>();
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoading = true;
  List<Review> _reviews = [];
  double _averageRating = 0;
  int _reviewCount = 0;
  bool _canReview = false;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      if (widget.orderId > 0) {
        _canReview = await _dataController.canUserReview(
          widget.orderId,
          widget.productId,
        );
      }
      await _loadReviews();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load review data",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReviews() async {
    try {
      final result = await _dataController.getReviews(widget.productId);
      setState(() {
        _reviews = result['reviews'];
        _averageRating = result['average_rating'];
        _reviewCount = result['review_count'];
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load reviews",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      Get.snackbar(
        "Error",
        "Please select a rating",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_reviewController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please write a review",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _dataController.submitReview(
        productId: widget.productId,
        orderId: widget.orderId,
        rating: _rating,
        comment: _reviewController.text,
      );

      await _loadReviews();
      _reviewController.clear();
      _rating = 0;
      setState(() => _canReview = false);

      Get.snackbar(
        "Success",
        "Review submitted successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index + 0.5 <= rating
              ? Icons.star
              : index + 1 <= rating
                  ? Icons.star_half
                  : Icons.star_border,
          color: Colors.amber,
          size: 24,
        );
      }),
    );
  }

  Widget _buildRatingInput() {
    if (!_canReview) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Rating:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _rating,
          min: 0,
          max: 5,
          divisions: 10,
          label: _rating.toStringAsFixed(1),
          onChanged: (value) => setState(() => _rating = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _rating == 0 ? "Not rated" : _rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 16),
            ),
            _buildRatingStars(_rating),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewInput() {
    if (!_canReview) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Your Review:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reviewController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Share your experience with this product...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: accentColor,
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Submit Review",
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(Review review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.userName ?? "Anonymous",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildRatingStars(review.rating),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM dd, yyyy').format(review.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Review ${widget.productName}",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          "http://$ipAddress/silverskin-api${widget.imageUrl}",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildRatingStars(_averageRating),
                                const SizedBox(width: 8),
                                Text(
                                  _reviewCount > 0
                                      ? "${_averageRating.toStringAsFixed(1)} ($_reviewCount reviews)"
                                      : "No reviews yet",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildRatingInput(),
                  _buildReviewInput(),
                  const SizedBox(height: 24),
                  const Text(
                    "Customer Reviews",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _reviews.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text("No reviews yet"),
                          ),
                        )
                      : Column(children: _reviews.map(_buildReviewItem).toList()),
                ],
              ),
            ),
    );
  }
}
