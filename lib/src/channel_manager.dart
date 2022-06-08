import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ChatIOSNative native = new ChatIOSNative();

class ChatIOSNative {
  ChatIOSNative._();
  static final instance = ChatIOSNative._();
  static const _methodChannel =
  const MethodChannel('tnex_chat');
  static const _tokenChannel =
  const MethodChannel('tnex_token');
  static const EventChannel _eventChannel =
  EventChannel('tnex_chat/refreshToken');
  static const _chatListChannel =
  const MethodChannel('tnex_chat_list');

  Map<String, String> roomAvatarDic = <String, String>{};

  static final ChatIOSNative _singleton = ChatIOSNative._internal();
  ChatIOSNative._internal();

  factory ChatIOSNative() {
    return _singleton;
  }


  Future <List<Object?>> getRooms() async {
    handleMethod();
    var rooms;
    try {
      final List<Object?> result = await _chatListChannel.invokeMethod('rooms');
      rooms = result;
    } on Exception catch (e) {
      print("Failed: ....");
    }
    return rooms;
  }

  Future<void> gotoChatDetail(String roomId) async {
    handleMethod();
    try {
      final int result = await _methodChannel.invokeMethod('gotoChatDetail', roomId);
      print('Resul: $result');
    } on Exception catch (e) {
      print("gotoChatDetail: Failed: ....");
    }
  }

  Future<void> getMembersInRoom(String roomId) async {
    // handleMethod();
    try {
      await _chatListChannel.invokeMethod('members', roomId);
    } on Exception catch (e) {
      print("getMembersInRoom: Failed: ....");
    }
  }

  void handleMethod() {
    _methodChannel.setMethodCallHandler((call) async {
      if (call.method == "listMember") {
        final userId = call.arguments["avatarUrl"].toString();
        final roomId = call.arguments["roomId"].toString();
        roomAvatarDic[userId] = roomId;
        print("*******@@@@11111");
        print(userId);
        print(roomId);
      } if (call.method == "transfer") {
        // final mobile = call.arguments.toString();
        // _onTransfer(mobile);
      } else {
        throw Exception('not implemented ${call.method}');
      }
    });
  }
}