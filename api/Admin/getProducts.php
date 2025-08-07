<?php
include '../helpers/db.php';

header('Content-Type: application/json');

try {
    // Verify database connection
    if (!$con) {
        throw new Exception("Database connection failed");
    }

    $sql = "SELECT 
                p.*, 
                c.category_title, 
                c.category_description,
                u.name as vendor_name
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            JOIN vendors v ON p.vendor_id = v.vendor_id
            JOIN users u ON v.user_id = u.user_id
            ORDER BY p.created_at DESC";

    $result = mysqli_query($con, $sql);
    
    if (!$result) {
        throw new Exception(mysqli_error($con));
    }

    $products = mysqli_fetch_all($result, MYSQLI_ASSOC);

    // Ensure all responses are UTF-8 encoded
    array_walk_recursive($products, function(&$value) {
        $value = utf8_encode($value);
    });

    echo json_encode([
        "success" => true,
        "products" => $products
    ]);

} catch (Exception $e) {
    // Log the error
    error_log($e->getMessage());
    
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>