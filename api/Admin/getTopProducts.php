<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    $sql = "SELECT p.product_id, p.product_name, p.price, p.image_url,
                   SUM(oi.quantity) as total_sold
            FROM order_items oi
            JOIN products p ON oi.product_id = p.product_id
            JOIN orders o ON oi.order_id = o.order_id
            WHERE o.order_status IN ('Online Paid', 'Cash Paid')
            GROUP BY p.product_id
            ORDER BY total_sold DESC
            LIMIT 5";

    $result = mysqli_query($con, $sql);
    $products = mysqli_fetch_all($result, MYSQLI_ASSOC);

    echo json_encode([
        "success" => true,
        "products" => $products,
        "message" => "Top products fetched successfully"
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>