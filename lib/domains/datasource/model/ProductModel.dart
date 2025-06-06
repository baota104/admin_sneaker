class ProductModel {
  String productId;
  String name;
  String brand;
  double price;
  double? discountPrice;
  int stock;
  String activity;
  String description;
  int status;
  List<String> imageUrls; // Đổi từ String sang List<String>
  bool isloved;
  int size;

  ProductModel({
    required this.productId,
    required this.name,
    required this.brand,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.activity,
    required this.description,
    required this.status,
    required this.imageUrls, // cập nhật ở đây
    required this.isloved,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      "product_id": productId,
      "name": name,
      "brand": brand,
      "price": price,
      "discountPrice": discountPrice,
      "stock": stock,
      "activity": activity,
      "description": description,
      "status": status,
      "imageUrl": imageUrls, // cập nhật ở đây
      "isloved": isloved,
      "size": size,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map["product_id"] ?? "",
      name: map["name"] ?? "Không có tên",
      brand: map["brand"] ?? "Không rõ thương hiệu",
      price: (map["price"] ?? 0).toDouble(),
      discountPrice: map["discountPrice"] != null
          ? (map["discountPrice"] as num).toDouble()
          : null,
      stock: map["stock"] ?? 0,
      activity: map["activity"] ?? "",
      description: map["description"] ?? "",
      status: (map["status"] ?? 0).toInt(),

      imageUrls: (map["imageUrl"] is List)
          ? (map["imageUrl"] as List)
          .where((item) => item is String)
          .map((item) => item as String)
          .toList()
          : [],

      isloved: map["isloved"] ?? false,
      size: (map["size"] ?? 0).toInt(),
    );
  }




}
