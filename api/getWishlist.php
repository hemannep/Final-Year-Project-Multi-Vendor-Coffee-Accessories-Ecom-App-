<?php
include './helpers/db.php';

try {
    // Debugging: Log the received POST data
    error_log("Received POST data: " . print_r($_POST, true));

    // Check if user_id is provided
    if (isset($_POST['user_id'])) {
        $user_id = $_POST['user_id'];

        // Debugging: Log the user_id
        error_log("User ID: $user_id");

        // Validate user_id
        $checkUserQuery = "SELECT * FROM users WHERE user_id = '$user_id'";
        $userResult = mysqli_query($con, $checkUserQuery);

        if (mysqli_num_rows($userResult) == 0) {
            echo json_encode(array(
                "success" => false,
                "message" => "Invalid user_id. User does not exist.",
            ));
            die();
        }

        // Fetch wishlist for the user
        $wishlistQuery = "SELECT p.* FROM wishlist w
                          JOIN products p ON w.product_id = p.product_id
                          WHERE w.user_id = '$user_id'";
        $wishlistResult = mysqli_query($con, $wishlistQuery);

        if (!$wishlistResult) {
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to fetch wishlist. Please try again.",
                "error" => mysqli_error($con)
            ));
            die();
        }

        $wishlist = [];
        while ($row = mysqli_fetch_assoc($wishlistResult)) {
            $wishlist[] = $row;
        }

        echo json_encode(array(
            "success" => true,
            "data" => $wishlist,
        ));
    } else {
        echo json_encode(array(
            "success" => false,
            "message" => "Missing required field: user_id.",
        ));
    }
} catch (Exception $e) {
    echo json_encode(array(
        "success" => false,
        "message" => "An error occurred: " . $e->getMessage()
    ));
}
?>