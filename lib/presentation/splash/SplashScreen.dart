import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  // Future<void> _checkAppstate(BuildContext context) async{
  //   final check = await _isonboardingcompleted();
  //     if(check){
  //       // di chuyen den login
  //       if(!context.mounted){
  //         return;
  //         // neu context van con ton tai thi moi chay xuong lenh o duoi
  //       }
  //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Loginscreen(isFirstTimeInstallApp: false,)));
  //     }
  //     else{
  //       // if(!context.mounted)return;
  //       // Navigator.pushReplacement(context,
  //       // MaterialPageRoute(builder: (context) => OnboardingPageView())
  //       // );
  //     }
  // }
  // Future<bool> _isonboardingcompleted() async{
  //   try{
  //     final SharedPreferences pref = await SharedPreferences.getInstance();
  //     final result = pref.getBool("kOnboardingCompleted");
  //     return result ?? false;
  //   }
  //   catch(e){
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // _checkAppstate(context);
    return Scaffold(
      body: Container(
          color: Color(0xFF0D6EFD),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: Lottie.asset(
                    'assets/animations/sneaker.json',
                    animate: true,
                    repeat: true,
                    onLoaded: (complete){
                      Future.delayed(Duration(seconds: 2),() async{
                        // String? token = await SharePre.instance.get(AppConstant.accessToken);
                        // print(token);
                        // SharePre.instance.clearPref();
                        // if(token != null && token.isNotEmpty){
                        //   Navigator.pushReplacementNamed(context, "/home");
                        // }else{
                        //   Navigator.pushReplacementNamed(context, "/sign-in");
                        // }
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, "/home");
                        }

                      });
                    }
                ),
              ),
              Text("2SNEAKER",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white,

                  ))
            ],
          )
      ),
    );
  }
}
