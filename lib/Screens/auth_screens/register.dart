//*************   © Copyrighted by OkiTel. An Exclusive item of Kostricani. *********************

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:device_info/device_info.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/optional_constants.dart';
import 'package:fiberchat/Screens/auth_screens/loading_button1.dart';
import 'package:fiberchat/Screens/homepage/homepage.dart';
import 'package:fiberchat/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/Providers/TimerProvider.dart';
import 'package:fiberchat/Utils/custom_url_launcher.dart';
import 'package:fiberchat/Utils/phonenumberVariantsGenerator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Services/localization/language.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiberchat/Models/E2EE/e2ee.dart' as e2ee;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Utils/unawaited.dart';

class Register extends StatefulWidget {
  Register(
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
  RegisterState createState() => new RegisterState();
}

class RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String _code = "";
  final _phoneNo = TextEditingController();
  int currentStatus = 0;
  final _name = TextEditingController();

  bool _obscureText = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _retypePasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? phoneCode = DEFAULT_COUNTTRYCODE_NUMBER;
  final storage = new FlutterSecureStorage();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  int attempt = 1;
  String? verificationId;
  bool isShowCompletedLoading = false;
  bool isVerifyingCode = false;
  bool isCodeSent = false;
  dynamic isLoggedIn = false;
  User? currentUser;
  String? deviceid;
  var mapDeviceInfo = {};
  bool isChecked = false;

  @override
  void initState() {
    super.initState();

    //For Testing only

    _generateId();

    setdeviceinfo();
    seletedlanguage = Language.languageList()
        .where((element) => element.languageCode == 'en')
        .toList()[0];
  }

  setdeviceinfo() async {
    if (Platform.isAndroid == true) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setState(() {
        deviceid = androidInfo.id + androidInfo.androidId;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: androidInfo.model,
          Dbkeys.deviceInfoOS: 'android',
          Dbkeys.deviceInfoISPHYSICAL: androidInfo.isPhysicalDevice,
          Dbkeys.deviceInfoDEVICEID: androidInfo.id,
          Dbkeys.deviceInfoOSID: androidInfo.androidId,
          Dbkeys.deviceInfoOSVERSION: androidInfo.version.baseOS,
          Dbkeys.deviceInfoMANUFACTURER: androidInfo.manufacturer,
          Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
        };
      });
    } else if (Platform.isIOS == true) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setState(() {
        deviceid = iosInfo.systemName + iosInfo.model + iosInfo.systemVersion;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: iosInfo.model,
          Dbkeys.deviceInfoOS: 'ios',
          Dbkeys.deviceInfoISPHYSICAL: iosInfo.isPhysicalDevice,
          Dbkeys.deviceInfoDEVICEID: iosInfo.identifierForVendor,
          Dbkeys.deviceInfoOSID: iosInfo.name,
          Dbkeys.deviceInfoOSVERSION: iosInfo.name,
          Dbkeys.deviceInfoMANUFACTURER: iosInfo.name,
          Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
        };
      });
    }
  }

  int currentPinAttemps = 0;
  Future<void> verifyPhoneNumber() async {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      isShowCompletedLoading = true;
      setState(() {});
      handleSignIn(authCredential: phoneAuthCredential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        currentStatus = LoginStatus.failure.index;
        // _phoneNo.clear();
        // _code = '';
        isCodeSent = false;

        timerProvider.resetTimer();

        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps = 0;
      });

      print(
          'Authentication failed -ERROR: ${authException.message}. Try again later.');

      Fiberchat.toast('Authentication failed - ${authException.message}');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      timerProvider.startTimer();
      setState(() {
        currentStatus = LoginStatus.sentSMSCode.index;
        isVerifyingCode = false;
        isCodeSent = true;
      });

      this.verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      setState(() {
        currentStatus = LoginStatus.failure.index;
        // _phoneNo.clear();
        // _code = '';
        isCodeSent = false;

        timerProvider.resetTimer();

        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps = 0;
      });

      Fiberchat.toast('Authentication failed Timeout. please try again.');
    };
    // print('Verify phone triggered');
    // try {
    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: (phoneCode! + _phoneNo.text).trim(),
        timeout: Duration(seconds: timeOutSeconds),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    // } catch (e) {
    //   Fiberchat.toast('NEW CATCH' + e.toString());
    // }
  }

  Future<void> loginWithUsernameAndPassword(
      TextEditingController usernameController,
      TextEditingController passwordController) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      final email = '+2022' + _usernameController.text + '@okidokinow.com';
      print(email);
      try {
        UserCredential firebaseUser =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );
        print(firebaseUser);
        // isShowCompletedLoading = true;

        //setState(() {});

        await handleSignIn2(firebaseUser);
        //createUserInFirestore(credential.user);
        //TODO Update Usermeta fireBaseUid
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          Fiberchat.toast("Failed to Login ! Please try again. ");
          print(e);
          //TODO Regenrate user id
          //_fireBaseLogin(email, pwd, context);
        } else if (e.code == 'invalid-email') {
          print(e);
          Fiberchat.toast("Failed to Login ! Please try again. ");
          //This error may not occur since email is taken from user data when username provided for login
        } else if (e.code == 'weak-password') {
          // Fiberchat.toast("Failed to Login ! Please try again. ");
          //This error may not occur since password append with 5 * when less than 6
        } else if (e.code == 'user-not-found') {
          //TODO Register New user then login
          await register();

          // Fiberchat.toast("Failed to Login ! Please try again. ");
          //This error may not occur since password append with 5 * when less than 6
        }
        //  print('Error: ' + e.code);
      }
    }
    //TODO Append user id with @okitel.com
  }

  register() async {
    if (isChecked == false) {
      Fiberchat.toast('Please Accept terms and conditions');
    } else if (_formKey.currentState != null &&
        _formKey.currentState!.validate()) {
      final email = '2022' + _usernameController.text + '@okidokinow.com';
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );

        /*  isShowCompletedLoading = true;
      setState(() {});*/

        await handleSignIn2(credential);

        //createUserInFirestore(credential.user);
        //TODO Update Usermeta fireBaseUid
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          //ID is in use
        } else if (e.code == 'invalid-email') {
          //Invalid ID
          //This error may not occur since email is taken from user data when username provided for login
        } else if (e.code == 'weak-password') {
          //Weak Passowrd
          //This error may not occur since password append with 5 * when less than 6
        }
        //  print('Error: ' + e.code);
      }
    }

    // return status();
  }

  subscribeToNotification(String currentUserNo, bool isFreshNewAccount) async {
    await FirebaseMessaging.instance
        .subscribeToTopic(
            '${currentUserNo.replaceFirst(new RegExp(r'\+'), '')}')
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Dbkeys.topicUSERS)
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Platform.isAndroid
            ? Dbkeys.topicUSERSandroid
            : Platform.isIOS
                ? Dbkeys.topicUSERSios
                : Dbkeys.topicUSERSweb)
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });

    if (isFreshNewAccount == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserNo)
          .get()
          .then((query) async {
        if (query.docs.length > 0) {
          query.docs.forEach((doc) async {
            if (doc.data().containsKey(Dbkeys.groupMUTEDMEMBERS)) {
              if (doc[Dbkeys.groupMUTEDMEMBERS].contains(currentUserNo)) {
              } else {
                await FirebaseMessaging.instance
                    .subscribeToTopic(
                        "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                    .catchError((err) {
                  print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
                });
              }
            } else {
              await FirebaseMessaging.instance
                  .subscribeToTopic(
                      "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                  .catchError((err) {
                print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
              });
            }
          });
        }
      });
    }
  }

  Future<Null> handleSignIn({AuthCredential? authCredential}) async {
    setState(() {
      isShowCompletedLoading = true;
    });
    var phoneNo = (phoneCode! + _phoneNo.text).trim();

    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: _code);

      UserCredential firebaseUser =
          await firebaseAuth.signInWithCredential(credential);

      // ignore: unnecessary_null_comparison
      if (firebaseUser != null) {
        // Check is already sign up
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .where(Dbkeys.id, isEqualTo: firebaseUser.user!.uid)
            .get();
        final List documents = result.docs;
        final pair = await e2ee.X25519().generateKeyPair();

        if (documents.length == 0) {
          String? fcmTokenn = await FirebaseMessaging.instance.getToken();
          if (fcmTokenn != null) {
            await storage.write(
                key: Dbkeys.privateKey, value: pair.secretKey.toBase64());
            // Update data to server if new user
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(phoneNo)
                .set({
              Dbkeys.publicKey: pair.publicKey.toBase64(),
              Dbkeys.privateKey: pair.secretKey.toBase64(),
              Dbkeys.countryCode: phoneCode,
              Dbkeys.nickname: _name.text.trim(),
              Dbkeys.photoUrl: firebaseUser.user!.photoURL ?? '',
              Dbkeys.id: firebaseUser.user!.uid,
              Dbkeys.phone: phoneNo,
              Dbkeys.phoneRaw: _phoneNo.text,
              Dbkeys.authenticationType: AuthenticationType.passcode.index,
              Dbkeys.aboutMe: '',
              //---Additional fields added for Admin app compatible----
              Dbkeys.accountstatus:
                  widget.isaccountapprovalbyadminneeded == true
                      ? Dbkeys.sTATUSpending
                      : Dbkeys.sTATUSallowed,
              Dbkeys.actionmessage: widget.accountApprovalMessage,
              Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
              Dbkeys.joinedOn: DateTime.now().millisecondsSinceEpoch,
              Dbkeys.searchKey: _name.text.trim().substring(0, 1).toUpperCase(),
              Dbkeys.videoCallMade: 0,
              Dbkeys.videoCallRecieved: 0,
              Dbkeys.audioCallMade: 0,
              Dbkeys.groupsCreated: 0,
              Dbkeys.blockeduserslist: [],
              Dbkeys.audioCallRecieved: 0,
              Dbkeys.mssgSent: 0,
              Dbkeys.deviceDetails: mapDeviceInfo,
              Dbkeys.currentDeviceID: deviceid,
              Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                  countrycode: phoneCode, phonenumber: _phoneNo.text)
            }, SetOptions(merge: true));
            currentUser = firebaseUser.user;
            await FirebaseFirestore.instance
                .collection(DbPaths.collectiondashboard)
                .doc(DbPaths.docuserscount)
                .set(
                    widget.isaccountapprovalbyadminneeded == false
                        ? {
                            Dbkeys.totalapprovedusers: FieldValue.increment(1),
                          }
                        : {
                            Dbkeys.totalpendingusers: FieldValue.increment(1),
                          },
                    SetOptions(merge: true));

            await FirebaseFirestore.instance
                .collection(DbPaths.collectioncountrywiseData)
                .doc(phoneCode)
                .set({
              Dbkeys.totalusers: FieldValue.increment(1),
            }, SetOptions(merge: true));

            await FirebaseFirestore.instance
                .collection(DbPaths.collectionnotifications)
                .doc(DbPaths.adminnotifications)
                .update({
              Dbkeys.nOTIFICATIONxxaction: 'PUSH',
              Dbkeys.nOTIFICATIONxxdesc: widget
                          .isaccountapprovalbyadminneeded ==
                      true
                  ? '${_name.text.trim()} has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
                  : '${_name.text.trim()} has Joined $Appname. You can view the user profile from All Users List.',
              Dbkeys.nOTIFICATIONxxtitle: 'New User Joined',
              Dbkeys.nOTIFICATIONxximageurl: null,
              Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
              'list': FieldValue.arrayUnion([
                {
                  Dbkeys.docid:
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  Dbkeys.nOTIFICATIONxxdesc: widget
                              .isaccountapprovalbyadminneeded ==
                          true
                      ? '${_name.text.trim()} has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
                      : '${_name.text.trim()} has Joined $Appname. You can view the user profile from All Users List.',
                  Dbkeys.nOTIFICATIONxxtitle: 'New User Joined',
                  Dbkeys.nOTIFICATIONxximageurl: null,
                  Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
                  Dbkeys.nOTIFICATIONxxauthor:
                      currentUser!.uid + 'XXX' + 'userapp',
                }
              ])
            });

            // Write data to local

            await widget.prefs.setString(Dbkeys.id, currentUser!.uid);
            await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
            await widget.prefs
                .setString(Dbkeys.photoUrl, currentUser!.photoURL ?? '');
            await widget.prefs.setString(Dbkeys.phone, phoneNo);
            await widget.prefs.setString(Dbkeys.countryCode, phoneCode!);
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(phoneNo)
                .set({
              Dbkeys.notificationTokens: [fcmTokenn]
            }, SetOptions(merge: true));
            unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));

            unawaited(Navigator.pushReplacement(
                this.context,
                MaterialPageRoute(
                    builder: (newContext) => Homepage(
                          currentUserNo: phoneNo,
                          isSecuritySetupDone: true,
                          prefs: widget.prefs,
                        ))));
            await widget.prefs.setString(Dbkeys.isSecuritySetupDone, phoneNo);
            await subscribeToNotification(phoneNo, true);
          } else {
            unawaited(Navigator.pushReplacement(
                this.context,
                new MaterialPageRoute(
                    builder: (context) => FiberchatWrapper())));
            Fiberchat.toast("Failed to Login ! Please try again. ");
          }
        } else {
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await storage.write(
                key: Dbkeys.privateKey, value: documents[0][Dbkeys.privateKey]);

            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(phoneNo)
                .update(
                  !documents[0].data().containsKey(Dbkeys.deviceDetails)
                      ? {
                          Dbkeys.authenticationType:
                              AuthenticationType.passcode.index,
                          Dbkeys.accountstatus:
                              widget.isaccountapprovalbyadminneeded == true
                                  ? Dbkeys.sTATUSpending
                                  : Dbkeys.sTATUSallowed,
                          Dbkeys.actionmessage: widget.accountApprovalMessage,
                          Dbkeys.lastLogin:
                              DateTime.now().millisecondsSinceEpoch,
                          Dbkeys.joinedOn:
                              documents[0].data()![Dbkeys.lastSeen] != true
                                  ? documents[0].data()![Dbkeys.lastSeen]
                                  : DateTime.now().millisecondsSinceEpoch,
                          Dbkeys.nickname: _name.text.trim(),
                          Dbkeys.searchKey:
                              _name.text.trim().substring(0, 1).toUpperCase(),
                          Dbkeys.videoCallMade: 0,
                          Dbkeys.videoCallRecieved: 0,
                          Dbkeys.audioCallMade: 0,
                          Dbkeys.audioCallRecieved: 0,
                          Dbkeys.mssgSent: 0,
                          Dbkeys.deviceDetails: mapDeviceInfo,
                          Dbkeys.currentDeviceID: deviceid,
                          Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                              countrycode:
                                  documents[0].data()![Dbkeys.countryCode],
                              phonenumber:
                                  documents[0].data()![Dbkeys.phoneRaw]),
                          Dbkeys.notificationTokens: [fcmToken],
                        }
                      : {
                          Dbkeys.searchKey:
                              _name.text.trim().substring(0, 1).toUpperCase(),
                          Dbkeys.nickname: _name.text.trim(),
                          Dbkeys.authenticationType:
                              AuthenticationType.passcode.index,
                          Dbkeys.lastLogin:
                              DateTime.now().millisecondsSinceEpoch,
                          Dbkeys.deviceDetails: mapDeviceInfo,
                          Dbkeys.currentDeviceID: deviceid,
                          Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                              countrycode:
                                  documents[0].data()![Dbkeys.countryCode],
                              phonenumber:
                                  documents[0].data()![Dbkeys.phoneRaw]),
                          Dbkeys.notificationTokens: [fcmToken],
                        },
                );
            // Write data to local
            await widget.prefs.setString(Dbkeys.id, documents[0][Dbkeys.id]);
            await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
            await widget.prefs.setString(
                Dbkeys.photoUrl, documents[0][Dbkeys.photoUrl] ?? '');
            await widget.prefs
                .setString(Dbkeys.aboutMe, documents[0][Dbkeys.aboutMe] ?? '');
            await widget.prefs
                .setString(Dbkeys.phone, documents[0][Dbkeys.phone]);

            if (widget.issecutitysetupdone == false) {
              unawaited(Navigator.pushReplacement(
                  this.context,
                  MaterialPageRoute(
                      builder: (newContext) => Homepage(
                            currentUserNo: phoneNo,
                            isSecuritySetupDone: true,
                            prefs: widget.prefs,
                          ))));
              await widget.prefs.setString(
                  Dbkeys.isSecuritySetupDone, documents[0][Dbkeys.phone]);
              await subscribeToNotification(documents[0][Dbkeys.phone], false);
            } else {
              unawaited(Navigator.pushReplacement(
                  this.context,
                  new MaterialPageRoute(
                      builder: (context) => FiberchatWrapper())));
              Fiberchat.toast(getTranslated(this.context, 'welcomeback'));
              await subscribeToNotification(documents[0][Dbkeys.phone], false);
            }
          } else {
            unawaited(Navigator.pushReplacement(
                this.context,
                new MaterialPageRoute(
                    builder: (context) => FiberchatWrapper())));
            Fiberchat.toast("Failed to Login ! Please try again. ");
          }
        }
      } else {
        Fiberchat.toast(getTranslated(this.context, 'failedlogin'));
      }
    } catch (e) {
      setState(() {
        if (currentPinAttemps >= 4) {
          currentStatus = LoginStatus.failure.index;
          // _phoneNo.clear();
          // _code = '';
          isCodeSent = false;
        }

        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps++;
      });
      if (e.toString().contains('invalid') ||
          e.toString().contains('code') ||
          e.toString().contains('verification')) {
        // Fiberchat.toast(getTranslated(this.context, 'makesureotp'));
      }
    }
  }

  Future<Null> handleSignIn2(UserCredential firebaseUser) async {
    setState(() {
      isShowCompletedLoading = true;
    });

    /* isShowCompletedLoading = true;
    setState(() {});*/

    _phoneNo.text = _usernameController.text;
    phoneCode = '2022';
    var phoneNo = _usernameController.text;
    _name.text = 'Unknown';

    try {
      /*AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: _code);

      UserCredential firebaseUser =
      await firebaseAuth.signInWithCredential(credential);*/
//print(firebaseUser);
      // ignore: unnecessary_null_comparison
      if (firebaseUser != null) {
        print(_usernameController.text);
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('loginId', _usernameController.text);
        print(pref.getString('loginId'));
        // Check is already sign up
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .where(Dbkeys.id, isEqualTo: firebaseUser.user!.uid)
            .get();
        final List documents = result.docs;
        final pair = await e2ee.X25519().generateKeyPair();
//print(documents.length);
        if (documents.length == 0) {
          String? fcmTokenn = await FirebaseMessaging.instance.getToken();
          print(fcmTokenn);
          if (fcmTokenn != null) {
            //  print('start set user');
            //  print(firebaseUser.user!.uid);
            await storage.write(
                key: Dbkeys.privateKey, value: pair.secretKey.toBase64());
            // Update data to server if new user
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(phoneNo)
                .set({
              Dbkeys.publicKey: pair.publicKey.toBase64(),
              Dbkeys.privateKey: pair.secretKey.toBase64(),
              Dbkeys.countryCode: phoneCode,
              Dbkeys.nickname: _name.text.trim(),
              Dbkeys.photoUrl: firebaseUser.user!.photoURL ?? '',
              Dbkeys.id: firebaseUser.user!.uid,
              Dbkeys.phone: phoneNo,
              Dbkeys.phoneRaw: _phoneNo.text,
              Dbkeys.authenticationType: AuthenticationType.passcode.index,
              Dbkeys.aboutMe: '',
              //---Additional fields added for Admin app compatible----
              Dbkeys.accountstatus:
                  widget.isaccountapprovalbyadminneeded == true
                      ? Dbkeys.sTATUSpending
                      : Dbkeys.sTATUSallowed,
              Dbkeys.actionmessage: widget.accountApprovalMessage,
              Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
              Dbkeys.joinedOn: DateTime.now().millisecondsSinceEpoch,
              Dbkeys.searchKey: _name.text.trim().substring(0, 1).toUpperCase(),
              Dbkeys.videoCallMade: 0,
              Dbkeys.videoCallRecieved: 0,
              Dbkeys.audioCallMade: 0,
              Dbkeys.groupsCreated: 0,
              Dbkeys.blockeduserslist: [],
              Dbkeys.audioCallRecieved: 0,
              Dbkeys.mssgSent: 0,
              Dbkeys.deviceDetails: mapDeviceInfo,
              Dbkeys.currentDeviceID: deviceid,
              Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                  countrycode: phoneCode, phonenumber: _phoneNo.text)
            }, SetOptions(merge: true));

            currentUser = firebaseUser.user;
            print(currentUser);
            await FirebaseFirestore.instance
                .collection(DbPaths.collectiondashboard)
                .doc(DbPaths.docuserscount)
                .set(
                    widget.isaccountapprovalbyadminneeded == false
                        ? {
                            Dbkeys.totalapprovedusers: FieldValue.increment(1),
                          }
                        : {
                            Dbkeys.totalpendingusers: FieldValue.increment(1),
                          },
                    SetOptions(merge: true));

            await FirebaseFirestore.instance
                .collection(DbPaths.collectioncountrywiseData)
                .doc(phoneCode)
                .set({
              Dbkeys.totalusers: FieldValue.increment(1),
            }, SetOptions(merge: true));

            await FirebaseFirestore.instance
                .collection(DbPaths.collectionnotifications)
                .doc(DbPaths.adminnotifications)
                .update({
              Dbkeys.nOTIFICATIONxxaction: 'PUSH',
              Dbkeys.nOTIFICATIONxxdesc: widget
                          .isaccountapprovalbyadminneeded ==
                      true
                  ? '${_name.text.trim()} has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
                  : '${_name.text.trim()} has Joined $Appname. You can view the user profile from All Users List.',
              Dbkeys.nOTIFICATIONxxtitle: 'New User Joined',
              Dbkeys.nOTIFICATIONxximageurl: null,
              Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
              'list': FieldValue.arrayUnion([
                {
                  Dbkeys.docid:
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  Dbkeys.nOTIFICATIONxxdesc: widget
                              .isaccountapprovalbyadminneeded ==
                          true
                      ? '${_name.text.trim()} has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
                      : '${_name.text.trim()} has Joined $Appname. You can view the user profile from All Users List.',
                  Dbkeys.nOTIFICATIONxxtitle: 'New User Joined',
                  Dbkeys.nOTIFICATIONxximageurl: null,
                  Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
                  Dbkeys.nOTIFICATIONxxauthor:
                      currentUser!.uid + 'XXX' + 'userapp',
                }
              ])
            });

            // Write data to local

            await widget.prefs.setString(Dbkeys.id, currentUser!.uid);
            await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
            await widget.prefs
                .setString(Dbkeys.photoUrl, currentUser!.photoURL ?? '');
            await widget.prefs.setString(Dbkeys.phone, phoneNo);
            await widget.prefs.setString(Dbkeys.countryCode, phoneCode!);
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(phoneNo)
                .set({
              Dbkeys.notificationTokens: [fcmTokenn]
            }, SetOptions(merge: true));
            unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));

            unawaited(Navigator.pushReplacement(
                this.context,
                MaterialPageRoute(
                    builder: (newContext) => Homepage(
                          currentUserNo: phoneNo,
                          isSecuritySetupDone: true,
                          prefs: widget.prefs,
                        ))));
            await widget.prefs.setString(Dbkeys.isSecuritySetupDone, phoneNo);
            await subscribeToNotification(phoneNo, true);
          } else {
            unawaited(Navigator.pushReplacement(
                this.context,
                new MaterialPageRoute(
                    builder: (context) => FiberchatWrapper())));
            Fiberchat.toast("Failed to Login ! Please try again. ");
          }
        } else {
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await storage.write(
                key: Dbkeys.privateKey, value: documents[0][Dbkeys.privateKey]);

            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(phoneNo)
                .update(
                  !documents[0].data().containsKey(Dbkeys.deviceDetails)
                      ? {
                          Dbkeys.authenticationType:
                              AuthenticationType.passcode.index,
                          Dbkeys.accountstatus:
                              widget.isaccountapprovalbyadminneeded == true
                                  ? Dbkeys.sTATUSpending
                                  : Dbkeys.sTATUSallowed,
                          Dbkeys.actionmessage: widget.accountApprovalMessage,
                          Dbkeys.lastLogin:
                              DateTime.now().millisecondsSinceEpoch,
                          Dbkeys.joinedOn:
                              documents[0].data()![Dbkeys.lastSeen] != true
                                  ? documents[0].data()![Dbkeys.lastSeen]
                                  : DateTime.now().millisecondsSinceEpoch,
                          Dbkeys.nickname: _name.text.trim(),
                          Dbkeys.searchKey:
                              _name.text.trim().substring(0, 1).toUpperCase(),
                          Dbkeys.videoCallMade: 0,
                          Dbkeys.videoCallRecieved: 0,
                          Dbkeys.audioCallMade: 0,
                          Dbkeys.audioCallRecieved: 0,
                          Dbkeys.mssgSent: 0,
                          Dbkeys.deviceDetails: mapDeviceInfo,
                          Dbkeys.currentDeviceID: deviceid,
                          Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                              countrycode:
                                  documents[0].data()![Dbkeys.countryCode],
                              phonenumber:
                                  documents[0].data()![Dbkeys.phoneRaw]),
                          Dbkeys.notificationTokens: [fcmToken],
                        }
                      : {
                          Dbkeys.searchKey:
                              _name.text.trim().substring(0, 1).toUpperCase(),
                          Dbkeys.nickname: _name.text.trim(),
                          Dbkeys.authenticationType:
                              AuthenticationType.passcode.index,
                          Dbkeys.lastLogin:
                              DateTime.now().millisecondsSinceEpoch,
                          Dbkeys.deviceDetails: mapDeviceInfo,
                          Dbkeys.currentDeviceID: deviceid,
                          Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                              countrycode:
                                  documents[0].data()![Dbkeys.countryCode],
                              phonenumber:
                                  documents[0].data()![Dbkeys.phoneRaw]),
                          Dbkeys.notificationTokens: [fcmToken],
                        },
                );
            // Write data to local
            await widget.prefs.setString(Dbkeys.id, documents[0][Dbkeys.id]);
            await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
            await widget.prefs.setString(
                Dbkeys.photoUrl, documents[0][Dbkeys.photoUrl] ?? '');
            await widget.prefs
                .setString(Dbkeys.aboutMe, documents[0][Dbkeys.aboutMe] ?? '');
            await widget.prefs
                .setString(Dbkeys.phone, documents[0][Dbkeys.phone]);

            if (widget.issecutitysetupdone == false) {
              unawaited(Navigator.pushReplacement(
                  this.context,
                  MaterialPageRoute(
                      builder: (newContext) => Homepage(
                            currentUserNo: phoneNo,
                            isSecuritySetupDone: true,
                            prefs: widget.prefs,
                          ))));
              await widget.prefs.setString(
                  Dbkeys.isSecuritySetupDone, documents[0][Dbkeys.phone]);
              await subscribeToNotification(documents[0][Dbkeys.phone], false);
            } else {
              unawaited(Navigator.pushReplacement(
                  this.context,
                  new MaterialPageRoute(
                      builder: (context) => FiberchatWrapper())));
              Fiberchat.toast(getTranslated(this.context, 'welcomeback'));
              await subscribeToNotification(documents[0][Dbkeys.phone], false);
            }
          } else {
            unawaited(Navigator.pushReplacement(
                this.context,
                new MaterialPageRoute(
                    builder: (context) => FiberchatWrapper())));
            Fiberchat.toast("Failed to Login ! Please try again. ");
          }
        }
      } else {
        Fiberchat.toast(getTranslated(this.context, 'failedlogin'));
      }
    } catch (e) {
      setState(() {
        if (currentPinAttemps >= 4) {
          currentStatus = LoginStatus.failure.index;
          // _phoneNo.clear();
          // _code = '';
          isCodeSent = false;
        }

        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps++;
      });
      if (e.toString().contains('invalid') ||
          e.toString().contains('code') ||
          e.toString().contains('verification')) {
        Fiberchat.toast(getTranslated(this.context, 'makesureotp'));
      }
    }
  }

  Language? seletedlanguage;
  customclippath(double w, double h) {
    return ClipPath(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: MediaQuery.of(this.context).padding.top),
        height: 400,
        /* decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [loginPageTopColor, loginPageBottomColor],
          ),
        ),*/
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/topimg.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: Platform.isIOS ? 0 : 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //---- All localizations settings----
                ],
              ),
            ),
            //  SizedBox(height: w > h ? 0 : 15,),

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
    );
  }

  buildCurrentWidget(double w) {
    if (currentStatus == LoginStatus.sendSMScode.index) {
      return loginWidgetsendSMScode(w);
    } /*else if (currentStatus == LoginStatus.sendingSMScode.index) {
      return loginWidgetsendingSMScode();
    }*/ /*else if (currentStatus == LoginStatus.sentSMSCode.index) {
      return loginWidgetsentSMScode();
    }*/ /*else if (currentStatus == LoginStatus.verifyingSMSCode.index) {
      return loginWidgetVerifyingSMScode();
    } */ /*else if (currentStatus == LoginStatus.sendingSMScode.index) {
      return loginWidgetsendingSMScode();
    } */
    else {
      return loginWidgetsendSMScode(w);
    }
  }

  loginWidgetsendSMScode(double w) {
    return Consumer<Observer>(
        builder: (context, observer, _) => Column(
              children: [
                Container(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 13,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          // height: 63,
                          height: 83,
                          width: w / 1.24,
                          child: TextFormField(
                            controller: _usernameController,
                            readOnly: true,
                            validator: (v) {
                              if (v != null && v.length > 10) {
                                return 'id cannot exceeds more than 10 digits';
                              } else if (v != null && v.length < 10) {
                                return 'please enter 10 digits id';
                              } else
                                return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Your Unique ID',
                              prefix: Padding(
                                  padding: EdgeInsets.all(13),
                                  child: Text('+2022',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1)),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          // height: 63,
                          height: 83,
                          width: w / 1.24,
                          child: TextFormField(
                            obscureText: _obscureText,
                            validator: (v) {
                              if (v != null && v.length < 5) {
                                return 'Please enter 6 digit password';
                              }
                              /* else if( v != null && v.length >7){
                            return 'Please enter 6 digit password';

                          }*/
                              else
                                return null;
                            },
                            decoration: InputDecoration(
                                hintText: 'Password',
                                suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    })),
                            controller: _passwordController,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          // height: 63,
                          height: 83,
                          width: w / 1.24,
                          child: TextFormField(
                            obscureText: _obscureText,
                            validator: (v) {
                              if (v != null && v.length < 5) {
                                return 'Password should match to login ';
                              }
                              if (_passwordController.text !=
                                  _retypePasswordController.text) {
                                return 'Password should match to login ';
                              } else
                                return null;
                            },
                            decoration: InputDecoration(
                                hintText: 'Re-type Password',
                                suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    })),
                            controller: _retypePasswordController,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(17, 22, 17, 5),
                          child: LoadingButton1(
                            text: 'SIGN IN',
                            buttoncolor: DESIGN_TYPE == Themetype.whatsapp
                                ? fiberchatLightGreen
                                : fiberchatLightGreen,
                            height: 57,

                            onPressed: () async {
                              setState(() {
                                if (isChecked == false)
                                  Fiberchat.toast(
                                      'Please accept terms and conditions');
                              });
                              await register();
                              return;
                            },
                            // text: 'SIGN IN',
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                              value: isChecked,
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: RichText(
                                  maxLines: 3,
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                      text:
                                          //'${getTranslated(this.context, 'agree')} \n',
                                          ''' By Continuing, you agree with the Terms & Conditions and Privacy Policy ''',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          if (ConnectWithAdminApp == false) {
                                            custom_url_launcher(
                                                PRIVACY_POLICY_URL);
                                          } else {
                                            if (observer.privacypolicyType ==
                                                'url') {
                                              if (observer.privacypolicy ==
                                                  null) {
                                                custom_url_launcher(
                                                    PRIVACY_POLICY_URL);
                                              } else {
                                                custom_url_launcher(
                                                    observer.privacypolicy!);
                                              }
                                            } else if (observer
                                                    .privacypolicyType ==
                                                'file') {
                                              Navigator.push(
                                                  this.context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PDFViewerCachedFromUrl(
                                                      prefs: widget.prefs,
                                                      title: getTranslated(
                                                          this.context, 'pp'),
                                                      url: observer
                                                          .privacypolicy,
                                                      isregistered: false,
                                                    ),
                                                  ));
                                            }
                                          }
                                        }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  height: 450,
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(this.context).size.width;
    var h = MediaQuery.of(this.context).size.height;

    return Fiberchat.getNTPWrappedWidget(Scaffold(
      backgroundColor: fiberchatWhite,
      //DESIGN_TYPE == Themetype.whatsapp ? fiberchatDeepGreen
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme:
            Theme.of(context).primaryIconTheme.copyWith(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[customclippath(w, h), buildCurrentWidget(w)],
          ),
        ],
      )),
    ));
  }

  onError() {
    print('unknown');
  }

  Future<void> _generateId() async {
    //SharedPreferences pref = await SharedPreferences.getInstance();
    // String? id = await pref.getString('loginId');
    //   print(id);
    /* if (id != null) {
      _usernameController.text = id;
    } else {*/
    Random random = new Random();
    var randomNumber = random.nextInt(1000000000) + 1000000000;
    _usernameController.text = randomNumber.toString();
    // }
  }
}

//___CONSTRUCTORS----

/*class MySimpleButton extends StatefulWidget {
  final Color? buttoncolor;
  final Color? buttontextcolor;
  final Color? shadowcolor;
  final String? buttontext;
  final double? width;
  final double? height;
  final double? spacing;
  final double? borderradius;
  final Function()? onpressed;

  MySimpleButton(
      {this.buttontext,
        this.buttoncolor,
        this.height,
        this.spacing,
        this.borderradius,
        this.width,
        this.buttontextcolor,
        // this.icon,
        this.onpressed,
        // this.forcewidget,
        this.shadowcolor});
  @override
  _MySimpleButtonState createState() => _MySimpleButtonState();
}

class _MySimpleButtonState extends State<MySimpleButton> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(this.context).size.width;
    return GestureDetector(
        onTap: widget.onpressed as void Function()?,
        child: Container(
          alignment: Alignment.center,
          width: widget.width ?? w - 40,
          height: widget.height ?? 50,
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Text(
            widget.buttontext ?? getTranslated(this.context, 'submit'),
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: widget.spacing ?? 2,
              fontSize: 15,
              color: widget.buttontextcolor ?? Colors.white,
            ),
          ),
          decoration: BoxDecoration(
              color: widget.buttoncolor ?? Colors.primaries as Color?,
              //gradient: LinearGradient(colors: [bgColor, whiteColor]),
              boxShadow: [
                BoxShadow(
                    color: widget.shadowcolor ?? Colors.transparent,
                    blurRadius: 10,
                    spreadRadius: 2)
              ],
              border: Border.all(
                color: widget.buttoncolor ?? fiberchatgreen,
              ),
              borderRadius:
              BorderRadius.all(Radius.circular(widget.borderradius ?? 5))),
        ));
  }
}*/

/*class MobileInputWithOutline extends StatefulWidget {
  final String? initialCountryCode;
  final String? hintText;
  final double? height;
  final double? width;
  final TextEditingController? controller;
  final Color? borderColor;
  final Color? buttonTextColor;
  final Color? buttonhintTextColor;
  final TextStyle? hintStyle;
  final String? buttonText;
  final Function(PhoneNumber? phone)? onSaved;

  MobileInputWithOutline(
      {this.height,
        this.width,
        this.borderColor,
        this.buttonhintTextColor,
        this.hintStyle,
        this.buttonTextColor,
        this.onSaved,
        this.hintText,
        this.controller,
        this.initialCountryCode,
        this.buttonText});
  @override
  _MobileInputWithOutlineState createState() => _MobileInputWithOutlineState();
}

class _MobileInputWithOutlineState extends State<MobileInputWithOutline> {
  BoxDecoration boxDecoration(
      {double radius = 5,
        Color bgColor = Colors.white,
        var showShadow = false}) {
    return BoxDecoration(
        color: bgColor,
        boxShadow: showShadow
            ? [
          BoxShadow(
              color: fiberchatgreen, blurRadius: 10, spreadRadius: 2)
        ]
            : [BoxShadow(color: Colors.transparent)],
        border:
        Border.all(color: widget.borderColor ?? Colors.grey, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(radius)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsetsDirectional.only(bottom: 7, top: 5),
          height: widget.height ?? 50,
          width: widget.width ?? MediaQuery.of(this.context).size.width,
          decoration: boxDecoration(),
          child: IntlPhoneField(
              searchText: "Search by Country / Region Name",
              dropDownArrowColor:
              widget.buttonhintTextColor ?? Colors.grey[300],
              textAlign: TextAlign.left,
              initialCountryCode: widget.initialCountryCode,
              controller: widget.controller,
              style: TextStyle(
                  height: 1.35,
                  letterSpacing: 1,
                  fontSize: 16.0,
                  color: widget.buttonTextColor ?? Colors.black87,
                  fontWeight: FontWeight.bold),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(3, 15, 8, 0),
                  hintText: widget.hintText ??
                      getTranslated(this.context, 'enter_mobilenumber'),
                  hintStyle: widget.hintStyle ??
                      TextStyle(
                          letterSpacing: 1,
                          height: 0.0,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w400,
                          color: widget.buttonhintTextColor ?? fiberchatGrey),
                  fillColor: Colors.white,
                  filled: true,
                  border: new OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    borderSide: BorderSide.none,
                  )),
              onChanged: (phone) {
                widget.onSaved!(phone);
              },
              validator: (v) {
                return null;
              },
              onSaved: widget.onSaved),
        ),
        // Positioned(
        //     left: 110,
        //     child: Container(
        //       width: 1.5,
        //       height: widget.height ?? 48,
        //       color: widget.borderColor ?? Colors.grey,
        //     ))
      ],
    );
  }
}*/
/*
class InpuTextBox extends StatefulWidget {
  final Color? boxbcgcolor;
  final Color? boxbordercolor;
  final double? boxcornerradius;
  final double? fontsize;
  final double? boxwidth;
  final double? boxborderwidth;
  final double? boxheight;
  final EdgeInsets? forcedmargin;
  final double? letterspacing;
  final double? leftrightmargin;
  final TextEditingController? controller;
  final Function(String val)? validator;
  final Function(String? val)? onSaved;
  final Function(String val)? onchanged;
  final TextInputType? keyboardtype;
  final TextCapitalization? textCapitalization;

  final String? title;
  final String? subtitle;
  final String? hinttext;
  final String? placeholder;
  final int? maxLines;
  final int? minLines;
  final int? maxcharacters;
  final bool? isboldinput;
  final bool? obscuretext;
  final bool? autovalidate;
  final bool? disabled;
  final bool? showIconboundary;
  final Widget? sufficIconbutton;
  final List<TextInputFormatter>? inputFormatter;
  final Widget? prefixIconbutton;

  InpuTextBox(
      {this.controller,
        this.boxbordercolor,
        this.boxheight,
        this.fontsize,
        this.leftrightmargin,
        this.letterspacing,
        this.forcedmargin,
        this.boxwidth,
        this.boxcornerradius,
        this.boxbcgcolor,
        this.hinttext,
        this.boxborderwidth,
        this.onSaved,
        this.textCapitalization,
        this.onchanged,
        this.placeholder,
        this.showIconboundary,
        this.subtitle,
        this.disabled,
        this.keyboardtype,
        this.inputFormatter,
        this.validator,
        this.title,
        this.maxLines,
        this.autovalidate,
        this.prefixIconbutton,
        this.maxcharacters,
        this.isboldinput,
        this.obscuretext,
        this.sufficIconbutton,
        this.minLines});
  @override
  _InpuTextBoxState createState() => _InpuTextBoxState();
}

class _InpuTextBoxState extends State<InpuTextBox> {
  bool isobscuretext = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      isobscuretext = widget.obscuretext ?? false;
    });
  }

  changeobscure() {
    setState(() {
      isobscuretext = !isobscuretext;
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(this.context).size.width;
    return Align(
      child: Container(
        margin: EdgeInsets.fromLTRB(
            widget.leftrightmargin ?? 8, 5, widget.leftrightmargin ?? 8, 5),
        width: widget.boxwidth ?? w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // color: Colors.white,
              height: widget.boxheight ?? 50,
              // decoration: BoxDecoration(
              //     color: widget.boxbcgcolor ?? Colors.white,
              //     border: Border.all(
              //         color:
              //             widget.boxbordercolor ?? Mycolors.grey.withOpacity(0.2),
              //         style: BorderStyle.solid,
              //         width: 1.8),
              //     borderRadius: BorderRadius.all(
              //         Radius.circular(widget.boxcornerradius ?? 5))),
              child: TextFormField(
                minLines: widget.minLines ?? null,
                maxLines: widget.maxLines ?? 1,
                controller: widget.controller ?? null,
                obscureText: isobscuretext,
                onSaved: widget.onSaved ?? (val) {},
                readOnly: widget.disabled ?? false,
                onChanged: widget.onchanged ?? (val) {},
                maxLength: widget.maxcharacters ?? null,
                validator:
                widget.validator as String? Function(String?)? ?? null,
                keyboardType: widget.keyboardtype ?? null,
                autovalidateMode: widget.autovalidate == true
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                inputFormatters: widget.inputFormatter ?? [],
                textCapitalization:
                widget.textCapitalization ?? TextCapitalization.sentences,
                style: TextStyle(
                  letterSpacing: widget.letterspacing ?? null,
                  fontSize: widget.fontsize ?? 15,
                  fontWeight: widget.isboldinput == true
                      ? FontWeight.w600
                      : FontWeight.w400,
                  // fontFamily:
                  //     widget.isboldinput == true ? 'NotoBold' : 'NotoRegular',
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                    prefixIcon: widget.prefixIconbutton != null
                        ? Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                                width: widget.boxborderwidth ?? 1.5,
                                color: widget.showIconboundary == true ||
                                    widget.showIconboundary == null
                                    ? Colors.grey.withOpacity(0.3)
                                    : Colors.transparent),
                          ),
                          // color: Colors.white,
                        ),
                        margin: EdgeInsets.only(
                            left: 2, right: 5, top: 2, bottom: 2),
                        // height: 45,
                        alignment: Alignment.center,
                        width: 50,
                        child: widget.prefixIconbutton != null
                            ? widget.prefixIconbutton
                            : null)
                        : null,
                    suffixIcon: widget.sufficIconbutton != null ||
                        widget.obscuretext == true
                        ? Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                                width: widget.boxborderwidth ?? 1.5,
                                color: widget.showIconboundary == true ||
                                    widget.showIconboundary == null
                                    ? Colors.grey.withOpacity(0.3)
                                    : Colors.transparent),
                          ),
                          // color: Colors.white,
                        ),
                        margin: EdgeInsets.only(
                            left: 2, right: 5, top: 2, bottom: 2),
                        // height: 45,
                        alignment: Alignment.center,
                        width: 50,
                        child: widget.sufficIconbutton != null
                            ? widget.sufficIconbutton
                            : widget.obscuretext == true
                            ? IconButton(
                            icon: Icon(
                                isobscuretext == true
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.blueGrey),
                            onPressed: () {
                              changeobscure();
                            })
                            : null)
                        : null,
                    filled: true,
                    fillColor: widget.boxbcgcolor ?? Colors.white,
                    enabledBorder: OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderRadius:
                      BorderRadius.circular(widget.boxcornerradius ?? 1),
                      borderSide: BorderSide(
                          color: widget.boxbordercolor ??
                              Colors.grey.withOpacity(0.2),
                          width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderRadius:
                      BorderRadius.circular(widget.boxcornerradius ?? 1),
                      borderSide: BorderSide(color: fiberchatgreen, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(widget.boxcornerradius ?? 1),
                        borderSide: BorderSide(color: Colors.grey)),
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    // labelText: 'Password',
                    hintText: widget.hinttext ?? '',
                    // fillColor: widget.boxbcgcolor ?? Colors.white,

                    hintStyle: TextStyle(
                        letterSpacing: widget.letterspacing ?? 1.5,
                        color: fiberchatGrey,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
