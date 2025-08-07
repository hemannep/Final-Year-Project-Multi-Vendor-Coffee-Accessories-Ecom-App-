// models/vendor.dart

class Vendor {
  final String vendorId;
  final String? userId;
  final String? storeName;
  final String? storeDescription;
  final String? address;
  final String? name;
  final String? email;
  final String? phone;
  final String? status; 

  Vendor({
    required this.vendorId,
    this.userId,
    this.storeName,
    this.storeDescription,
    this.address,
    this.name,
    this.email,
    this.phone,
    this.status
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      vendorId: json['vendor_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      storeName: json['store_name']?.toString(),
      storeDescription: json['store_description']?.toString(),
      address: json['address']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'user_id': userId,
      'store_name': storeName,
      'store_description': storeDescription,
      'address': address,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  Vendor copyWith({
    String? vendorId,
    String? userId,
    String? storeName,
    String? storeDescription,
    String? address,
    String? name,
    String? email,
    String? phone,
  }) {
    return Vendor(
      vendorId: vendorId ?? this.vendorId,
      userId: userId ?? this.userId,
      storeName: storeName ?? this.storeName,
      storeDescription: storeDescription ?? this.storeDescription,
      address: address ?? this.address,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}