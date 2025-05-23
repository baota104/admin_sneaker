import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../datasource/model/UserModel.dart';

class CustomerProvider with ChangeNotifier {
  List<UserModel> _customers = [];
  bool _isLoading = false;

  List<UserModel> get customers => _customers;
  bool get isLoading => _isLoading;

  Future<void> fetchCustomers() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .orderBy('createdAt', descending: true)
          .get();

      _customers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> toggleUserStatus(String userId, bool isDisabled) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'isDisabled': isDisabled});

      final index = _customers.indexWhere((user) => user.userId == userId);
      if (index != -1) {
        _customers[index] = _customers[index].copyWith(isDisabled: isDisabled);
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .delete();

      _customers.removeWhere((user) => user.userId == userId);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}