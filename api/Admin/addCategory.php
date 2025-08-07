<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    if (!isset($_POST['category_title'])) {
        throw new Exception('Category title is required');
    }

    $title = mysqli_real_escape_string($con, $_POST['category_title']);
    $description = isset($_POST['category_description']) 
        ? mysqli_real_escape_string($con, $_POST['category_description']) 
        : '';

    $sql = "INSERT INTO categories (category_title, category_description) VALUES (?, ?)";
    $stmt = mysqli_prepare($con, $sql);
    mysqli_stmt_bind_param($stmt, "ss", $title, $description);
    mysqli_stmt_execute($stmt);

    if (mysqli_stmt_affected_rows($stmt)) {
        echo json_encode([
            "success" => true,
            "message" => "Category added successfully"
        ]);
    } else {
        throw new Exception('Failed to add category');
    }

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>