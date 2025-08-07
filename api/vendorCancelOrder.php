<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    // Validate required fields
    if (!isset($_POST['order_id']) || !isset($_POST['vendor_id'])) {
        throw new Exception('Both order_id and vendor_id are required');
    }

    $order_id = (int)$_POST['order_id'];
    $vendor_id = (int)$_POST['vendor_id'];

    // Begin transaction
    mysqli_begin_transaction($con);

    // Verify the order belongs to this vendor
    $check_sql = "SELECT o.order_id 
                 FROM orders o
                 JOIN order_items oi ON o.order_id = oi.order_id
                 JOIN products p ON oi.product_id = p.product_id
                 WHERE o.order_id = ? AND p.vendor_id = ?";
    $check_stmt = mysqli_prepare($con, $check_sql);
    mysqli_stmt_bind_param($check_stmt, "ii", $order_id, $vendor_id);
    mysqli_stmt_execute($check_stmt);
    mysqli_stmt_store_result($check_stmt);

    if (mysqli_stmt_num_rows($check_stmt) == 0) {
        throw new Exception('Order not found or does not belong to this vendor');
    }

    // Update order status to Rejected
    $update_sql = "UPDATE orders SET order_status = 'Rejected' WHERE order_id = ?";
    $update_stmt = mysqli_prepare($con, $update_sql);
    mysqli_stmt_bind_param($update_stmt, "i", $order_id);
    mysqli_stmt_execute($update_stmt);

    // Remove from shipping_status table
    $delete_sql = "DELETE FROM shipping_status WHERE order_id = ?";
    $delete_stmt = mysqli_prepare($con, $delete_sql);
    mysqli_stmt_bind_param($delete_stmt, "i", $order_id);
    mysqli_stmt_execute($delete_stmt);

    // Commit transaction
    mysqli_commit($con);

    echo json_encode([
        'success' => true,
        'message' => 'Order has been Rejected and removed from shipping'
    ]);

} catch (Exception $e) {
    mysqli_rollback($con);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>