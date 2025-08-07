<?php
header("Content-Type: application/json");
include './helpers/db.php';

try {
    // Check required fields
    $requiredFields = ['product_id', 'product_name', 'price', 'stock', 'product_description', 'category_id'];
    foreach ($requiredFields as $field) {
        if (!isset($_POST[$field])) {
            echo json_encode(["success" => false, "message" => "$field is required"]);
            exit();
        }
    }

    $productId = (int)$_POST['product_id'];
    $productName = mysqli_real_escape_string($con, $_POST['product_name']);
    $price = (float)$_POST['price'];
    $stock = (int)$_POST['stock'];
    $description = mysqli_real_escape_string($con, $_POST['product_description']);
    $categoryId = (int)$_POST['category_id'];

    // Update product in database
    $sql = "UPDATE products SET 
            product_name = ?,
            product_description = ?,
            price = ?,
            stock = ?,
            category_id = ?
            WHERE product_id = ?";
    
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "ssdiii", 
        $productName, $description, $price, $stock, $categoryId, $productId);
    
    $success = mysqli_stmt_execute($stmt);

    if ($success) {
        echo json_encode([
            "success" => true,
            "message" => "Product updated successfully"
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Failed to update product"
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>