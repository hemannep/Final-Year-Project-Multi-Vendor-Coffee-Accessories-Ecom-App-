<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    if (!isset($_POST['user_id'], $_POST['order_id'], $_POST['amount'])) {
        throw new Exception('user_id, order_id, and amount are required');
    }

    $user_id = (int)$_POST['user_id'];
    $order_id = (int)$_POST['order_id'];
    $amount = (float)$_POST['amount'];
    $other_details = isset($_POST['other_details']) ? $_POST['other_details'] : null;

    // Begin transaction
    mysqli_begin_transaction($con);

    // 1. Verify order exists and has empty status
    $verify_sql = "SELECT order_id FROM orders WHERE order_id = ? AND user_id = ? AND order_status = ''";
    $verify_stmt = mysqli_prepare($con, $verify_sql);
    mysqli_stmt_bind_param($verify_stmt, "ii", $order_id, $user_id);
    mysqli_stmt_execute($verify_stmt);
    mysqli_stmt_store_result($verify_stmt);

    if (mysqli_stmt_num_rows($verify_stmt) == 0) {
        throw new Exception('Order not found or already processed');
    }

    // 2. Create payment record
    $payment_sql = "INSERT INTO payments (user_id, order_id, amount, other_details) VALUES (?, ?, ?, ?)";
    $payment_stmt = mysqli_prepare($con, $payment_sql);
    mysqli_stmt_bind_param($payment_stmt, "iids", $user_id, $order_id, $amount, $other_details);
    mysqli_stmt_execute($payment_stmt);

    // 3. Update order status to 'Online Paid'
    $order_sql = "UPDATE orders SET order_status = 'Online Paid' WHERE order_id = ?";
    $order_stmt = mysqli_prepare($con, $order_sql);
    mysqli_stmt_bind_param($order_stmt, "i", $order_id);
    mysqli_stmt_execute($order_stmt);

    // 4. Update product stock
    $items_sql = "SELECT product_id, quantity FROM order_items WHERE order_id = ?";
    $items_stmt = mysqli_prepare($con, $items_sql);
    mysqli_stmt_bind_param($items_stmt, "i", $order_id);
    mysqli_stmt_execute($items_stmt);
    $items_result = mysqli_stmt_get_result($items_stmt);
    
    while ($item = mysqli_fetch_assoc($items_result)) {
        $update_sql = "UPDATE products SET stock = stock - ? WHERE product_id = ?";
        $update_stmt = mysqli_prepare($con, $update_sql);
        mysqli_stmt_bind_param($update_stmt, "ii", $item['quantity'], $item['product_id']);
        mysqli_stmt_execute($update_stmt);
    }

    // Commit transaction
    mysqli_commit($con);

    echo json_encode([
        'success' => true,
        'message' => 'Payment processed successfully'
    ]);

} catch (Exception $e) {
    mysqli_rollback($con);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>