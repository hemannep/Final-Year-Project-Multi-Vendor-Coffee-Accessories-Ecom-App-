<?php
header('Content-Type: application/json');
include '../helpers/db.php';

try {
    $data = json_decode(file_get_contents('php://input'), true);
    $user_id = $data['user_id'] ?? null;
    $otp = $data['otp'] ?? null;

    if (!$user_id || !$otp) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'User ID and OTP are required']);
        exit;
    }

    // Verify OTP
    $stmt = $con->prepare("SELECT token FROM password_resets 
                          WHERE user_id = ? AND otp = ? AND expiry > NOW()");
    $stmt->bind_param("is", $user_id, $otp);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid or expired OTP']);
        exit;
    }

    $data = $result->fetch_assoc();
    echo json_encode([
        'success' => true,
        'message' => 'OTP verified successfully',
        'token' => $data['token'],
        'user_id' => $user_id
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Server error: ' . $e->getMessage()]);
}