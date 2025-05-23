class UserModel {
  final String userId;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String address;
  final String imageUrl;
  final DateTime createdAt;
  final bool isDisabled;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.imageUrl,
    required this.createdAt,
    this.isDisabled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": userId,
      "name": name,
      "email": email,
      "password": password,
      "phone": phone,
      "address": address,
      "imageUrl": imageUrl,
      "created_at": createdAt.toIso8601String(),
      "isDisabled": isDisabled,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map["uid"] ?? '',
      name: map["name"] ?? '',
      email: map["email"] ?? '',
      password: map["password"] ?? '',
      phone: map["phone"] ?? '',
      address: map["address"] ?? '',
      imageUrl: map["imageUrl"] ?? '',
      createdAt: map["created_at"] != null
          ? DateTime.parse(map["created_at"])
          : DateTime.now(),
      isDisabled: map["isDisabled"] ?? false,
    );
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? address,
    String? imageUrl,
    DateTime? createdAt,
    bool? isDisabled,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }
}