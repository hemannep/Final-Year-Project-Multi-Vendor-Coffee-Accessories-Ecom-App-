<?php
header("Content-Type: application/json");
include './helpers/db.php';

try {
    // Debugging: Log the query to confirm it's correct
    error_log("Fetching all vendors...");
    
    $sql = "SELECT 
              v.vendor_id, 
              v.user_id, 
              v.store_name, 
              v.store_description, 
              v.address,
              u.name AS owner_name,
              u.email,
              u.phone
            FROM vendors v
            JOIN users u ON v.user_id = u.user_id";
    
    $result = mysqli_query($con, $sql);

    if (!$result) {
        echo json_encode([
            "success" => false,
            "message" => "Failed to fetch vendors: " . mysqli_error($con)
        ]);
        exit();
    }

    $vendors = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $vendors[] = $row;
    }

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
