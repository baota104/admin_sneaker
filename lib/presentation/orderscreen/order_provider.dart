import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../datasource/model/OrderModel.dart';

enum OrderStatus {
  pending,
  confirmed,
  shipping,
  completed,
  cancelled,
}

class OrderProvider with ChangeNotifier {
  final CollectionReference _orders = FirebaseFirestore.instance.collection('Orders');
  final CollectionReference _products = FirebaseFirestore.instance.collection('Products');

  List<OrderModel> _ordersList = [];
  List<OrderModel> get orders => _ordersList;

  Future<void> loadOrders() async {
    try {
      QuerySnapshot snapshot = await _orders.orderBy('time', descending: true).get();
      List<OrderModel> fetchedOrders = [];

      for (var doc in snapshot.docs) {
        final orderId = doc.id;
        final data = doc.data() as Map<String, dynamic>;

        final orderDetailsSnapshot = await _orders
            .doc(orderId)
            .collection("order_details")
            .get();

        List<OrderDetail> orderDetails = orderDetailsSnapshot.docs.map((itemDoc) {
          return OrderDetail.fromMap(itemDoc.data() as Map<String, dynamic>);
        }).toList();

        final order = OrderModel.fromMap(orderId, data, orderDetails);
        fetchedOrders.add(order);
      }

      _ordersList = fetchedOrders;
      notifyListeners();
    } catch (e) {
      print("Lỗi loadOrders: $e");
      throw Exception("Không thể lấy danh sách đơn hàng");
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      if (newStatus == OrderStatus.shipping) {
        final orderDetailsSnapshot = await _orders
            .doc(orderId)
            .collection('order_details')
            .get();

        for (var itemDoc in orderDetailsSnapshot.docs) {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final String productId = itemData['productId'] ?? '';
          await _products.doc(productId).update({'stock': 0});
        }

        await _orders.doc(orderId).update({
          'status': newStatus.name,
          'updated_at': FieldValue.serverTimestamp(),
        });

        await loadOrders();
        return true;
      }

      if (newStatus == OrderStatus.cancelled) {
        await updateStockWhenCancelled(orderId);

        await _orders.doc(orderId).update({
          'status': newStatus.name,
          'updated_at': FieldValue.serverTimestamp(),
        });

        await loadOrders();
        return true;
      }

      // Các trạng thái khác
      await _orders.doc(orderId).update({
        'status': newStatus.name,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await loadOrders();
      return true;
    } catch (error) {
      print("Lỗi cập nhật trạng thái: $error");
      return false;
    }
  }


  Future<void> deleteOrder(String orderId) async {
    try {
      await _orders.doc(orderId).delete();
      await loadOrders(); // cập nhật UI
    } catch (error) {
      throw Exception("Lỗi xóa đơn hàng: $error");
    }
  }

  OrderStatus parseStatus(String status) {
    return OrderStatus.values.firstWhere(
          (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
  }
  Future<void> updateStockWhenCancelled(String orderId) async {
    try {
      final orderDetailsSnapshot = await _orders
          .doc(orderId)
          .collection('order_details')
          .get();

      for (var itemDoc in orderDetailsSnapshot.docs) {
        final itemData = itemDoc.data() as Map<String, dynamic>;
        final String productId = itemData['productId'] ?? '';
        await _products.doc(productId).update({'stock': 1});
      }
      notifyListeners();
    } catch (error) {
      print("Lỗi cập nhật stock khi hủy đơn hàng: $error");
    }
  }
  Future<void> createOrderNotification({
    required String orderId,
    required String userId,
    required OrderStatus newStatus,
    required String imageUrl,
  }) async {
    try {
      final message = "your order was converted to: ${statusToText(newStatus)}";
      await FirebaseFirestore.instance.collection('Notifications').add({
        'orderId':orderId,
        'user_id': userId,
        'message': message,
        'imageUrl': imageUrl,
        'is_read': false,
        'time': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Lỗi tạo thông báo: $e");
    }
  }

  String statusToText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "pending";
      case OrderStatus.confirmed:
        return "confirmed";
      case OrderStatus.shipping:
        return "shipping";
      case OrderStatus.completed:
        return "completed";
      case OrderStatus.cancelled:
        return "cancelled";
    }
  }

}
