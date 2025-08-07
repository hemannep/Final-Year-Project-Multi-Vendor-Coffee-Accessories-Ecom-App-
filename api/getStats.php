<?php
include './helpers/db.php';
try {



    $sql = "select count(*) as total_users from users";

    $result = mysqli_query($con, $sql);

    if (!$result) {
        echo json_encode(array(
            "success" => false,
            "message" => "An error occurred, please try again",
        ));
        die();
    }

    $total_users = mysqli_fetch_assoc($result);


    $sql = "select count(*) as total_products from products";

    $result = mysqli_query($con, $sql);

    if (!$result) {
        echo json_encode(array(
            "success" => false,
            "message" => "An error occurred, please try again",
        ));
        die();
    }

    $total_products = mysqli_fetch_assoc($result);


    $monthlyIncome = 0;

    $sql = "select sum(total) as total from orders where status ='completed' and month(created_at) = month(now()) and year(created_at) = year(now())";

    $result = mysqli_query($con, $sql);

    if (!$result) {
        echo json_encode(array(
            "success" => false,
            "message" => "An error occurred, please try again",
        ));
        die();
    }

    $monthlyIncome = mysqli_fetch_assoc($result);

    $sql = "select sum(total) as total from orders where status ='completed'";

    $result = mysqli_query($con, $sql);

    if (!$result) {
        echo json_encode(array(
            "success" => false,
            "message" => "An error occurred, please try again",
        ));
        die();
    }

    $totalIncome = mysqli_fetch_assoc($result);

    echo json_encode(array(
        "success" => true,
        "stats" => array(
            array(
                "title" => "Total Users",
                "value" => $total_users['total_users'],
            ),
            array(
                "title" => "Total Products",
                "value" => $total_products['total_products'],
            ),
            array(
                "title" => "Monthly Income",
                "value" => "Rs. " . $monthlyIncome['total'],
            ),
            array(
                "title" => "Total Income",
                "value" => "Rs. " . $totalIncome['total'],
            ),
        ),
        "message" => "Stats fetched successfully",
    ));
} catch (\Throwable $th) {
    echo json_encode(array(
        "success" => false,
        "message" => $th->getMessage(),
    ));
}
