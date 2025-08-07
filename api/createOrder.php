<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    // Validate required fields
    if (!isset($_POST['user_id'], $_POST['total_price'], $_POST['cart'])) {
        throw new Exception('user_id, total_price, and cart are required');
    }

    $user_id = (int)$_POST['user_id'];
    $total_price = (float)$_POST['total_price'];
    $cart_items = json_decode($_POST['cart'], true);
    $is_cod = isset($_POST['is_cod']) ? (int)$_POST['is_cod'] : 0;
    $shipping_id = isset($_POST['shipping_id']) ? (int)$_POST['shipping_id'] : null;

    // Begin transaction
    mysqli_begin_transaction($con);

    // Create temporary order with empty status (will be updated on success)
    $order_sql = "INSERT INTO orders (user_id, order_status, total_price) VALUES (?, '', ?)";
    $order_stmt = mysqli_prepare($con, $order_sql);
    mysqli_stmt_bind_param($order_stmt, "id", $user_id, $total_price);
    mysqli_stmt_execute($order_stmt);
    
    $order_id = mysqli_insert_id($con);

    // Process each cart item (but don't update stock yet)
    foreach ($cart_items as $item) {
        $product_id = (int)$item['product']['product_id'];
        $quantity = (int)$item['quantity'];
        
        // Get product price
        $product_sql = "SELECT price FROM products WHERE product_id = ?";
        $product_stmt = mysqli_prepare($con, $product_sql);
        mysqli_stmt_bind_param($product_stmt, "i", $product_id);
        mysqli_stmt_execute($product_stmt);
        $product_result = mysqli_stmt_get_result($product_stmt);
        $product = mysqli_fetch_assoc($product_result);
        
        if (!$product) {
            throw new Exception("Product ID $product_id not found");
        }
        
        $price = $product['price'] * $quantity;
        
        // Add order item
        $item_sql = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
        $item_stmt = mysqli_prepare($con, $item_sql);
        mysqli_stmt_bind_param($item_stmt, "iiii", $order_id, $product_id, $quantity, $price);
        mysqli_stmt_execute($item_stmt);
    }

    // If COD, update status immediately
    if ($is_cod) {
        $update_sql = "UPDATE orders SET order_status = 'COD' WHERE order_id = ?";
        $update_stmt = mysqli_prepare($con, $update_sql);
        mysqli_stmt_bind_param($update_stmt, "i", $order_id);
        mysqli_stmt_execute($update_stmt);
    }

    // Add shipping info if provided
    if ($shipping_id) {
        $shipping_sql = "UPDATE orders SET shipping_id = ? WHERE order_id = ?";
        $shipping_stmt = mysqli_prepare($con, $shipping_sql);
        mysqli_stmt_bind_param($shipping_stmt, "ii", $shipping_id, $order_id);
        mysqli_stmt_execute($shipping_stmt);
    }

    // Create shipping status record with initial status 'Pending'
    $status_sql = "INSERT INTO shipping_status (order_id, user_id, status) VALUES (?, ?, 'Pending')";
    $status_stmt = mysqli_prepare($con, $status_sql);
    mysqli_stmt_bind_param($status_stmt, "ii", $order_id, $user_id);
    mysqli_stmt_execute($status_stmt);

    // Commit transaction
    mysqli_commit($con);

    echo json_encode([
        'success' => true,
        'order_id' => $order_id,
        'message' => 'Order created successfully',
        'order_status' => $is_cod ? 'COD' : 'Pending Payment',
        'shipping_status' => 'Pending',
        'is_cod' => $is_cod
    ]);

} catch (Exception $e) {
    mysqli_rollback($con);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>