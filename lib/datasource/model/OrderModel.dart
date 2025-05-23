

import 'package:cloud_firestore/cloud_firestore.dart';



class OrderModel{
  String orderId;
  String userId;
  String status;
  double totalAmount;
  List<OrderDetail> orderDetails;
  DateTime time;
  String address;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.orderDetails,
    required this.time,
    required this.address
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map, List<OrderDetail> details) {
    return OrderModel(
      orderId: id,
      userId: map['user_id'] ?? '',
      status: map['status'] ?? '',
      totalAmount: (map['total_amout'] ?? 0).toDouble(),
      time: (map['time'] as Timestamp).toDate(),
      address: map['address'] ?? '',
      orderDetails: details,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'status': status,
      'total_amout': totalAmount,
      'time': Timestamp.fromDate(time),
      'address': address,
    };
  }
}
class OrderDetail {
  String productId;
  String name;
  String imageUrl;
  double price;
  double discountPrice;

  OrderDetail({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.discountPrice,
  });

  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: (map['discountprice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'discountprice': discountPrice,
    };
  }
}
