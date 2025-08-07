<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    $sql = "SELECT user_id, name, email, phone, role, created_at 
            FROM users 
            ORDER BY created_at DESC";
    
    $result = mysqli_query($con, $sql);
    $users = mysqli_fetch_all($result, MYSQLI_ASSOC);

    echo json_encode([
        "success" => true,
        "users" => $users,
        "message" => "Users fetched successfully"
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>