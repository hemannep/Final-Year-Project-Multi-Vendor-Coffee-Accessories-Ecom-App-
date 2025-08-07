<?php
include './helpers/db.php';
header('Content-Type: application/json');

try {
    if (isset($_POST['vendor_id'], $_POST['order_id'])) {
        $vendor_id = $_POST['vendor_id'];
        $order_id = $_POST['order_id'];

        // Begin transaction
        mysqli_begin_transaction($con);

        // Verify the vendor owns products in this order
        $verifySql = "SELECT oi.order_id 
                     FROM order_items oi
                     JOIN products p ON oi.product_id = p.product_id
                     WHERE oi.order_id = ? AND p.vendor_id = ?";
        $stmt = mysqli_prepare($con, $verifySql);
        mysqli_stmt_bind_param($stmt, "ii", $order_id, $vendor_id);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);

        if (mysqli_num_rows($result) > 0) {
            // Only update shipping status to 'Processing'
            $updateShippingSql = "UPDATE shipping_status SET status = 'Processing' 
                                WHERE order_id = ?";
            $stmt = mysqli_prepare($con, $updateShippingSql);
            mysqli_stmt_bind_param($stmt, "i", $order_id);
            mysqli_stmt_execute($stmt);

            // Commit transaction
            mysqli_commit($con);

            echo json_encode([
                "success" => true,
                "message" => "Order Dispatched Successfully"
            ]);
        } else {
            mysqli_rollback($con);
            echo json_encode([
                "success" => false,
                "message" => "Order not found or unauthorized"
            ]);
        }
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Missing required parameters"
        ]);
    }
} catch (Exception $e) {
    mysqli_rollback($con);
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>