<?php
include './helpers/db.php';
try {

    if (isset($_POST['user_id'])) {
        $user_id = $_POST['user_id'];
    } else {
        echo json_encode(array(
            "success" => false,
            "message" => "user_id is required",
        ));
        die();
    }


    $sql = "select * from users where user_id = '$user_id'";

    $result = mysqli_query($con, $sql);

    if (!$result) {
        echo json_encode(array(
            "success" => false,
            "message" => "An error occurred, please try again",
        ));
        die();
    }

    $user = mysqli_fetch_assoc($result);

    echo json_encode(array(
        "success" => true,
        "user" => $user,
        "message" => "User fetched successfully",
    ));
} catch (\Throwable $th) {
    echo json_encode(array(
        "success" => false,
        "message" => $th->getMessage(),
    ));
}
