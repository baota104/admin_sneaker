import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../datasource/model/CommentModel.dart';
import '../../datasource/model/NotificationModel.dart';

class CommentProvider with ChangeNotifier {
  List<CommentModel> _comments = [];
  bool _isLoading = false;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;

  Future<void> fetchComments() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('shop_comments')
          .orderBy('timestamp', descending: true)
          .get();

      _comments = snapshot.docs
          .map((doc) {
        // Debug: In ra doc.id và doc.data() để kiểm tra
        print('Document ID: ${doc.id}');
        print('Document data: ${doc.data()}');
        return CommentModel.fromMap(doc.data(), doc.id);
      })
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> toggleCommentVisibility(String commentId, bool isVisible) async {
    try {
      if (commentId.isEmpty) {
        throw Exception("Comment ID cannot be empty");
      }

      // Debug: In ra commentId trước khi thao tác
      print('Attempting to update comment with ID: $commentId');

      // Kiểm tra document có tồn tại không trước khi update
      final doc = await FirebaseFirestore.instance
          .collection('shop_comments')
          .doc(commentId)
          .get();

      if (!doc.exists) {
        throw Exception('Comment with ID $commentId does not exist');
      }

      await FirebaseFirestore.instance
          .collection('shop_comments')
          .doc(commentId)
          .update({'isvisible': isVisible});

      final index = _comments.indexWhere((comment) => comment.cmtId == commentId);
      if (index != -1) {
        _comments[index] = _comments[index].copyWith(isVisible: isVisible);
        notifyListeners();
      }
    } catch (e) {
      print("Error toggling comment visibility: $e");
      // Thêm thông báo lỗi chi tiết hơn
      throw Exception('Failed to toggle visibility: ${e.toString()}');
    }
  }

  Future<void> deleteComment(String commentId, String reason) async {
    try {
      if (commentId.isEmpty) {
        throw Exception("Comment ID cannot be empty");
      }

      // Kiểm tra document có tồn tại không trước khi xóa
      final doc = await FirebaseFirestore.instance
          .collection('shop_comments')
          .doc(commentId)
          .get();

      if (!doc.exists) {
        throw Exception('Comment with ID $commentId does not exist');
      }

      // Lấy thông tin comment trước khi xóa
      final comment = _comments.firstWhere((c) => c.cmtId == commentId);

      // Xóa comment
      await FirebaseFirestore.instance
          .collection('shop_comments')
          .doc(commentId)
          .delete();

      // Tạo thông báo cho người dùng
      await _createViolationNotification(
        userId: comment.userId,
        username: comment.username,
        reason: reason,
      );

      _comments.removeWhere((comment) => comment.cmtId == commentId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete comment: ${e.toString()}');
    }
  }

  Future<void> _createViolationNotification({
    required String userId,
    required String username,
    required String reason,
  }) async {
    try {
      final notification = NotificationModel(
        notificationId: FirebaseFirestore.instance.collection('Notifications').doc().id,
        userId: userId,
        orderId: '', // Có thể để trống hoặc thêm orderId nếu liên quan
        message: 'Bình luận của bạn đã bị xóa do vi phạm chuẩn mực cộng đồng: $reason',
        isRead: false,
        imageUrl: 'https://tse1.mm.bing.net/th?id=OIP.dxSGUhorbUfTF8xv5o_ItwHaGl&pid=Api&P=0&h=220', // URL hình ảnh cảnh báo
        time: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('Notifications')
          .doc(notification.notificationId)
          .set(notification.toMap());
    } catch (e) {
      print('Error creating violation notification: $e');
      // Không throw error ở đây để không ảnh hưởng đến flow xóa comment
    }
  }
}