<?php
header("Content-Type: application/json");
include './helpers/db.php';

try {
    if (!isset($_POST['product_id'])) {
        echo json_encode(["success" => false, "message" => "Product ID is required"]);
        exit();
    }

    $productId = (int)$_POST['product_id'];
    
    // First get the image path to delete the file
    $sql = "SELECT image_url FROM products WHERE product_id = ?";
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "i", $productId);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    
    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        $imagePath = '.' . $row['image_url'];
        
        // Delete the product
        $deleteSql = "DELETE FROM products WHERE product_id = ?";
        $deleteStmt = mysqli_prepare($con, $deleteSql);
        mysqli_stmt_bind_param($deleteStmt, "i", $productId);
        $success = mysqli_stmt_execute($deleteStmt);
        
        if ($success) {
            // Delete the image file if exists
            if (file_exists($imagePath)) {
                unlink($imagePath);
            }
            echo json_encode(["success" => true, "message" => "Product deleted successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Failed to delete product"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Product not found"]);
    }

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
}
?>