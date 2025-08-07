<?php
include './helpers/db.php';

try {
    if (isset($_POST['name'], $_POST['user_id'])) {
        $name = $_POST['name'];
        $email = isset($_POST['email']) ? $_POST['email'] : null;
        $phone = isset($_POST['phone']) ? $_POST['phone'] : null;
        $user_id = $_POST['user_id'];

        // Ensure empty values are NULL
        $email = !empty($email) ? $email : null;
        $phone = !empty($phone) ? $phone : null;

        $sql = "UPDATE users SET
            name = ?,
            email = ?,
            phone  = ?
        WHERE user_id = ?";

        $stmt = mysqli_prepare($con, $sql);
        if (!$stmt) {
            echo json_encode([
                "success" => false,
                "message" => "SQL preparation failed: " . mysqli_error($con),
            ]);
            die();
        }

        mysqli_stmt_bind_param($stmt, "ssss", $name, $email, $phone, $user_id);
        $result = mysqli_stmt_execute($stmt);

        if (!$result) {
            echo json_encode([
                "success" => false,
                "message" => "An error occurred: " . mysqli_error($con),
            ]);
            die();
        }

        echo json_encode([
            "success" => true,
            "message" => "User updated successfully",
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "name and user_id are required",
        ]);
        die();
    }
} catch (\Throwable $th) {
    echo json_encode([
        "success" => false,
        "message" => $th->getMessage(),
    ]);
}
