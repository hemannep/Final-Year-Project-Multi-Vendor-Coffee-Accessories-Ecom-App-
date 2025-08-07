<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    if (!isset(
        $_POST['user_id'],
        $_POST['address'],
        $_POST['city'],
        $_POST['state'],
        $_POST['postal_code'],
        $_POST['country']
    )) {
        throw new Exception('All fields are required');
    }

    $userId = (int)$_POST['user_id'];
    $address = $con->real_escape_string($_POST['address']);
    $city = $con->real_escape_string($_POST['city']);
    $state = $con->real_escape_string($_POST['state']);
    $postalCode = $con->real_escape_string($_POST['postal_code']);
    $country = $con->real_escape_string($_POST['country']);

    // Check if the user exists
    $userCheck = $con->query("SELECT user_id FROM users WHERE user_id = $userId");
    if ($userCheck === false || $userCheck->num_rows === 0) {
        throw new Exception('User does not exist');
    }

    // Modified query to match your actual table structure
    $stmt = $con->prepare("INSERT INTO shipping (
        user_id, 
        address, 
        city, 
        state, 
        postal_code, 
        country
        
    ) VALUES (?, ?, ?, ?, ?, ?)");
    
    if ($stmt === false) {
        throw new Exception('Failed to prepare statement: ' . $con->error);
    }
    
    $stmt->bind_param("isssss", $userId, $address, $city, $state, $postalCode, $country);
    $stmt->execute();

    echo json_encode([
        'success' => true,
        'shipping_id' => $stmt->insert_id,
        'message' => 'Address added successfully'
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>