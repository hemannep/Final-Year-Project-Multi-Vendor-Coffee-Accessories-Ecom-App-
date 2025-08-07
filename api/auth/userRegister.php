<?php

include "../helpers/db.php";

if(isset(
    $_POST['fullName'],
    $_POST['email'], 
    $_POST['phone'],
    $_POST['password']

    )){

        $email = $_POST['email'];
        $fullName = $_POST['fullName'];
        $phone = $_POST['phone'];
        $password = $_POST['password'];

        $sql = "Select * from users where email = '$email'";
        $result = mysqli_query($con,$sql);

        if (!$result){
            echo json_encode(array(
                "success" => false,
                "message" => "An Error occurred, please try again",
                
            ));
            die();
        }
        $count = mysqli_num_rows($result);
        if($count > 0){
            echo json_encode(array( 
                "success" => false,
                "message" => "Email already exists",
                
            ));
            die();

        }   

        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        $sql = "INSERT INTO users (name, email,phone , password,role) VALUES ('$fullName', '$email','$phone', '$hashed_password','user')";
        $result = mysqli_query($con,$sql);
        if (!$result){
            echo json_encode(array(
                "success" => false,
                " message" => "An Error occurred, please try again",
            ));
            die();

        }

        echo json_encode(array(
            "success" => true,
            "message" => "User created successfully",

        ));


    } else {
        echo json_encode(array(
            "success" => false,
            "message" => "Full Name, email, phone number and password are required",
            
        ));
        die();
    }

