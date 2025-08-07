<?php
include '../helpers/db.php';

header('Content-Type: application/json');

try {
    // Validate input
    if (!isset($_POST['product_id']) || !isset($_POST['status'])) {
        throw new Exception("Missing required parameters");
    }

    $product_id = (int)$_POST['product_id'];
    $status = mysqli_real_escape_string($con, $_POST['status']);

    // Validate status
    $validStatuses = ['public', 'private', 'rejected'];
    if (!in_array(strtolower($status), $validStatuses)) {
        throw new Exception("Invalid status value");
    }

    $sql = "UPDATE products SET Online = ? WHERE product_id = ?";
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "si", $status, $product_id);
    $success = mysqli_stmt_execute($stmt);

    if (!$success) {
        throw new Exception(mysqli_error($con));
    }

    echo json_encode([
        "success" => true,
        "message" => "Product status updated successfully"
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}
?>