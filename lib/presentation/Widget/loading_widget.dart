
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidet extends StatelessWidget {
  const LoadingWidet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          )
      ),
      //them phan loadinng cho signin screen
      child: SpinKitPouringHourGlass(
        color: Colors.white,
      ),
    );
  }
}
