<?php
include './helpers/db.php';
header('Content-Type: application/json');

try {
    if (!isset($_POST['product_id'])) {
        throw new Exception('product_id is required');
    }

    $product_id = (int)$_POST['product_id'];

    $sql = "SELECT v.*, u.name, u.email, u.phone 
            FROM vendors v
            JOIN users u ON v.user_id = u.user_id
            JOIN products p ON p.vendor_id = v.vendor_id
            WHERE p.product_id = ?";
    
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "i", $product_id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($result) > 0) {
        $vendor = mysqli_fetch_assoc($result);
        echo json_encode([
            'success' => true,
            'vendor' => $vendor
        ]);
    } else {
        throw new Exception('Vendor not found for this product');
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
?>