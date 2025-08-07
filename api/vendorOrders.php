<?php
include './helpers/db.php';
header('Content-Type: application/json');

try {
    if (isset($_POST['vendor_id'])) {
        $vendor_id = $_POST['vendor_id'];

        $sql = "SELECT 
                    o.order_id, 
                    o.order_status, 
                    o.user_id, 
                    o.created_at,
                    ss.status as shipping_status,
                    u.email, 
                    u.name,
                    u.phone,
                    p.product_name,
                    p.product_id,
                    oi.quantity,
                    oi.price as item_price,
                    p.image_url,
                    SUM(oi.price * oi.quantity) as vendor_order_total
                FROM orders o
                JOIN order_items oi ON o.order_id = oi.order_id
                JOIN products p ON oi.product_id = p.product_id
                JOIN users u ON o.user_id = u.user_id
                LEFT JOIN shipping_status ss ON o.order_id = ss.order_id
                WHERE p.vendor_id = '$vendor_id'
                GROUP BY o.order_id, o.order_status, o.user_id, o.created_at, ss.status, 
                         u.email, u.name, u.phone, p.product_name, p.product_id, 
                         oi.quantity, oi.price, p.image_url
                ORDER BY o.created_at DESC";

        $result = mysqli_query($con, $sql);

        if (!$result) {
            echo json_encode([
                "success" => false,
                "message" => "Failed to fetch orders: " . mysqli_error($con)
            ]);
            die();
        }

        $orders = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $order_id = $row['order_id'];
            
            if (!isset($orders[$order_id])) {
                $orders[$order_id] = [
                    'order_id' => $order_id,
                    'order_status' => $row['order_status'],
                    'shipping_status' => $row['shipping_status'] ?? 'Pending',
                    'user_id' => $row['user_id'],
                    'created_at' => $row['created_at'],
                    'user_name' => $row['name'],
                    'user_email' => $row['email'],
                    'user_phone' => $row['phone'],
                    'vendor_order_total' => 0,
                    'items' => []
                ];
            }
            
            $item_total = $row['item_price'] * $row['quantity'];
            $orders[$order_id]['vendor_order_total'] += $item_total;
            
            $orders[$order_id]['items'][] = [
                'product_id' => $row['product_id'],
                'product_name' => $row['product_name'],
                'quantity' => $row['quantity'],
                'price' => $row['item_price'],
                'item_total' => $item_total,
                'image_url' => $row['image_url']
            ];
        }

        echo json_encode([
            "success" => true,
            "orders" => array_values($orders),
            "message" => "Orders fetched successfully"
        ]);

    } else {
        echo json_encode([
            "success" => false,
            "message" => "vendor_id is required"
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}
?>