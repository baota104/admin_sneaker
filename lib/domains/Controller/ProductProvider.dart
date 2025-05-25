import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../datasource/model/ProductModel.dart';


class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ProductModel> _products = [];

  List<ProductModel> get products => _products;

  Future<void> fetchProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("Products").get();


      if (snapshot.docs.isEmpty) {
      }

      _products = snapshot.docs.map((doc) {

        return ProductModel.fromMap({
          "product_id": doc.id, // Lấy ID của document
          ...doc.data() as Map<String, dynamic>, // Lấy dữ liệu còn lại
        });
      }).toList();

      notifyListeners();
      print(" Dữ liệu sản phẩm đã tải về: ${_products.length} sản phẩm");
    } catch (e) {
      print(" Lỗi khi lấy dữ liệu từ Firestore: $e");
    }
  }



  ///  Thêm sản phẩm vào Firestore
  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection('Products').doc(product.productId).set(product.toMap());
      _products.add(product);
      notifyListeners();
    } catch (e) {
      print("Lỗi khi thêm sản phẩm: $e");
    }
  }

  ///  Cập nhật sản phẩm
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection('Products').doc(product.productId).update(product.toMap());
      int index = _products.indexWhere((p) => p.productId == product.productId);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi khi cập nhật sản phẩm: $e");
    }
  }

  ///  Xóa sản phẩm
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('Products').doc(productId).delete();
      _products.removeWhere((p) => p.productId == productId);
      notifyListeners();
    } catch (e) {
      print("Lỗi khi xóa sản phẩm: $e");
    }
  }
}
