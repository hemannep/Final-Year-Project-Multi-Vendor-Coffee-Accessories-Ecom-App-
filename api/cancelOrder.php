<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    // Validate required fields
    if (!isset($_POST['order_id']) || !isset($_POST['user_id'])) {
        throw new Exception('Both order_id and user_id are required');
    }

    $order_id = (int)$_POST['order_id'];
    $user_id = (int)$_POST['user_id'];

    // Begin transaction
    mysqli_begin_transaction($con);

    // Check if order belongs to user and is cancelable (only COD orders can be canceled)
    $check_sql = "SELECT order_id FROM orders 
                 WHERE order_id = ? AND user_id = ? 
                 AND order_status IN ('COD', 'Online Paid', 'Cash Paid')
                 AND order_id NOT IN (
                     SELECT order_id FROM shipping_status 
                     WHERE status IN ('Shipped', 'Delivered')
                 )";
    
    $check_stmt = mysqli_prepare($con, $check_sql);
    mysqli_stmt_bind_param($check_stmt, "ii", $order_id, $user_id);
    mysqli_stmt_execute($check_stmt);
    mysqli_stmt_store_result($check_stmt);

    if (mysqli_stmt_num_rows($check_stmt) == 0) {
        throw new Exception('Order cannot be canceled. Either it has already been shipped/delivered or is not eligible for cancellation.');
    }

    // Update order status to 'Canceled'
    $update_sql = "UPDATE orders SET order_status = 'Canceled' WHERE order_id = ?";
    $update_stmt = mysqli_prepare($con, $update_sql);
    mysqli_stmt_bind_param($update_stmt, "i", $order_id);
    $update_result = mysqli_stmt_execute($update_stmt);

    if (!$update_result) {
        throw new Exception('Failed to update order status');
    }

    // Also update shipping status to reflect cancellation
    $update_shipping_sql = "UPDATE shipping_status SET status = 'Canceled' WHERE order_id = ?";
    $update_shipping_stmt = mysqli_prepare($con, $update_shipping_sql);
    mysqli_stmt_bind_param($update_shipping_stmt, "i", $order_id);
    $shipping_result = mysqli_stmt_execute($update_shipping_stmt);

    if (!$shipping_result) {
        throw new Exception('Failed to update shipping status');
    }

    // Commit transaction
    mysqli_commit($con);

    echo json_encode([
        'success' => true,
        'message' => 'Order canceled successfully'
    ]);

} catch (Exception $e) {
    mysqli_rollback($con);
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>