import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:flutter_dialpad/flutter_dialpad.dart';



class JitsiCall extends StatefulWidget {
String userPhone="";
  @override
  _JitsiCall createState() => _JitsiCall();


JitsiCall(String userPhone){
this.userPhone = userPhone;
}

}



class _JitsiCall extends State<JitsiCall> {
  //String personalPhone=;
  final serverText = TextEditingController(text:"https://server12-3.okitelecom.com/");
  final roomText = TextEditingController(text: "nowthisisfinalaksandaskingformore");
  final subjectText = TextEditingController(text: "OKITELE Call");
  final nameText = TextEditingController(text: "Naseer");
  final emailText = TextEditingController(text: "naseer@gmail.com");
  final iosAppBarRGBAColor =
  TextEditingController(text: "#0080FF80"); //transparent blue
  bool? isAudioOnly = true;
  bool? isAudioMuted = true;
  bool? isVideoMuted = true;

  @override
  void initState() {
    super.initState();

    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    //personalPhone= widget.userPhone;
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child:
            DialPad(
                enableDtmf: true,
                //outputMask: "(000) 000-0000",
                backspaceButtonIconColor: Colors.red,
                buttonTextColor: Colors.white,
                dialOutputTextColor: Colors.white,
                keyPressed: (value){
                  print('$value was pressed');
                },
                makeCall: (number){
                  print("---personal number ${widget.userPhone}");
                  print(number);
                  var charactersNumber1 =  widget.userPhone.characters;
                  int a = int.parse(charactersNumber1.last);
                  var charactersNumber2 =  number.characters;
                  int b = int.parse(charactersNumber2.last);
                  print("----- a is ${a}");
                  print("----- a is ${b}");
                  String meetingRoom = "";
                  if(a==b){
                    charactersNumber1 =  widget.userPhone.characters;
                     a = int.parse(charactersNumber1.toList()[4]);
                    charactersNumber2 =  widget.userPhone.characters;
                     b = int.parse(charactersNumber1.toList()[4]);
                    if (a > b) {
                      meetingRoom = widget.userPhone + "AND" + number;
                      print("1 meeting roomn 1 is ${meetingRoom}");
                    }
                    else {
                      meetingRoom = number + "AND" + widget.userPhone;
                      print("2 meeting room is ${meetingRoom}");
                    }

//    1513299629AND1609919887
//    1609919887AND1513299629


        //            3 meeting room is 1513299629AND1609919887
                //      4 meeting room is 1513299629AND1609919887

                  }else {
                    if (a > b) {
                      meetingRoom = widget.userPhone + "AND" + number;
                      print("3 meeting room is ${meetingRoom}");
                    }
                    else {
                      meetingRoom = number + "AND" + widget.userPhone;
                      print("4 meeting room is ${meetingRoom}");
                    }
                  }// //super if

                  _joinMeeting(meetingRoom,widget.userPhone);
                }
            )
        ),
      ),
    );
  }

  Widget meetConfig() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          TextField(
            controller: serverText,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Server URL",
                hintText: "Hint: Leave empty for meet.jitsi.si"),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: roomText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Room",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: subjectText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Subject",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: nameText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Display Name",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: emailText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Email",
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          TextField(
            controller: iosAppBarRGBAColor,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "AppBar Color(IOS only)",
                hintText: "Hint: This HAS to be in HEX RGBA format"),
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Audio Only"),
            value: isAudioOnly,
            onChanged: _onAudioOnlyChanged,
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Audio Muted"),
            value: isAudioMuted,
            onChanged: _onAudioMutedChanged,
          ),
          SizedBox(
            height: 14.0,
          ),
          CheckboxListTile(
            title: Text("Video Muted"),
            value: isVideoMuted,
            onChanged: _onVideoMutedChanged,
          ),
          Divider(
            height: 48.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 64.0,
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () {
             //   _joinMeeting();
              },
              child: Text(
                "Call Now",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStateColor.resolveWith((states) => Colors.blue)),
            ),
          ),
          SizedBox(
            height: 48.0,
          ),
        ],
      ),
    );
  }

  _onAudioOnlyChanged(bool? value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool? value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool? value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinMeeting(String room,String personalNumber) async {
    String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    // Enable or disable any feature flag here
    // If feature flag are not provided, default values will be used
    // Full list of feature flags (and defaults) available in the README
    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };
    if (!kIsWeb) {
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
    }
    // Define meetings options here
    var options = JitsiMeetingOptions(room: room)
      ..serverURL = "https://server12-3.okitelecom.com/"
      ..subject = "OKITELE Call"
      ..userDisplayName = personalNumber
      ..userEmail = personalNumber+"@gmail.com"
      ..iosAppBarRGBAColor = iosAppBarRGBAColor.text
      ..audioOnly = isAudioOnly
      ..audioMuted = isAudioMuted
      ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": roomText.text,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": nameText.text}
      };

    debugPrint("JitsiMeetingOptions: $options");
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}