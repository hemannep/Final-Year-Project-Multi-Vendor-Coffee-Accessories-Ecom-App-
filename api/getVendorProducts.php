<?php
include './helpers/db.php';
header('Content-Type: application/json');

try {
    if (!isset($_POST['vendor_id'])) {
        throw new Exception("Vendor ID is required");
    }

    $vendor_id = (int)$_POST['vendor_id'];
    
    $sql = "SELECT p.*, c.category_title 
            FROM products p
            JOIN categories c ON p.category_id = c.category_id
            WHERE p.vendor_id = ?";
    
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "i", $vendor_id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    $products = mysqli_fetch_all($result, MYSQLI_ASSOC);

    echo json_encode([
        "success" => true,
        "products" => $products
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}
?>