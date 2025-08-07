<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    $data = json_decode(file_get_contents('php://input'), true);
    $vendorId = $data['vendor_id'];

    // Start transaction
    mysqli_begin_transaction($con);

    // First delete all products from this vendor
    mysqli_query($con, "DELETE FROM products WHERE vendor_id = $vendorId");

    // Then delete the vendor
    mysqli_query($con, "DELETE FROM vendors WHERE vendor_id = $vendorId");

    // Commit transaction
    mysqli_commit($con);

    echo json_encode([
        "success" => true,
        "message" => "Vendor and all products deleted successfully"
    ]);

} catch (Exception $e) {
    // Rollback transaction if error occurs
    mysqli_rollback($con);
    
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>