<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    if (!isset($_POST['user_id'], $_POST['currentPassword'], $_POST['newPassword'])) {
        echo json_encode([
            "success" => false,
            "message" => "user_id, currentPassword and newPassword are required",
        ]);
        die();
    }

    $user_id = $_POST['user_id'];
    $currentPassword = $_POST['currentPassword'];
    $newPassword = $_POST['newPassword'];

    // Validate new password length
    if (strlen($newPassword) < 6) {
        echo json_encode([
            "success" => false,
            "message" => "New password must be at least 6 characters",
        ]);
        die();
    }

    // Get user data
    $sql = "SELECT * FROM users WHERE user_id = ?";
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "i", $user_id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if (!$result || mysqli_num_rows($result) === 0) {
        echo json_encode([
            "success" => false,
            "message" => "User not found",
        ]);
        die();
    }

    $user = mysqli_fetch_assoc($result);
    $hashed_password = $user['password'];

    if (!password_verify($currentPassword, $hashed_password)) {
        echo json_encode([
            "success" => false,
            "message" => "Incorrect current password",
        ]);
        die();
    }

    $newHashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);

    // Update password
    $sql = "UPDATE users SET password = ? WHERE user_id = ?";
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "si", $newHashedPassword, $user_id);
    $result = mysqli_stmt_execute($stmt);

    if (!$result) {
        echo json_encode([
            "success" => false,
            "message" => "Failed to update password. Please try again.",
        ]);
        die();
    }

    echo json_encode([
        "success" => true,
        "message" => "Password changed successfully",
    ]);
} catch (\Throwable $th) {
    error_log("Change password error: " . $th->getMessage());
    echo json_encode([
        "success" => false,
        "message" => "An unexpected error occurred",
    ]);
}