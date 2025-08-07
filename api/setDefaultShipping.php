<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    if (!isset($_POST['user_id'], $_POST['shipping_id'])) {
        throw new Exception('User ID and Shipping ID are required');
    }

    $userId = (int)$_POST['user_id'];
    $shippingId = (int)$_POST['shipping_id'];

    // Start transaction
    $con->begin_transaction();

    try {
        // Reset all defaults first
        $con->query("UPDATE shipping SET is_default = 0 WHERE user_id = $userId");
        
        // Set new default
        $stmt = $con->prepare("UPDATE shipping SET is_default = 1 WHERE shipping_id = ? AND user_id = ?");
        $stmt->bind_param("ii", $shippingId, $userId);
        $stmt->execute();

        if ($stmt->affected_rows === 0) {
            throw new Exception('Address not found');
        }

        $con->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Default address updated'
        ]);
    } catch (Exception $e) {
        $con->rollback();
        throw $e;
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>