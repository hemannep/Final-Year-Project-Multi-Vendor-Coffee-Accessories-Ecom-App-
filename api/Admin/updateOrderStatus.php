<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    if (!isset($_POST['order_id'], $_POST['action'])) {
        throw new Exception('Missing required parameters');
    }

    $order_id = (int)$_POST['order_id'];
    $action = $_POST['action'];

    mysqli_begin_transaction($con);

    if ($action === 'mark_shipped') {
        // Update shipping status to "Shipped"
        $sql = "UPDATE shipping_status SET status = 'Shipped', updated_at = NOW() WHERE order_id = ?";
        $stmt = mysqli_prepare($con, $sql);
        mysqli_stmt_bind_param($stmt, "i", $order_id);
        $success = mysqli_stmt_execute($stmt);
        
        if (!$success) {
            throw new Exception('Failed to update shipping status to Shipped');
        }
    } 
    elseif ($action === 'mark_delivered') {
        // First update shipping status to "Delivered"
        $sql1 = "UPDATE shipping_status SET status = 'Delivered', updated_at = NOW() WHERE order_id = ?";
        $stmt1 = mysqli_prepare($con, $sql1);
        mysqli_stmt_bind_param($stmt1, "i", $order_id);
        $success1 = mysqli_stmt_execute($stmt1);
        
        if (!$success1) {
            throw new Exception('Failed to update shipping status to Delivered');
        }

        // Check current order status
        $check_sql = "SELECT order_status FROM orders WHERE order_id = ?";
        $check_stmt = mysqli_prepare($con, $check_sql);
        mysqli_stmt_bind_param($check_stmt, "i", $order_id);
        mysqli_stmt_execute($check_stmt);
        mysqli_stmt_bind_result($check_stmt, $current_status);
        mysqli_stmt_fetch($check_stmt);
        mysqli_stmt_close($check_stmt);

        // Only update order status if it's COD
        if ($current_status === 'COD') {
            $sql2 = "UPDATE orders SET order_status = 'Cash Paid' WHERE order_id = ?";
            $stmt2 = mysqli_prepare($con, $sql2);
            mysqli_stmt_bind_param($stmt2, "i", $order_id);
            $success2 = mysqli_stmt_execute($stmt2);
            
            if (!$success2) {
                throw new Exception('Failed to update order status to Cash Paid');
            }
        }
        // If order_status is already 'Paid' (Online Paid), do nothing
    } 
    else {
        throw new Exception('Invalid action');
    }

    mysqli_commit($con);
    echo json_encode([
        'success' => true,
        'message' => 'Status updated successfully'
    ]);

} catch (Exception $e) {
    mysqli_rollback($con);
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
?>