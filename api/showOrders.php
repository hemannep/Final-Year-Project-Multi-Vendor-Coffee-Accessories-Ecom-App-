<?php
header('Content-Type: application/json');
include './helpers/db.php';

try {
    // Validate required field
    if (!isset($_POST['user_id'])) {
        throw new Exception('user_id is required');
    }

    $user_id = (int)$_POST['user_id'];

    // Get orders with order items and shipping status (if exists)
    $orders_sql = "SELECT 
                    o.order_id, 
                    o.order_status, 
                    o.total_price, 
                    o.created_at,
                    ss.status as shipping_status,
                    GROUP_CONCAT(oi.product_id) AS product_ids,
                    GROUP_CONCAT(oi.quantity) AS quantities,
                    GROUP_CONCAT(oi.price) AS prices,
                    GROUP_CONCAT(p.product_name) AS product_names,
                    GROUP_CONCAT(p.image_url) AS product_images,
                    GROUP_CONCAT(v.vendor_id) AS vendor_ids
                FROM orders o
                LEFT JOIN order_items oi ON o.order_id = oi.order_id
                LEFT JOIN products p ON oi.product_id = p.product_id
                LEFT JOIN vendors v ON p.vendor_id = v.vendor_id
                LEFT JOIN shipping_status ss ON o.order_id = ss.order_id
                WHERE o.user_id = ?
                GROUP BY o.order_id
                ORDER BY o.created_at DESC";
    
    $orders_stmt = mysqli_prepare($con, $orders_sql);
    mysqli_stmt_bind_param($orders_stmt, "i", $user_id);
    mysqli_stmt_execute($orders_stmt);
    $orders_result = mysqli_stmt_get_result($orders_stmt);

    $orders = [];
    while ($order = mysqli_fetch_assoc($orders_result)) {
        // Process order items
        $product_ids = explode(',', $order['product_ids']);
        $quantities = explode(',', $order['quantities']);
        $prices = explode(',', $order['prices']);
        $product_names = explode(',', $order['product_names']);
        $product_images = explode(',', $order['product_images']);
        $vendor_ids = explode(',', $order['vendor_ids']);

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

        // Determine shipping status
        $shipping_status = 'Pending';
        if ($order['order_status'] === 'Cancled' || $order['order_status'] === 'Rejected') {
            $shipping_status = 'Canceled';
        } elseif (!empty($order['shipping_status'])) {
            $shipping_status = $order['shipping_status'];
        }

        $orders[] = [
            'order_id' => (int)$order['order_id'],
            'order_status' => $order['order_status'],
            'shipping_status' => $shipping_status,
            'total_price' => (int)$order['total_price'],
            'created_at' => $order['created_at'],
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
        'message' => $e->getMessage()
    ]);
}
?>