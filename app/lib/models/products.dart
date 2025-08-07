import 'dart:convert';

// Add this at the top of product.dart after the imports
ProductResponse productResponseFromJson(String str) => 
    ProductResponse.fromJson(json.decode(str));

class ProductResponse {
  final bool? success;
  final List<Product>? products;
  final String? message;

  ProductResponse({
    this.success,
    this.products,
    this.message,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) => ProductResponse(
        success: json["success"],
        products: json["products"] == null
            ? []
            : List<Product>.from(
                json["products"]!.map((x) => Product.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "message": message,
      };
}

class Product {
  final String? product_id;
  final String? vendor_id;
  final String? productName;
  final String? productDescription;
  final String? price;
  final String? stock;
  final String? categoryId;
  final String? imageUrl;
  final DateTime? createdAt;
  final String? onlineStatus;
  final String? categoryTitle;
  final String? categoryDescription;

  Product({
    this.product_id,
    this.vendor_id,
    this.productName,
    this.productDescription,
    this.price,
    this.stock,
    this.categoryId,
    this.imageUrl,
    this.createdAt,
    this.onlineStatus,
    this.categoryTitle,
    this.categoryDescription,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        product_id: json["product_id"]?.toString(),
        vendor_id: json["vendor_id"]?.toString(),
        productName: json["product_name"]?.toString(),
        productDescription: json["product_description"]?.toString(),
        price: json["price"]?.toString(),
        stock: json["stock"]?.toString(),
        categoryId: json["category_id"]?.toString(),
        imageUrl: json["image_url"]?.toString(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        onlineStatus: json["Online"]?.toString(),
        categoryTitle: json["category_title"]?.toString(),
        categoryDescription: json["category_description"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "product_id": product_id,
        "vendor_id": vendor_id,
        "product_name": productName,
        "product_description": productDescription,
        "price": price,
        "stock": stock,
        "category_id": categoryId,
        "image_url": imageUrl,
        "created_at": createdAt?.toIso8601String(),
        "Online": onlineStatus,
        "category_title": categoryTitle,
        "category_description": categoryDescription,
      };

  // Helper methods
  double? get priceAsDouble => double.tryParse(price ?? '');
  int? get stockAsInt => int.tryParse(stock ?? '');
  bool get isOnline => onlineStatus?.toLowerCase() == 'public';

  Product copyWith({
    String? product_id,
    String? vendor_id,
    String? productName,
    String? productDescription,
    String? price,
    String? stock,
    String? categoryId,
    String? imageUrl,
    DateTime? createdAt,
    String? onlineStatus,
    String? categoryTitle,
    String? categoryDescription,
  }) {
    return Product(
      product_id: product_id ?? this.product_id,
      vendor_id: vendor_id ?? this.vendor_id,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      categoryDescription: categoryDescription ?? this.categoryDescription,
    );
  }
}