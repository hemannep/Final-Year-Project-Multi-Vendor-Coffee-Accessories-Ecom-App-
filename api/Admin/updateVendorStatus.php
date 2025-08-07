<?php
include '../helpers/db.php';

// Clear any previous output
ob_clean();

// Set JSON header
header('Content-Type: application/json');

try {
    // Get and decode JSON input
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    // Validate input
    if (json_last_error() !== JSON_ERROR_NONE) {
        throw new Exception("Invalid JSON input");
    }

    if (!isset($data['vendor_id']) || !isset($data['status'])) {
        throw new Exception("Missing required fields");
    }

    $vendorId = (int)$data['vendor_id'];
    $status = $data['status'];

    // Validate status
    $validStatuses = ['Online', 'Waiting for Approval', 'Rejected'];
    if (!in_array($status, $validStatuses)) {
        throw new Exception("Invalid status value");
    }

    // Update database
    $stmt = $con->prepare("UPDATE vendors SET status = ? WHERE vendor_id = ?");
    $stmt->bind_param("si", $status, $vendorId);
    $stmt->execute();

    // Prepare success response
    $response = [
        'success' => true,
        'message' => 'Vendor status updated successfully',
        'vendor_id' => $vendorId,
        'new_status' => $status
    ];

    // Output JSON and exit
    echo json_encode($response);
    exit();

} catch (Exception $e) {
    // Prepare error response
    $response = [
        'success' => false,
        'message' => $e->getMessage(),
        'error' => true
    ];
    
    echo json_encode($response);
    exit();
}