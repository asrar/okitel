import 'package:fiberchat/Screens/auth_screens/login.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Configs/Enum.dart';
import '../Configs/app_constants.dart';
import '../Services/Providers/Observer.dart';
import 'auth_screens/generateID.dart';
import 'auth_screens/loading_button.dart';
import 'auth_screens/loading_button1.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen(
      {Key? key,
      this.title,
      required this.issecutitysetupdone,
      required this.isaccountapprovalbyadminneeded,
      required this.accountApprovalMessage,
      required this.prefs,
      required this.isblocknewlogins})
      : super(key: key);

  final String? title;
  final bool issecutitysetupdone;
  final bool? isblocknewlogins;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(this.context).size.width;
    var h = MediaQuery.of(this.context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[customclippath(w, h), buildCurrentWidget(w)],
          ),
        ],
      )),
    );
  }

  customclippath(w, h) {
    return Stack(children: [
      Image.asset(
        'assets/images/loginImg.png',
        width: double.infinity,
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height,
      ),
      ClipPath(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding:
              EdgeInsets.only(top: MediaQuery.of(this.context).padding.top),
          height: 400,
          child: Column(
            children: <Widget>[
              w < h
                  ? Image.asset(
                      AppLogoPath,
                      width: w / 1.3,
                    )
                  : Image.asset(
                      AppLogoPath,
                      height: h / 1.3,
                    ),
              // SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ]);
  }

  buildCurrentWidget(double w) {
    return Consumer<Observer>(
        builder: (context, observer, _) => Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3.0,
                          color: fiberchatDeepGreen,
                          spreadRadius: 1.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.fromLTRB(15,
                        MediaQuery.of(this.context).size.height / 2.50, 16, 0),
                    child: Column(
                      children: <Widget>[
                        Text('Welcome',
                            style: TextStyle(
                                color: fiberchatLightGreen,
                                fontWeight: FontWeight.bold,
                                fontFamily: FONTFAMILY_NAME,
                                fontSize: 20,
                                height: 3)),
                        Padding(
                          padding: EdgeInsets.fromLTRB(17, 22, 17, 5),
                          child: LoadingButton(
                            text: 'LOGIN',
                            buttoncolor: DESIGN_TYPE == Themetype.whatsapp
                                ? fiberchatLightGreen
                                : fiberchatLightGreen,
                            height: 57,

                            onPressed: () async {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen(
                                            prefs: widget.prefs,
                                            accountApprovalMessage:
                                                widget.accountApprovalMessage,
                                            isaccountapprovalbyadminneeded: widget
                                                .isaccountapprovalbyadminneeded,
                                            isblocknewlogins:
                                                widget.isblocknewlogins,
                                            title: getTranslated(
                                                context, 'signin'),
                                            issecutitysetupdone:
                                                widget.issecutitysetupdone,
                                          )));
                              //await LoginScreen();
                              //loginWithUsernameAndPassword(_usernameController, _passwordController);
                              //return;
                            },
                            // text: 'SIGN IN',
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(17, 22, 17, 5),
                          child: Text('-------------- OR ---------------',
                              style: TextStyle(
                                  height: 1.7,
                                  fontFamily: FONTFAMILY_NAME,
                                  color: fiberchatLightGreen.withOpacity(0.5),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.8)),
                        ),

                        //  SizedBox(height: 50,),
                        Padding(
                          padding: EdgeInsets.fromLTRB(17, 22, 17, 5),
                          child: Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: Text('Create Your ID'),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GenerateId(
                                              prefs: widget.prefs,
                                              accountApprovalMessage:
                                                  widget.accountApprovalMessage,
                                              isaccountapprovalbyadminneeded: widget
                                                  .isaccountapprovalbyadminneeded,
                                              isblocknewlogins:
                                                  widget.isblocknewlogins,
                                              title: getTranslated(
                                                  context, 'signin'),
                                              issecutitysetupdone:
                                                  widget.issecutitysetupdone,
                                            )));
                              },
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  backgroundColor: Color(0xFF009DC8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ));
  }
}
