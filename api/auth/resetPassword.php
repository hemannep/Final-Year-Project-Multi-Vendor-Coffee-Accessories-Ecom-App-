<?php
header('Content-Type: application/json');
include '../helpers/db.php';

try {
    $data = json_decode(file_get_contents('php://input'), true);
    $token = $data['token'] ?? null;
    $user_id = $data['user_id'] ?? null;
    $new_password = $data['new_password'] ?? null;

    if (!$token || !$user_id || !$new_password) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'All fields are required']);
        exit;
    }

    if (strlen($new_password) < 6) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Password must be at least 6 characters']);
        exit;
    }

    // Verify token
    $stmt = $con->prepare("SELECT * FROM password_resets 
                          WHERE user_id = ? AND token = ? AND expiry > NOW()");
    $stmt->bind_param("is", $user_id, $token);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid or expired token']);
        exit;
    }

    // Update password
    $hashed_password = password_hash($new_password, PASSWORD_DEFAULT);
    $stmt = $con->prepare("UPDATE users SET password = ? WHERE user_id = ?");
    $stmt->bind_param("si", $hashed_password, $user_id);
    $stmt->execute();

    // Delete used token
    $stmt = $con->prepare("DELETE FROM password_resets WHERE user_id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();

    echo json_encode(['success' => true, 'message' => 'Password updated successfully']);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Server error: ' . $e->getMessage()]);
}