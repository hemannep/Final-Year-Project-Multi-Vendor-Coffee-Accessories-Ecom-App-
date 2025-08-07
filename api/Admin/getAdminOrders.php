<?php
include '../helpers/db.php';
header('Content-Type: application/json');

try {
    $sql = "SELECT 
                o.order_id, 
                o.user_id,
                o.order_status, 
                o.total_price, 
                o.created_at,
                ss.status as shipping_status,
                u.name as user_name,
                u.phone as user_phone,
                u.email as user_email,
                GROUP_CONCAT(oi.product_id) AS product_ids,
                GROUP_CONCAT(oi.quantity) AS quantities,
                GROUP_CONCAT(oi.price) AS prices,
                GROUP_CONCAT(p.product_name) AS product_names,
                GROUP_CONCAT(p.image_url) AS product_images,
                GROUP_CONCAT(p.vendor_id) AS vendor_ids
            FROM orders o
            LEFT JOIN order_items oi ON o.order_id = oi.order_id
            LEFT JOIN products p ON oi.product_id = p.product_id
            LEFT JOIN shipping_status ss ON o.order_id = ss.order_id
            LEFT JOIN users u ON o.user_id = u.user_id
            GROUP BY o.order_id
            ORDER BY o.created_at DESC";

    $result = mysqli_query($con, $sql);
    $orders = [];

    while ($row = mysqli_fetch_assoc($result)) {
        $product_ids = explode(',', $row['product_ids']);
        $quantities = explode(',', $row['quantities']);
        $prices = explode(',', $row['prices']);
        $product_names = explode(',', $row['product_names']);
        $product_images = explode(',', $row['product_images']);
        $vendor_ids = explode(',', $row['vendor_ids']);

        $items = [];
        for ($i = 0; $i < count($product_ids); $i++) {
            if (empty($product_ids[$i])) continue;
            
            $items[] = [
                'product_id' => (int)$product_ids[$i],
                'quantity' => (int)$quantities[$i],
                'price' => (int)$prices[$i],
                'product_name' => $product_names[$i],
                'image_url' => $product_images[$i],
                'vendor_id' => (int)$vendor_ids[$i]
            ];
        }

        $orders[] = [
            'order_id' => (int)$row['order_id'],
            'user_id' => (int)$row['user_id'],
            'user_name' => $row['user_name'],
            'user_phone' => $row['user_phone'],
            'user_email' => $row['user_email'],
            'order_status' => $row['order_status'],
            'shipping_status' => $row['shipping_status'] ?? 'Pending',
            'total_price' => (int)$row['total_price'],
            'created_at' => $row['created_at'],
            'items' => $items
        ];
    }

    echo json_encode([
        'success' => true,
        'orders' => $orders,
        'message' => 'Orders fetched successfully'
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
?>