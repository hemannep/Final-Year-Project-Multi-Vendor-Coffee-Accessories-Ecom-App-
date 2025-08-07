<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    // Get user_id from either GET, POST or REQUEST
    $userId = isset($_REQUEST['user_id']) ? (int)$_REQUEST['user_id'] : null;
    if (!$userId) {
        throw new Exception('User ID is required');
    }

    // Check if the user exists - use prepared statement here too for security
    $userCheck = $con->prepare("SELECT user_id FROM users WHERE user_id = ?");
    if ($userCheck === false) {
        throw new Exception('Failed to prepare user check statement: ' . $con->error);
    }
    
    $userCheck->bind_param("i", $userId);
    $userCheck->execute();
    $userCheck->store_result();
    
    if ($userCheck->num_rows === 0) {
        throw new Exception('User does not exist');
    }
    $userCheck->close();

    // Get all shipping addresses for the user
    $stmt = $con->prepare("SELECT 
        shipping_id,
        address,
        city,
        state,
        postal_code,
        country
        FROM shipping 
        WHERE user_id = ?");

    if ($stmt === false) {
        throw new Exception('Failed to prepare statement: ' . $con->error);
    }

    $stmt->bind_param("i", $userId);
    $stmt->execute();

    $result = $stmt->get_result();
    $shippingAddresses = $result->fetch_all(MYSQLI_ASSOC);

    echo json_encode([
        'success' => true,
        'data' => $shippingAddresses,
        'message' => 'Shipping addresses retrieved successfully'
    ]);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>