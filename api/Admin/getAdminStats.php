<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    // Total Users
    $usersQuery = "SELECT COUNT(*) as total FROM users";
    $usersResult = mysqli_query($con, $usersQuery);
    $totalUsers = mysqli_fetch_assoc($usersResult)['total'];

    // Total Vendors
    $vendorsQuery = "SELECT COUNT(*) as total FROM vendors";
    $vendorsResult = mysqli_query($con, $vendorsQuery);
    $totalVendors = mysqli_fetch_assoc($vendorsResult)['total'];

    // Monthly Orders
    $monthlyOrdersQuery = "SELECT COUNT(*) as total FROM orders 
                          WHERE MONTH(created_at) = MONTH(CURRENT_DATE()) 
                          AND YEAR(created_at) = YEAR(CURRENT_DATE())";
    $monthlyOrdersResult = mysqli_query($con, $monthlyOrdersQuery);
    $monthlyOrders = mysqli_fetch_assoc($monthlyOrdersResult)['total'];

    // Monthly Revenue
    $monthlyRevenueQuery = "SELECT SUM(total_price) as total FROM orders 
                           WHERE MONTH(created_at) = MONTH(CURRENT_DATE()) 
                           AND YEAR(created_at) = YEAR(CURRENT_DATE())
                           AND order_status IN ('Online Paid', 'Cash Paid')";
    $monthlyRevenueResult = mysqli_query($con, $monthlyRevenueQuery);
    $monthlyRevenue = mysqli_fetch_assoc($monthlyRevenueResult)['total'] ?? 0;

    // Lifetime Orders
    $lifetimeOrdersQuery = "SELECT COUNT(*) as total FROM orders";
    $lifetimeOrdersResult = mysqli_query($con, $lifetimeOrdersQuery);
    $lifetimeOrders = mysqli_fetch_assoc($lifetimeOrdersResult)['total'];

    // Lifetime Revenue
    $lifetimeRevenueQuery = "SELECT SUM(total_price) as total FROM orders 
                            WHERE order_status IN ('Online Paid', 'Cash Paid')";
    $lifetimeRevenueResult = mysqli_query($con, $lifetimeRevenueQuery);
    $lifetimeRevenue = mysqli_fetch_assoc($lifetimeRevenueResult)['total'] ?? 0;

    // Calculate changes (example: compare with previous month)
    $prevMonthOrdersQuery = "SELECT COUNT(*) as total FROM orders 
                            WHERE MONTH(created_at) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)) 
                            AND YEAR(created_at) = YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))";
    $prevMonthOrdersResult = mysqli_query($con, $prevMonthOrdersQuery);
    $prevMonthOrders = mysqli_fetch_assoc($prevMonthOrdersResult)['total'];
    $ordersChange = $prevMonthOrders > 0 ? 
        round((($monthlyOrders - $prevMonthOrders) / $prevMonthOrders) * 100) : 0;

    $prevMonthRevenueQuery = "SELECT SUM(total_price) as total FROM orders 
                             WHERE MONTH(created_at) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)) 
                             AND YEAR(created_at) = YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
                             AND order_status IN ('Online Paid', 'Cash Paid')";
    $prevMonthRevenueResult = mysqli_query($con, $prevMonthRevenueQuery);
    $prevMonthRevenue = mysqli_fetch_assoc($prevMonthRevenueResult)['total'] ?? 0;
    $revenueChange = $prevMonthRevenue > 0 ? 
        round((($monthlyRevenue - $prevMonthRevenue) / $prevMonthRevenue) * 100) : 0;

    echo json_encode([
        "success" => true,
        "stats" => [
            [
                "title" => "Total Users",
                "value" => $totalUsers,
                "change" => null,
                "subtitle" => "Registered users"
            ],
            [
                "title" => "Total Vendors",
                "value" => $totalVendors,
                "change" => null,
                "subtitle" => "Active vendors"
            ],
            [
                "title" => "Monthly Orders",
                "value" => $monthlyOrders,
                "change" => $ordersChange,
                "subtitle" => "This month"
            ],
            [
                "title" => "Monthly Revenue",
                "value" => $monthlyRevenue,
                "change" => $revenueChange,
                "subtitle" => "This month"
            ],
            [
                "title" => "Lifetime Orders",
                "value" => $lifetimeOrders,
                "change" => null,
                "subtitle" => "All time"
            ],
            [
                "title" => "Lifetime Revenue",
                "value" => $lifetimeRevenue,
                "change" => null,
                "subtitle" => "All time"
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
?>