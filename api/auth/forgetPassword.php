<?php
header('Content-Type: application/json');
include '../helpers/db.php';

try {
    $data = json_decode(file_get_contents('php://input'), true);
    $email = $data['email'] ?? null;

    if (!$email) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Email is required']);
        exit;
    }

    // Check if user exists
    $stmt = $con->prepare("SELECT user_id FROM users WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        // For security, don't reveal if email doesn't exist
        echo json_encode(['success' => true, 'message' => 'If this email exists, an OTP has been generated']);
        exit;
    }

    $user = $result->fetch_assoc();
    $user_id = $user['user_id'];
    $token = bin2hex(random_bytes(32));
    $otp = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT); // 6-digit OTP
    $expiry = date('Y-m-d H:i:s', strtotime('+15 minutes')); // OTP valid for 15 mins

    // Store token and OTP in database
    $stmt = $con->prepare("INSERT INTO password_resets (user_id, token, otp, expiry) VALUES (?, ?, ?, ?) 
                          ON DUPLICATE KEY UPDATE token = VALUES(token), otp = VALUES(otp), expiry = VALUES(expiry)");
    $stmt->bind_param("isss", $user_id, $token, $otp, $expiry);
    $stmt->execute();

    // In development, return the OTP in the response
    // In production, you would send this OTP via email instead
    echo json_encode([
        'success' => true,
        'message' => 'OTP generated successfully',
        'user_id' => $user_id,
        'otp' => $otp // Remove this line in production
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Server error: ' . $e->getMessage()]);
}