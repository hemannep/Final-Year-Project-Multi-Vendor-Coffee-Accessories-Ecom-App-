<?php
include './helpers/db.php';
header('Content-Type: application/json');

try {
    if (!isset($_POST['vendor_id'])) {
        echo json_encode([
            "success" => false,
            "message" => "Vendor ID is required"
        ]);
        die();
    }

    $vendorId = $_POST['vendor_id'];

    // Get total products for this vendor
    $productsQuery = "SELECT COUNT(*) AS total_products FROM products WHERE vendor_id = ?";
    $stmt = mysqli_prepare($con, $productsQuery);
    mysqli_stmt_bind_param($stmt, "i", $vendorId);
    mysqli_stmt_execute($stmt);
    $productsResult = mysqli_stmt_get_result($stmt);
    $totalProducts = mysqli_fetch_assoc($productsResult)['total_products'] ?? 0;

    // Get monthly income for this vendor
    $monthlyIncomeQuery = "SELECT SUM(oi.price * oi.quantity) AS monthly_income 
                          FROM order_items oi
                          JOIN products p ON oi.product_id = p.product_id
                          JOIN orders o ON oi.order_id = o.order_id
                          WHERE p.vendor_id = ? 
                          AND o.order_status IN ('Online Paid', 'Cash Paid')
                          AND MONTH(o.created_at) = MONTH(CURRENT_DATE())";
    $stmt = mysqli_prepare($con, $monthlyIncomeQuery);
    mysqli_stmt_bind_param($stmt, "i", $vendorId);
    mysqli_stmt_execute($stmt);
    $monthlyResult = mysqli_stmt_get_result($stmt);
    $monthlyIncome = mysqli_fetch_assoc($monthlyResult)['monthly_income'] ?? 0;

    // Get total income for this vendor
    $totalIncomeQuery = "SELECT SUM(oi.price * oi.quantity) AS total_income 
                        FROM order_items oi
                        JOIN products p ON oi.product_id = p.product_id
                        JOIN orders o ON oi.order_id = o.order_id
                        WHERE p.vendor_id = ? 
                        AND o.order_status IN ('Online Paid','Cash Paid')";
    $stmt = mysqli_prepare($con, $totalIncomeQuery);
    mysqli_stmt_bind_param($stmt, "i", $vendorId);
    mysqli_stmt_execute($stmt);
    $totalResult = mysqli_stmt_get_result($stmt);
    $totalIncome = mysqli_fetch_assoc($totalResult)['total_income'] ?? 0;

    // Get pending orders count
    $pendingOrdersQuery = "SELECT COUNT(DISTINCT oi.order_id) AS pending_orders
                          FROM order_items oi
                          JOIN products p ON oi.product_id = p.product_id
                          JOIN orders o ON oi.order_id = o.order_id
                          WHERE p.vendor_id = ? 
                          AND o.order_status IN ('Processing', 'COD')";
    $stmt = mysqli_prepare($con, $pendingOrdersQuery);
    mysqli_stmt_bind_param($stmt, "i", $vendorId);
    mysqli_stmt_execute($stmt);
    $pendingResult = mysqli_stmt_get_result($stmt);
    $pendingOrders = mysqli_fetch_assoc($pendingResult)['pending_orders'] ?? 0;

    echo json_encode([
        "success" => true,
        "stats" => [
            [
                "title" => "Total Products",
                "value" => (string)$totalProducts
            ],
            [
                "title" => "Monthly Income",
                "value" => "Rs. " . number_format($monthlyIncome)
            ],
            [
                "title" => "Total Income",
                "value" => "Rs. " . number_format($totalIncome)
            ],
            [
                "title" => "Pending Orders",
                "value" => (string)$pendingOrders
            ]
        ],
        "message" => "Stats fetched successfully"
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}