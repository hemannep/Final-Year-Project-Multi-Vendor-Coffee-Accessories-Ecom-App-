<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    $data = json_decode(file_get_contents('php://input'), true);
    $userId = $data['user_id'];

    // Check if user exists and is not already a vendor
    $userQuery = mysqli_query($con, "SELECT role FROM users WHERE user_id = $userId");
    if (mysqli_num_rows($userQuery) == 0) {
        throw new Exception("User not found");
    }

    $user = mysqli_fetch_assoc($userQuery);
    if ($user['role'] == 'vendor') {
        throw new Exception("User is already a vendor");
    }

    // Update user role to vendor
    mysqli_query($con, "UPDATE users SET role = 'vendor' WHERE user_id = $userId");

    echo json_encode([
        "success" => true,
        "message" => "User approved as vendor successfully"
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>