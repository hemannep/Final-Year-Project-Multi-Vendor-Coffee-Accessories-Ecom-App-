<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    if (!isset($_POST['product_id'])) {
        throw new Exception('Product ID is required');
    }

    $product_id = (int)$_POST['product_id'];

    // First delete from order_items to maintain referential integrity
    $sql = "DELETE FROM order_items WHERE product_id = ?";
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "i", $product_id);
    mysqli_stmt_execute($stmt);

    // Then delete the product
    $sql = "DELETE FROM products WHERE product_id = ?";
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "i", $product_id);
    mysqli_stmt_execute($stmt);

    if (mysqli_stmt_affected_rows($stmt)) {
        echo json_encode([
            "success" => true,
            "message" => "Product deleted successfully"
        ]);
    } else {
        throw new Exception('Product not found or already deleted');
    }

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>