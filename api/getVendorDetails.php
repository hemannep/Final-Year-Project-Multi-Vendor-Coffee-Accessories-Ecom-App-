<?php
header("Content-Type: application/json");
include './helpers/db.php';

try {
    if (!isset($_POST['vendor_id'])) {
        echo json_encode(["success" => false, "message" => "Vendor ID required"]);
        exit();
    }

    $vendorId = (int)$_POST['vendor_id'];
    
    $sql = "SELECT v.*, u.name, u.email, u.phone 
            FROM vendors v 
            JOIN users u ON v.user_id = u.user_id
            WHERE v.vendor_id = ?";
    
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "i", $vendorId);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if (!$result || mysqli_num_rows($result) === 0) {
        echo json_encode(["success" => false, "message" => "Vendor not found"]);
        exit();
    }

    $vendor = mysqli_fetch_assoc($result);

    echo json_encode([
        "success" => true,
        "vendor" => [
            "vendor_id" => $vendor['vendor_id'],
            "user_id" => $vendor['user_id'],
            "store_name" => $vendor['store_name'],
            "store_description" => $vendor['store_description'],
            "address" => $vendor['address'],
            "name" => $vendor['name'],      // From users table
            "email" => $vendor['email'],    // From users table
            "phone" => $vendor['phone'],    // From users table
        ]
    ]);

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
}
?>