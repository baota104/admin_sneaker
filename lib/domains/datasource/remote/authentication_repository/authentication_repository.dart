


import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../presentation/ultilenum/AuthenticationStatus.dart';
import '../../../Controller/firebase_auth_service.dart';
import 'entities/user_entity.dart';

abstract class AuthenticationRepository{
  //muon cac class khac truy cap
  Stream<AuthenticationStatus> get status;
  Stream<UserEntity> get user;
  // thi lam nhu sau
  Future<void> loginWithGoogle();
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password
});
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name
  });
  Future<void> sendPasswordResetEmail(String email);



}

class AuthenticationRepositoryImpl extends AuthenticationRepository{
  final FirebaseAuthService firebaseAuthService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _statuscontroller = StreamController<AuthenticationStatus>();// de xac dinh da login hay chuaw
  final _usercontroller = StreamController<UserEntity>();
  AuthenticationRepositoryImpl({
  required this.firebaseAuthService
  }){
    firebaseAuthService.user.listen((firebaseuser){
      final isLoggeedIn = firebaseuser != null;
      // bien doi tu firebaseuser thanh UserEntity
      final user = isLoggeedIn ? firebaseuser.toUserEntity : UserEntity.empty;

      _usercontroller.sink.add(user);
      if(isLoggeedIn){
        _statuscontroller.sink.add(AuthenticationStatus.authenticated);
      }
      else {
        _statuscontroller.sink.add(AuthenticationStatus.unauthenticated);
      }
    });
  }


  @override
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,

  }) async{
    try{
      final userCredential = await firebaseAuthService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        print("User ID: ${userCredential.user!.uid}");
        // Lưu UID vào SharedPreferences
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('uid',userCredential.user!.uid);
        print("Lưu UID vào SharedPreferences thành công!");
      }
      else{
        print("khong luu dược rồi em ạ");
      }
    }
    catch(e){
      print(e.toString());
    }
  }

  @override
  Stream<AuthenticationStatus> get status async* { // Sửa kiểu trả về thành Stream<AuthenticationStatus>
    yield AuthenticationStatus.unauthenticated; //
    yield* _statuscontroller.stream;
  }

  @override
  Stream<UserEntity> get user async* { // Sửa kiểu trả về thành Stream<UserEntity>
    yield* _usercontroller.stream;
  }

  @override
  Future<void> registerWithEmailAndPassword({

    required String email,
    required String password,
    required String name
  }) async {
    try {
      final user = await firebaseAuthService.registerWithEmailAndPassword(email: email, password: password,name: name);
      if(user!= null){
        print("Đăng ký thành công. Tiến hành đăng xuất...");
        await FirebaseAuth.instance.signOut(); //
      }
    } catch (e) {
      print("Error registering user: $e");
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    try {
      // final user = await firebaseAuthService.signInWithGoogle();
      // if (user != null) {
      //   // SharedPreferences prefs = await SharedPreferences.getInstance();
      //   // await prefs.setString('uid', user.uid);
      //   print("Google UID saved!");
      // }
    } catch (e) {
      print("Google Login Error: $e");
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try{
      await firebaseAuthService.sendPasswordResetEmail(email);
    }
    catch(e){
      print(e.toString());
    }
  }

  }


