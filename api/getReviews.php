<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    if (!isset($_POST['product_id'])) {
        throw new Exception('product_id is required');
    }

    $product_id = (int)$_POST['product_id'];

    $sql = "SELECT r.*, u.name as user_name 
            FROM reviews r
            JOIN users u ON r.user_id = u.user_id
            WHERE r.product_id = $product_id
            ORDER BY r.created_at DESC";
    
    $result = mysqli_query($con, $sql);

    if (!$result) {
        throw new Exception('Database error: ' . mysqli_error($con));
    }

    $reviews = mysqli_fetch_all($result, MYSQLI_ASSOC);

    // Get average rating
    $avg_sql = "SELECT AVG(rating) as avg_rating, COUNT(*) as review_count 
                FROM reviews 
                WHERE product_id = $product_id";
    $avg_result = mysqli_query($con, $avg_sql);
    $avg_data = mysqli_fetch_assoc($avg_result);

    echo json_encode([
        'success' => true,
        'reviews' => $reviews,
        'average_rating' => round($avg_data['avg_rating'] ?? 0, 1),
        'review_count' => $avg_data['review_count'] ?? 0
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>