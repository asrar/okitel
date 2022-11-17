//*************   © Copyrighted by OkiTel. An Exclusive item of Kostricani. *********************

import 'package:flutter/foundation.dart';

class CurrentChatPeer with ChangeNotifier {
  String? peerid = '';
  String? groupChatId = '';

  setpeer({
    String? newpeerid,
    String? newgroupChatId,
  }) {
    peerid = newpeerid ?? peerid;
    groupChatId = newgroupChatId ?? groupChatId;
    notifyListeners();
  }
}
