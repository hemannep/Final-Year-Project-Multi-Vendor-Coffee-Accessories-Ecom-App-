<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    $data = json_decode(file_get_contents('php://input'), true);
    $userId = $data['user_id'];

    // Start transaction
    mysqli_begin_transaction($con);

    // First delete from vendors if user is a vendor
    $vendorCheck = mysqli_query($con, "SELECT vendor_id FROM vendors WHERE user_id = $userId");
    if (mysqli_num_rows($vendorCheck) > 0) {
        $vendor = mysqli_fetch_assoc($vendorCheck);
        $vendorId = $vendor['vendor_id'];
        
        // Delete vendor's products first
        mysqli_query($con, "DELETE FROM products WHERE vendor_id = $vendorId");
        
        // Then delete the vendor
        mysqli_query($con, "DELETE FROM vendors WHERE vendor_id = $vendorId");
    }

    // Delete user's orders and related data
    $orderQuery = mysqli_query($con, "SELECT order_id FROM orders WHERE user_id = $userId");
    while ($order = mysqli_fetch_assoc($orderQuery)) {
        $orderId = $order['order_id'];
        mysqli_query($con, "DELETE FROM order_items WHERE order_id = $orderId");
        mysqli_query($con, "DELETE FROM payments WHERE order_id = $orderId");
        mysqli_query($con, "DELETE FROM shipping_status WHERE order_id = $orderId");
    }
    mysqli_query($con, "DELETE FROM orders WHERE user_id = $userId");

    // Delete other user data
    mysqli_query($con, "DELETE FROM shipping WHERE user_id = $userId");
    mysqli_query($con, "DELETE FROM password_resets WHERE user_id = $userId");
    mysqli_query($con, "DELETE FROM reviews WHERE user_id = $userId");
    mysqli_query($con, "DELETE FROM wishlist WHERE user_id = $userId");

    // Finally delete the user
    mysqli_query($con, "DELETE FROM users WHERE user_id = $userId");

    // Commit transaction
    mysqli_commit($con);

    echo json_encode([
        "success" => true,
        "message" => "User and all related data deleted successfully"
    ]);

} catch (Exception $e) {
    // Rollback transaction if error occurs
    mysqli_rollback($con);
    
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>