import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardProvider extends ChangeNotifier {
  double totalRevenue = 0;
  Map<String, double> brandRevenue = {};

  Future<void> fetchDataByRange(DateTime start, DateTime end) async {
    totalRevenue = 0;
    brandRevenue.clear();

    try {
      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection("Orders")
          .where("status", isEqualTo: "completed")
          .where("time", isGreaterThanOrEqualTo: start)
          .where("time", isLessThanOrEqualTo: end)
          .get();

      for (var doc in ordersSnapshot.docs) {
        var orderDetailsSnapshot = await doc.reference.collection("order_details").get();

        for (var detailDoc in orderDetailsSnapshot.docs) {
          var detail = detailDoc.data();
          String name = (detail['name'] ?? '').toString();
          double price = (detail['price'] ?? 0).toDouble();
          double discount = (detail['discountprice'] ?? 0).toDouble();
          double finalPrice = discount > 0 ? discount : price;

          String brand = _detectBrandFromName(name);

          totalRevenue += finalPrice;
          brandRevenue.update(brand, (v) => v + finalPrice, ifAbsent: () => finalPrice);
        }
      }

      notifyListeners();
    } catch (e) {
      print("Error loading data: $e");
    }
  }


  String _detectBrandFromName(String name) {
    name = name.toLowerCase();
    if (name.contains('jordan')) return 'Jordan';
    if (name.contains('adidas')) return 'Adidas';
    if (name.contains('new balance')) return 'New Balance';
    if (name.contains('converse')) return 'Converse';
    if (name.contains('nike')) return 'Nike';
    if (name.contains('puma')) return 'Puma';
    return 'Other';
  }
}
