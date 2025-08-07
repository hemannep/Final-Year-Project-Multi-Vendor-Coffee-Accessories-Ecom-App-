<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    // Validate required fields
    $required = ['user_id', 'product_id', 'order_id', 'rating', 'comment'];
    foreach ($required as $field) {
        if (!isset($_POST[$field])) {
            throw new Exception("$field is required");
        }
    }

    $user_id = (int)$_POST['user_id'];
    $product_id = (int)$_POST['product_id'];
    $order_id = (int)$_POST['order_id'];
    $rating = (float)$_POST['rating'];
    $comment = mysqli_real_escape_string($con, $_POST['comment']);

    // Validate rating (0.5 to 5.0 in 0.5 increments)
    if ($rating < 0.5 || $rating > 5.0 || fmod($rating * 10, 5) != 0) {
        throw new Exception('Rating must be between 0.5 and 5.0 in 0.5 increments');
    }

    // Check if order is delivered
    $order_check = mysqli_query($con, 
        "SELECT o.order_id 
         FROM orders o
         JOIN shipping_status ss ON o.order_id = ss.order_id
         WHERE o.order_id = $order_id 
         AND o.user_id = $user_id
         AND ss.status = 'Delivered'");
    
    if (mysqli_num_rows($order_check) == 0) {
        throw new Exception('You can only review delivered products');
    }

    // Check if product was in this order
    $product_check = mysqli_query($con, 
        "SELECT 1 FROM order_items 
         WHERE order_id = $order_id AND product_id = $product_id");
    
    if (mysqli_num_rows($product_check) == 0) {
        throw new Exception('This product was not in your order');
    }

    // Check if already reviewed
    $existing_review = mysqli_query($con, 
        "SELECT 1 FROM reviews 
         WHERE order_id = $order_id AND product_id = $product_id");
    
    if (mysqli_num_rows($existing_review) > 0) {
        throw new Exception('You have already reviewed this product');
    }

    // Insert review
    $sql = "INSERT INTO reviews (product_id, user_id, order_id, rating, comment)
            VALUES ($product_id, $user_id, $order_id, $rating, '$comment')";
    
    if (mysqli_query($con, $sql)) {
        echo json_encode([
            'success' => true,
            'message' => 'Review submitted successfully'
        ]);
    } else {
        throw new Exception('Failed to submit review');
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>