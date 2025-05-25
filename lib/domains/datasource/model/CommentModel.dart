import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String cmtId; // Document ID từ Firestore
  final String userId;
  final String username;
  final String avatarUrl;
  final String content;
  final double rating;
  final bool isVisible;
  final DateTime timestamp;

  CommentModel({
    required this.cmtId,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.content,
    required this.rating,
    required this.isVisible,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'content': content,
      'rating': rating,
      'isvisible': isVisible, // Chú ý: tên trường phải khớp với Firestore
      'timestamp': timestamp,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map, String docId) {
    return CommentModel(
      cmtId: docId,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      content: map['content'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      isVisible: map['isvisible'] ?? true, // Chú ý: tên trường phải khớp
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  CommentModel copyWith({
    String? cmtId,
    String? userId,
    String? username,
    String? avatarUrl,
    String? content,
    double? rating,
    bool? isVisible,
    DateTime? timestamp,
  }) {
    return CommentModel(
      cmtId: cmtId ?? this.cmtId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      isVisible: isVisible ?? this.isVisible,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}