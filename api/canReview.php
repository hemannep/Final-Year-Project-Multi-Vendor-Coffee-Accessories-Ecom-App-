<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    $required = ['user_id', 'order_id', 'product_id'];
    foreach ($required as $field) {
        if (!isset($_POST[$field])) {
            throw new Exception("$field is required");
        }
    }

    $userId = (int)$_POST['user_id'];
    $orderId = (int)$_POST['order_id'];
    $productId = (int)$_POST['product_id'];

    // Check if order exists and is delivered
    $orderCheck = mysqli_query($con, 
        "SELECT o.order_id 
         FROM orders o
         JOIN shipping_status ss ON o.order_id = ss.order_id
         WHERE o.order_id = $orderId 
         AND o.user_id = $userId
         AND ss.status = 'Delivered'");
    
    if (mysqli_num_rows($orderCheck) == 0) {
        throw new Exception('Order not found or not delivered');
    }

    // Check if product was in this order
    $productCheck = mysqli_query($con, 
        "SELECT 1 FROM order_items 
         WHERE order_id = $orderId AND product_id = $productId");
    
    if (mysqli_num_rows($productCheck) == 0) {
        throw new Exception('Product not in order');
    }

    // Check if already reviewed
    $reviewCheck = mysqli_query($con, 
        "SELECT 1 FROM reviews 
         WHERE order_id = $orderId AND product_id = $productId");
    
    echo json_encode([
        'success' => true,
        'can_review' => mysqli_num_rows($reviewCheck) == 0
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>