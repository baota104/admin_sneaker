import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String notificationId;
  String userId;
  String orderId;
  String message;
  bool isRead;
  String imageUrl;
  DateTime time;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.orderId,
    required this.message,
    required this.isRead,
    required this.imageUrl,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      "notification_id": notificationId,
      "user_id": userId,
      "orderId":orderId,
      "message": message,
      "is_read": isRead,
      "imageUrl":imageUrl,
      "time": time.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    final rawTime = map["time"];
    final parsedTime = rawTime is Timestamp
        ? rawTime.toDate()
        : (rawTime is String ? DateTime.tryParse(rawTime) ?? DateTime.now() : DateTime.now());

    return NotificationModel(
      notificationId: map["notificationId"] ?? '',
      userId: map["user_id"] ?? '',
      orderId: map["orderId"] ?? '',
      message: map["message"] ?? '',
      isRead: map["is_read"] ?? false,
      imageUrl: map["imageUrl"] ?? '',
      time: parsedTime,
    );
  }

}
