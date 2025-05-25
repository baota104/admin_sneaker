import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? username;
  final String? photo;

  UserEntity({required this.id, this.email, this.username, this.photo});
  static var empty = UserEntity(id: "");

  bool isEmpty(){
    return this == UserEntity.empty;
  }
  bool isnotEmpty(){
    return this != UserEntity.empty;
  }



  @override
  // TODO: implement props
  List<Object?> get props => [
  id,
  email,
  username,
  photo
  ];
}
extension UserFirebaseAuthExtension on User{
  UserEntity get toUserEntity{
    return UserEntity(
        id: uid,
        email: email,
        username: displayName,
        photo: photoURL
    );
  }
}