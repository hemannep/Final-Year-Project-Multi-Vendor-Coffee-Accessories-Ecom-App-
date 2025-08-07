<?php
include './helpers/db.php';
try {


    $sql = "select * from categories";

    $result = mysqli_query($con, $sql);

    if (!$result) {
        echo json_encode(array(
            "success" => false,
            "message" => "An error occurred, please try again",
        ));
        die();
    }

    $products = mysqli_fetch_all($result, MYSQLI_ASSOC);

    echo json_encode(array(
        "success" => true,
        "categories" => $products,
        "message" => "Categories fetched successfully"
    ));
} catch (\Throwable $th) {
    echo json_encode(array(
        "success" => false,
        "message" => $th->getMessage(),
    ));
}