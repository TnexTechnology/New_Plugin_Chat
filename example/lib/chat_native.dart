import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ChatIOSNative native = new ChatIOSNative();

class ChatIOSNative {
  static const _methodChannel =
  const MethodChannel('tnex_chat');
  static const _tokenChannel =
  const MethodChannel('tnex_token');
  static const EventChannel _eventChannel =
  EventChannel('tnex_chat/refreshToken');
  static const _chatListChannel =
  const MethodChannel('tnex_chat_list');

  static final ChatIOSNative _singleton = ChatIOSNative._internal();
  ChatIOSNative._internal();

  factory ChatIOSNative() {
    return _singleton;
  }


  Future getRooms() async {
    try {
      final List<Object?> result = await _chatListChannel.invokeMethod('rooms');
      final numberItems = result.length;
      print('Resul getRooms: $numberItems');
    } on Exception catch (e) {
      print("Failed: ....");
    }
  }
}