class OrderResponse {
  final bool? success;
  final List<Order>? orders;
  final String? message;

  OrderResponse({
    this.success,
    this.orders,
    this.message,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
        success: json["success"],
        orders: json["orders"] == null
            ? []
            : List<Order>.from(json["orders"]!.map((x) => Order.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "orders": orders == null
            ? []
            : List<dynamic>.from(orders!.map((x) => x.toJson())),
        "message": message,
      };
}

class Order {
  final int? orderId;
  final int? userId;
  final String? userName;
  final String? userPhone;
  final String? userEmail;
  final String? orderStatus;
  final String? shippingStatus;
  final int? totalPrice;
  final DateTime? createdAt;
  final List<Item>? items;

  Order({
    this.orderId,
    this.userId,
    this.userName,
    this.userPhone,
    this.userEmail,
    this.orderStatus,
    this.shippingStatus,
    this.totalPrice,
    this.createdAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: int.tryParse(json["order_id"].toString()) ?? 0,
        userId: int.tryParse(json["user_id"].toString()),
        userName: json["user_name"],
        userPhone: json["user_phone"],
        userEmail: json["user_email"],
        orderStatus: json["order_status"],
        shippingStatus: json["shipping_status"] ?? 'Pending',
        totalPrice: int.tryParse(json["total_price"].toString()) ?? 0,
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        items: json["items"] == null
            ? []
            : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "user_id": userId,
        "user_name": userName,
        "user_phone": userPhone,
        "user_email": userEmail,
        "order_status": orderStatus,
        "shipping_status": shippingStatus,
        "total_price": totalPrice,
        "created_at": createdAt?.toIso8601String(),
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class Item {
  final int? productId;
  final int? quantity;
  final int? price;
  final String? productName;
  final String? imageUrl;
  final int? vendorId;

  Item({
    this.productId,
    this.quantity,
    this.price,
    this.productName,
    this.imageUrl,
    this.vendorId,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        productId: int.tryParse(json["product_id"].toString()) ?? 0,
        quantity: int.tryParse(json["quantity"].toString()) ?? 0,
        price: int.tryParse(json["price"].toString()) ?? 0,
        productName: json["product_name"],
        imageUrl: json["image_url"],
        vendorId: int.tryParse(json["vendor_id"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "quantity": quantity,
        "price": price,
        "product_name": productName,
        "image_url": imageUrl,
        "vendor_id": vendorId,
      };
}