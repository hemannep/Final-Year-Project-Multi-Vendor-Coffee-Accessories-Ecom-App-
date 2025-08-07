<?php
include './helpers/db.php';

try {
    // Check if required fields are provided
    if (isset($_POST['user_id'], $_POST['product_id'])) {
        $user_id = $_POST['user_id'];
        $product_id = $_POST['product_id'];

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

        // Validate product_id
        $checkProductQuery = "SELECT * FROM products WHERE product_id = '$product_id'";
        $productResult = mysqli_query($con, $checkProductQuery);

        if (mysqli_num_rows($productResult) == 0) {
            echo json_encode(array(
                "success" => false,
                "message" => "Invalid product_id. Product does not exist.",
            ));
            die();
        }

        // Remove product from wishlist
        $sql = "DELETE FROM wishlist WHERE user_id = '$user_id' AND product_id = '$product_id'";
        $result = mysqli_query($con, $sql);

        if (!$result) {
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to remove product from wishlist. Please try again.",
                "error" => mysqli_error($con)
            ));
            die();
        }

        echo json_encode(array(
            "success" => true,
            "message" => "Product removed from wishlist successfully!",
        ));
    } else {
        echo json_encode(array(
            "success" => false,
            "message" => "Missing required fields. Please provide user_id and product_id.",
        ));
    }
} catch (Exception $e) {
    echo json_encode(array(
        "success" => false,
        "message" => "An error occurred: " . $e->getMessage()
    ));
}
?>