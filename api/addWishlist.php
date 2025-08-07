<?php
include './helpers/db.php';

try {
    if (isset($_POST['user_id'], $_POST['product_id'])) {
        $user_id = $_POST['user_id'];
        $product_id = $_POST['product_id'];

        // Check if the product is already in the wishlist
        $checkWishlistQuery = "SELECT * FROM wishlist WHERE user_id = '$user_id' AND product_id = '$product_id'";
        $wishlistResult = mysqli_query($con, $checkWishlistQuery);

        if (mysqli_num_rows($wishlistResult) > 0) {
            echo json_encode(array(
                "success" => false,
                "message" => "Product is already in the wishlist."
            ));
            die();
        }

        // Insert into wishlist
        $sql = "INSERT INTO wishlist (user_id, product_id) VALUES ('$user_id', '$product_id')";
        $result = mysqli_query($con, $sql);

        if (!$result) {
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to add product to wishlist. Please try again.",
                "error" => mysqli_error($con)
            ));
            die();
        }

        // Success response
        echo json_encode(array(
            "success" => true,
            "message" => "Product added to wishlist successfully!"
        ));
    } else {
        echo json_encode(array(
            "success" => false,
            "message" => "Missing required fields. Please provide user_id and product_id."
        ));
    }
} catch (Exception $e) {
    echo json_encode(array(
        "success" => false,
        "message" => "An error occurred: " . $e->getMessage()
    ));
}
?>