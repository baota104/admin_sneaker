import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domains/datasource/remote/authentication_repository/authentication_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthenticationRepository authenticationRepository;
  LoginCubit({
    required this.authenticationRepository
  }) : super(const LoginState(""));

  Future<void> login(String email,String password)async{
    try{
      print("yeeee sor");
      await authenticationRepository.loginWithEmailAndPassword(
          email: email,
          password: password
      );

    }
    catch(e){

      print(e.toString());
    }
  }
}
