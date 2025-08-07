<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    if (isset($_POST['email'], $_POST['password'])) {
        $email = $_POST['email'];
        $password = $_POST['password'];

        // Get user with vendor status
        $sql = "SELECT users.*, vendors.vendor_id, vendors.status as vendor_status 
                FROM users
                LEFT JOIN vendors ON users.user_id = vendors.user_id
                WHERE users.email = ?";
        
        $stmt = mysqli_prepare($con, $sql);
        mysqli_stmt_bind_param($stmt, "s", $email);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);

        if (mysqli_num_rows($result) === 0) {
            echo json_encode([
                "success" => false,
                "message" => "User not found!"
            ]);
            exit();
        }

        $user = mysqli_fetch_assoc($result);

        // Verify password
        if (!password_verify($password, $user['password'])) {
            echo json_encode([
                "success" => false,
                "message" => "Incorrect password!"
            ]);
            exit();
        }

        // Vendor status checks
        if ($user['role'] === 'vendor') {
            if ($user['vendor_status'] === 'Rejected') {
                echo json_encode([
                    "success" => false,
                    "message" => "vendor_rejected",
                    "role" => $user['role']
                ]);
                exit();
            } elseif ($user['vendor_status'] === 'Waiting for Approval') {
                echo json_encode([
                    "success" => false,
                    "message" => "vendor_pending",
                    "role" => $user['role']
                ]);
                exit();
            } elseif ($user['vendor_status'] !== 'Online') {
                echo json_encode([
                    "success" => false,
                    "message" => "Vendor account not active",
                    "role" => $user['role']
                ]);
                exit();
            }
        }

        // Successful login
        echo json_encode([
            "success" => true,
            "message" => "Login successful",
            "role" => $user['role'],
            "user_id" => $user['user_id'],
            "vendor_id" => $user['vendor_id'] ?? null,
            "vendor_status" => $user['vendor_status'] ?? null
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Email and password are required"
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}