import 'package:fiberchat/Screens/auth_screens/register.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Configs/app_constants.dart';

class GenerateId extends StatefulWidget {
  GenerateId(
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
  State<GenerateId> createState() => _GenerateIdState();
}

class _GenerateIdState extends State<GenerateId> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(this.context).size.width;
    var h = MediaQuery.of(this.context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme:
            Theme.of(context).primaryIconTheme.copyWith(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/loginImg.png',
                  width: double.infinity,
                  fit: MediaQuery.of(context).size.height >
                          MediaQuery.of(context).size.width
                      ? BoxFit.cover
                      : BoxFit.fitHeight,
                  height: MediaQuery.of(context).size.height,
                ),
                ClipPath(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    // padding: EdgeInsets.only(top: MediaQuery.of(this.context).padding.top),
                    // height: 400,
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
                      ],
                    ),
                  ),
                ),

                /* BackButton(
                  color: Colors.black,
                  onPressed: (){
                  },),*/

                Image.asset(
                  'assets/images/regImg.png',
                  width: double.infinity,
                  // fit: MediaQuery.of(context).size.height > MediaQuery.of(context).size.width ? BoxFit.cover : BoxFit.fitHeight,
                  height: 1000,
                ),

                Positioned(
                  top: 450,
                  left: 50,
                  child: Padding(
                    padding: EdgeInsets.all(17),
                    child: Container(
                      width: 280,
                      child: ElevatedButton(
                        child: Text('GENERATE UNIQUE ID'),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Register(
                                        prefs: widget.prefs,
                                        accountApprovalMessage:
                                            widget.accountApprovalMessage,
                                        isaccountapprovalbyadminneeded: widget
                                            .isaccountapprovalbyadminneeded,
                                        isblocknewlogins:
                                            widget.isblocknewlogins,
                                        title: getTranslated(context, 'signin'),
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
                ), //
              ],
            ),
          ],
        ),
      ),
    );
  }
}
