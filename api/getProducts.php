<?php
include './helpers/db.php';
header('Content-Type: application/json');

try {
    // Only fetch products that are marked as 'Public'
    $sql = "SELECT p.*, c.category_title, c.category_description 
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            WHERE p.Online = 'Public'";

    $result = mysqli_query($con, $sql);

    if (!$result) {
        throw new Exception("Database query failed: " . mysqli_error($con));
    }

    $products = mysqli_fetch_all($result, MYSQLI_ASSOC);

    // Ensure proper UTF-8 encoding
    array_walk_recursive($products, function(&$value) {
        $value = utf8_encode($value);
    });

    echo json_encode([
        "success" => true,
        "products" => $products,
        "message" => "Products fetched successfully"
    ]);

} catch (Throwable $th) {
    error_log($th->getMessage()); // Log the error
    echo json_encode([
        "success" => false,
        "message" => "An error occurred while fetching products"
    ]);
}
?>