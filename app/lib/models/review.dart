class Review {
  final int reviewId;
  final int productId;
  final int userId;
  final int orderId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? userName;

  Review({
    required this.reviewId,
    required this.productId,
    required this.userId,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: int.tryParse(json['review_id'].toString()) ?? 0,
      productId: int.tryParse(json['product_id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      orderId: int.tryParse(json['order_id'].toString()) ?? 0,
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'].toString()),
      userName: json['user_name']?.toString(),
    );
  }
}