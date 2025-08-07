<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    // Validate required fields
    if (!isset($_POST['order_id']) || !isset($_POST['new_status'])) {
        throw new Exception('Both order_id and new_status are required');
    }

    $order_id = (int)$_POST['order_id'];
    $new_status = $_POST['new_status'];

    // Begin transaction
    mysqli_begin_transaction($con);

    // Update order status
    $update_sql = "UPDATE orders SET order_status = ? WHERE order_id = ?";
    $update_stmt = mysqli_prepare($con, $update_sql);
    mysqli_stmt_bind_param($update_stmt, "si", $new_status, $order_id);
    $update_result = mysqli_stmt_execute($update_stmt);

    if (!$update_result) {
        throw new Exception('Failed to update order status');
    }

    // If changing from Payment Due to COD, add shipping status
    if ($new_status == 'COD') {
        // Get user_id from order
        $user_sql = "SELECT user_id FROM orders WHERE order_id = ?";
        $user_stmt = mysqli_prepare($con, $user_sql);
        mysqli_stmt_bind_param($user_stmt, "i", $order_id);
        mysqli_stmt_execute($user_stmt);
        mysqli_stmt_bind_result($user_stmt, $user_id);
        mysqli_stmt_fetch($user_stmt);
        mysqli_stmt_close($user_stmt);

        $shipping_sql = "INSERT INTO shipping_status (order_id, user_id, status) 
                        VALUES (?, ?, 'Pending')";
        $shipping_stmt = mysqli_prepare($con, $shipping_sql);
        mysqli_stmt_bind_param($shipping_stmt, "ii", $order_id, $user_id);
        $shipping_result = mysqli_stmt_execute($shipping_stmt);

        if (!$shipping_result) {
            throw new Exception('Failed to create shipping status');
        }
    }

    // Commit transaction
    mysqli_commit($con);

    echo json_encode([
        'success' => true,
        'message' => 'Order status updated successfully'
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