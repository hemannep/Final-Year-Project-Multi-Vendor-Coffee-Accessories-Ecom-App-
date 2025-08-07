<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    if (!isset($_POST['shipping_id'], $_POST['user_id'])) {
        throw new Exception('Shipping ID and User ID are required');
    }

    $shippingId = (int)$_POST['shipping_id'];
    $userId = (int)$_POST['user_id'];

    // Verify the shipping address belongs to the user
    $verifyStmt = $con->prepare("SELECT shipping_id FROM shipping WHERE shipping_id = ? AND user_id = ?");
    $verifyStmt->bind_param("ii", $shippingId, $userId);
    $verifyStmt->execute();
    $verifyStmt->store_result();

    if ($verifyStmt->num_rows === 0) {
        throw new Exception('Shipping address not found or does not belong to user');
    }
    $verifyStmt->close();

    // Delete the shipping address
    $deleteStmt = $con->prepare("DELETE FROM shipping WHERE shipping_id = ?");
    $deleteStmt->bind_param("i", $shippingId);
    $deleteStmt->execute();

    echo json_encode([
        'success' => $deleteStmt->affected_rows > 0,
        'message' => $deleteStmt->affected_rows > 0 ? 'Shipping address deleted successfully' : 'No shipping address found'
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>