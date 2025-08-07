<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    if (!isset(
        $_POST['shipping_id'],
        $_POST['user_id'],
        $_POST['address'],
        $_POST['city'],
        $_POST['state'],
        $_POST['postal_code'],
        $_POST['country']
    )) {
        throw new Exception('All fields are required');
    }

    $shippingId = (int)$_POST['shipping_id'];
    $user_id = (int)$_POST['user_id'];
    $address = $con->real_escape_string($_POST['address']);
    $city = $con->real_escape_string($_POST['city']);
    $state = $con->real_escape_string($_POST['state']);
    $postalCode = $con->real_escape_string($_POST['postal_code']);
    $country = $con->real_escape_string($_POST['country']);

    $stmt = $con->prepare("UPDATE shipping SET 
        address = ?,
        city = ?,
        state = ?,
        postal_code = ?,
        country = ?
        WHERE shipping_id = ? AND user_id = ?
    ");
    
    $stmt->bind_param("sssssii", $address, $city, $state, $postalCode, $country, $shippingId, $user_id);
    $stmt->execute();

    echo json_encode([
        'success' => $stmt->affected_rows > 0,
        'message' => $stmt->affected_rows > 0 ? 'Address updated successfully' : 'No changes made'
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>