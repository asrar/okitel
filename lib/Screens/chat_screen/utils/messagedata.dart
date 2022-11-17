//*************   © Copyrighted by OkiTel. An Exclusive item of Kostricani. *********************

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageData {
  dynamic lastSeen;
  QuerySnapshot snapshot;

  MessageData({
    required this.snapshot,
    required this.lastSeen,
  });
}
