<?php
include "../helpers/db.php";

if (isset(
    $_POST['name'],
    $_POST['store_name'],
    $_POST['email'],
    $_POST['phone'],
    $_POST['password'],
    $_POST['store_description'],
    $_POST['address']
)) {

    $email = $_POST['email'];
    $name = $_POST['name'];
    $phone = $_POST['phone'];
    $password = $_POST['password'];
    $store_name = $_POST['store_name'];
    $store_description = $_POST['store_description'];
    $address = $_POST['address'];


    // Check if the email already exists in the users table
    $sql = "SELECT * FROM users WHERE email = '$email'";
    $result = mysqli_query($con, $sql);

    if (!$result) {
        echo json_encode(array(
            "success" => false,
            "message" => "An error occurred, please try again",
        ));
        die();
    }

    $count = mysqli_num_rows($result);
    if ($count > 0) {
        echo json_encode(array(
            "success" => false,
            "message" => "Email already exists",
        ));
        die();
    }

    // Insert into users table and assign role as 'vendor'
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    $sql = "INSERT INTO users (name, email, phone, password, role) VALUES ('$name', '$email', '$phone', '$hashed_password', 'vendor')";
    $result = mysqli_query($con, $sql);

    if (!$result) {
        echo json_encode(array(
            "success" => false,
            "message" => "An error occurred while creating the user, please try again",
        ));
        die();
    }

    // Get the user_id of the newly created user
    $user_id = mysqli_insert_id($con);

    // Insert into vendors table with 'Waiting for Approval' status
    $sql = "INSERT INTO vendors (user_id, store_name, store_description, address, status) 
            VALUES ('$user_id', '$store_name', '$store_description', '$address', 'Waiting for Approval')";
    $result = mysqli_query($con, $sql);

    if (!$result) {
        echo json_encode(array(
            "success" => false,
            "message" => "An error occurred while creating the vendor, please try again",
        ));
        die();
    }

    echo json_encode(array(
        "success" => true,
        "message" => "Vendor registration submitted for approval. You'll be notified once approved.",
    ));
} else {
    echo json_encode(array(
        "success" => false,
        "message" => "Full Name, email, phone number, password, store name, store description, and address are required",
    ));
    die();
}