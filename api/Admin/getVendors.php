<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    $sql = "SELECT v.vendor_id, v.store_name, v.store_description, v.address, v.status,
                   u.user_id, u.name, u.email, u.phone, u.created_at
            FROM vendors v
            JOIN users u ON v.user_id = u.user_id
            ORDER BY v.created_at DESC";
    
    $result = mysqli_query($con, $sql);
    $vendors = mysqli_fetch_all($result, MYSQLI_ASSOC);

    echo json_encode([
        "success" => true,
        "vendors" => $vendors,
        "message" => "Vendors fetched successfully"
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>