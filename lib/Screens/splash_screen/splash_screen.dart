//*************   © Copyrighted by OkiTel. An Exclusive item of Kostricani. *********************

import 'package:fiberchat/Configs/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Splashscreen extends StatelessWidget {
  final bool? isShowOnlySpinner;

  Splashscreen({this.isShowOnlySpinner = false});
  @override
  Widget build(BuildContext context) {
    return IsSplashOnlySolidColor == true || this.isShowOnlySpinner == true
        ? Scaffold(
            backgroundColor: SplashBackgroundSolidColor,
            body: Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(fiberchatLightGreen)),
            ))
        : Scaffold(
            body: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark,
              child: Center(
                  child: Container(
                      child: Image.asset('assets/images/splash.png',
                          fit: BoxFit.contain))),
            ),
          );
  }
}
