<?php
include './helpers/db.php';

try {
    if (isset($_POST['name'], $_POST['user_id'])) {
        $name = $_POST['name'];
        $email = $_POST['email'] ?? null;
        $phone = $_POST['phone'] ?? null;
        $user_id = $_POST['user_id'];
        
        // Update users table
        $userSql = "UPDATE users SET
            name = ?,
            email = ?,
            phone = ?
            WHERE user_id = ?";

        $userStmt = mysqli_prepare($con, $userSql);
        mysqli_stmt_bind_param($userStmt, "sssi", $name, $email, $phone, $user_id);
        $userResult = mysqli_stmt_execute($userStmt);

        // If vendor, update vendor table
        if (isset($_POST['store_name'], $_POST['store_description'], $_POST['address'])) {
            $storeName = $_POST['store_name'];
            $storeDescription = $_POST['store_description'];
            $address = $_POST['address'];

            $vendorSql = "UPDATE vendors SET
                store_name = ?,
                store_description = ?,
                address = ?
                WHERE user_id = ?";

            $vendorStmt = mysqli_prepare($con, $vendorSql);
            mysqli_stmt_bind_param($vendorStmt, "sssi", $storeName, $storeDescription, $address, $user_id);
            $vendorResult = mysqli_stmt_execute($vendorStmt);
            
            $success = $userResult && $vendorResult;
            $message = $success ? "Vendor profile updated successfully" : "Error updating vendor profile";
        } else {
            $success = $userResult;
            $message = $success ? "Profile updated successfully" : "Error updating profile";
        }

        echo json_encode([
            "success" => $success,
            "message" => $message,
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Required fields are missing",
        ]);
    }
} catch (\Throwable $th) {
    echo json_encode([
        "success" => false,
        "message" => $th->getMessage(),
    ]);
}