import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'bloc/login_cubit.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});


  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool isvisibleicon = true;
  var _emailController = TextEditingController();
  var _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
      backgroundColor: Colors.transparent,
      leading:null
      ),
  body: SafeArea(
        child: Container(
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: SingleChildScrollView(
            child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:double.minPositive
            ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    _buildtitleandcontent(),
                    _buildemailfield(),
                    _buildpasswordfield(),
                    _buildsigninbutton(),
                    _buildgoogle(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    )
    );
  }
  Widget _buildtitleandcontent(){
    return Column(
        children: [
          Container(
            width: 187,
            height: 45,
            child: Text("Hello Admin",
              style: TextStyle(
               fontSize: 32,
               fontWeight: FontWeight.bold,
               fontFamily:GoogleFonts.raleway().fontFamily,
              ),
            ),
          ),
          SizedBox(height: 8,),
          Container(
            width: 315,
            height: 48,
            child: Text("Fill your details to manage your system",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF707B81),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily:GoogleFonts.poppins().fontFamily,
              ),
            ),
          )
        ],
    );
  }
  Widget _buildemailfield(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30,horizontal: 20),
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
               Text("Email Address",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily:GoogleFonts.raleway().fontFamily,
                ),
              ),
            TextFormField(
              autofocus: false,
              maxLines: 1,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: Colors.black),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }
                final bool emailValid =
                RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (emailValid) {
                  return null;
                }
                else {
                  return "email is not invalidate";
                }
                return null;
              },
              decoration: InputDecoration(
                fillColor: Color(0xFFF7F7F9).withOpacity(0.5),
                filled: true,
                hintText: "xyz@gmail.com",
                hintStyle: TextStyle(
                  color: Color(0xFF6A6A6A),
                  fontFamily: GoogleFonts.poppins().fontFamily
                ),
                labelStyle: TextStyle(color: Colors.blue),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(width: 1, color: Colors.white)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(width: 1, color: Colors.white)
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(width: 1, color: Colors.white)
                ),
              ),
            ),
          ],
        ),
    );
  }
  Widget _buildpasswordfield(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Password",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily:GoogleFonts.raleway().fontFamily,
            ),
          ),
          TextFormField(
            maxLines: 1,
            controller: _passController,
            obscureText: isvisibleicon,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            style: TextStyle(color: Color(0xFF6A6A6A)),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Password is required";
              }
              if (value.length < 6) {
                return "required more than 6 words";
              }
              return null;
            },
            decoration: InputDecoration(
              suffixIcon: IconButton(onPressed: (){
                setState(() {
                  isvisibleicon = !isvisibleicon;
                });
              }, icon: isvisibleicon ? Icon(CupertinoIcons.eye,color: Color(0xFF6A6A6A),):Icon(CupertinoIcons.eye_slash,color: Color(0xFF6A6A6A))
              ),
              fillColor: Color(0xFFF7F7F9).withOpacity(0.5),
              filled: true,
              hintStyle: TextStyle(
                  color: Color(0xFF6A6A6A),
                  fontFamily: GoogleFonts.poppins().fontFamily
              ),
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(width: 1, color: Colors.white)
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(width: 1, color: Colors.white)
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(width: 1, color: Colors.white)
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              // Navigator.push(context,
              //     MaterialPageRoute(
              //         builder: (context) => Recoveryscreen())
              // );
            },
            child: Container(
              alignment: Alignment.centerRight,
              child: Text("Recovery Password",
              style: TextStyle(
                color: Color(0xFF707B81),
                fontSize: 12,
                fontFamily: GoogleFonts.poppins().fontFamily
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildsigninbutton() {
    return Container(
      height: 48,
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 24),
      width: double.infinity,
      child: ElevatedButton(onPressed: () {
        _onhandleloginsubmit();
      }, style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF0D6EFD),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)
          )
      ), child: Text("Login",
        style: TextStyle(color: Colors.white,
        ),
      )),
    );
  }
  Widget _buildgoogle(){
    return Container(
      height: 48,
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 24),
      width: double.infinity,
      child: ElevatedButton(onPressed: () {
        // _onhandleloginsubmitgoogle();
      }, style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xF7F7F9).withOpacity(0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)
          ),

      ), child: Row(
     //   crossAxisAlignment: CrossAxisAlignment.center,\
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset("assets/image/img.png",
            width: 22,
            height: 22,
          ),
          SizedBox(width: 12,),
          Text("Sign In with Google ",
            style: TextStyle(color: Colors.black,
              fontFamily: GoogleFonts.raleway().fontFamily,
              fontSize: 14
            ),
          ),
        ],
      )),
    );
  }
  Widget _buildtextregister(){
    return Container(
      margin: EdgeInsets.only(top: 70),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("New User?",
            style: TextStyle(
              color: Color(0xFF6A6A6A),
              fontFamily: GoogleFonts.raleway().fontFamily,
              fontSize: 16,
            ),
          ),
          InkWell(
            onTap: () {
              //Navigator.pushNamed(context, "/register");
              // Navigator.push(context,
              //     MaterialPageRoute(
              //         builder: (context) => Registerscreen())
              // );
              // print("hello uc");
            },
            child: Text("Create Account",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: GoogleFonts.raleway().fontFamily,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _onhandleloginsubmit () async {
    if (!_formKey.currentState!.validate()) {
      return; // Nếu form không hợp lệ, không làm gì cả
    }
    final logincubit = context.read<LoginCubit>();
    var email = _emailController.text;
    var password = _passController.text;
    try{
       await logincubit.login(email, password);
    }
    catch(e){
      print(e.toString());
    }
    return;
  }


}
