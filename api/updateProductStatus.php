<?php
include './helpers/db.php';
header('Content-Type: application/json');

try {
    // Validate input
    if (!isset($_POST['product_id']) || !isset($_POST['status'])) {
        throw new Exception("Product ID and status are required");
    }

    $product_id = (int)$_POST['product_id'];
    $status = mysqli_real_escape_string($con, $_POST['status']);

    // Validate status
    $allowedStatuses = ['Public', 'Private', 'Rejected'];
    if (!in_array($status, $allowedStatuses)) {
        throw new Exception("Invalid status value");
    }

    // Update the product status
    $sql = "UPDATE products SET Online = ? WHERE product_id = ?";
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "si", $status, $product_id);
    mysqli_stmt_execute($stmt);

    if (mysqli_stmt_affected_rows($stmt) > 0) {
        echo json_encode([
            "success" => true,
            "message" => "Product status updated successfully"
        ]);
    } else {
        throw new Exception("No changes made or product not found");
    }

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}
?>