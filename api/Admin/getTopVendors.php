<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    $sql = "SELECT v.vendor_id, v.store_name, 
                   SUM(oi.price * oi.quantity) as total_sales
            FROM order_items oi
            JOIN products p ON oi.product_id = p.product_id
            JOIN vendors v ON p.vendor_id = v.vendor_id
            JOIN orders o ON oi.order_id = o.order_id
            WHERE o.order_status IN ('Online Paid', 'Cash Paid')
            GROUP BY v.vendor_id
            ORDER BY total_sales DESC
            LIMIT 5";

    $result = mysqli_query($con, $sql);
    $vendors = mysqli_fetch_all($result, MYSQLI_ASSOC);

    echo json_encode([
        "success" => true,
        "vendors" => $vendors,
        "message" => "Top vendors fetched successfully"
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>