<?php
include './helpers/db.php';

try {
    // Check if all required fields are provided
    if (isset(
        $_POST['vendor_id'],
        $_POST['product_name'],
        $_POST['product_description'],
        $_POST['price'],
        $_POST['stock'],
        $_POST['category'],
        $_FILES['image']
    )) {
        // Extract POST data
        $vendor_id = $_POST['vendor_id'];
        $product_name = $_POST['product_name'];
        $product_description = $_POST['product_description'];
        $price = $_POST['price'];
        $stock = $_POST['stock'];
        $category = $_POST['category'];
        $image = $_FILES['image'];

        // Validate vendor_id
        $checkVendorQuery = "SELECT * FROM vendors WHERE vendor_id = '$vendor_id'";
        $vendorResult = mysqli_query($con, $checkVendorQuery);
        
        if (mysqli_num_rows($vendorResult) == 0) {
            echo json_encode(array(
                "success" => false,
                "message" => "Invalid vendor_id ($vendor_id). Vendor does not exist.",
            ));
            die();
        }
        
        // Image validation
        $imageName = $image['tmp_name'];
        $imageSize = $image['size'];
        $imageExtension = pathinfo($image['name'], PATHINFO_EXTENSION);

        $allowedExtensions = ['png', 'jpg', 'jpeg', 'webp', 'heic'];
        if (!in_array($imageExtension, $allowedExtensions)) {
            echo json_encode(array(
                "success" => false,
                "message" => "Only image files (png, jpg, jpeg, webp, heic) are allowed."
            ));
            die();
        }

        if ($imageSize > 10 * 1024 * 1024) {
            echo json_encode(array(
                "success" => false,
                "message" => "Image size must be less than 10MB."
            ));
            die();
        }

        // Generate unique file name and upload image
        $newFileName = uniqid() . '.' . $imageExtension;
        $newPath = './images/' . $newFileName;
        $actualPath = '/images/' . $newFileName;

        if (!move_uploaded_file($imageName, $newPath)) {
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to upload image. Please try again."
            ));
            die();
        }

        // Insert product into database
        $sql = "INSERT INTO products (vendor_id, product_name, product_description, price, stock, category_id, image_url)
                VALUES ('$vendor_id', '$product_name', '$product_description', '$price', '$stock', '$category', '$actualPath')";

        $result = mysqli_query($con, $sql);

        if (!$result) {
            echo json_encode(array(
                "success" => false,
                "message" => "Failed to add product. Please try again.",
                "error" => mysqli_error($con)
            ));
            die();
        }

        // Success response
        echo json_encode(array(
            "success" => true,
            "message" => "Product added successfully!"
        ));
    } else {
        echo json_encode(array(
            "success" => false,
            "message" => "Missing required fields. Please provide all required inputs."
        ));
    }
} catch (Exception $e) {
    echo json_encode(array(
        "success" => false,
        "message" => "An error occurred: " . $e->getMessage()
    ));
}
?>