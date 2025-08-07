<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    $sql = "SELECT o.order_id, o.order_status, o.total_price, o.created_at, 
                   u.name as user_name, u.email as user_email
            FROM orders o
            JOIN users u ON o.user_id = u.user_id
            ORDER BY o.created_at DESC
            LIMIT 5";

    $result = mysqli_query($con, $sql);
    $orders = mysqli_fetch_all($result, MYSQLI_ASSOC);

    echo json_encode([
        "success" => true,
        "orders" => $orders,
        "message" => "Recent orders fetched successfully"
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>