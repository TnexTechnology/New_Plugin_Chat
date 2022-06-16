import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './room_model.dart';
import 'dart:convert';

class ChatIOSNative {
  ChatIOSNative._();
  static final _instance = ChatIOSNative();
  static ChatIOSNative get instance => _instance;
  static const MethodChannel _chatChannel = MethodChannel('tnex_chat');
  static const EventChannel _eventChannel = EventChannel('event_room');

  Map<String, String> roomAvatarDic = <String, String>{};
  Function(List<RoomModel>)? _rooms = null;

  static final ChatIOSNative _singleton = ChatIOSNative._internal();
  ChatIOSNative._internal() {
    handleMethod();
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }
  factory ChatIOSNative() {
    return _singleton;
  }

  void _onEvent(Object? event) {
    final eventString = json.encode(event);
    final eventDic = json.decode(eventString);
    if (eventDic["event"] != null) {
      //Can toi uu lai cho nay -> Tu tinh toan va sap xep lai data
      _chatChannel.invokeMethod('rooms');
    }
  }

  void _onError(Object error) {
    print("error!!!");
  }

  void getRooms(Function(List<RoomModel>) listrooms) async {
    _rooms = listrooms;
    await _chatChannel.invokeMethod('rooms');
  }

  Future<void> gotoChatDetail(String roomId) async {
    await _chatChannel.invokeMethod('gotoChatDetail', roomId);
  }

  Future<void> getMembersInRoom(String roomId) async {
    await _chatChannel.invokeMethod('members', roomId);
  }

  void handleMethod() {
    _chatChannel.setMethodCallHandler((call) async {
      if (call.method == "rooms") {
        List<RoomModel> roomModels = [];
        final roomsNative = call.arguments;
        for (final room in roomsNative) {
          final roomString = json.encode(room);
          final roomDic = json.decode(roomString);
          final roomModel = RoomModel(
            id: roomDic["id"],
            displayname: roomDic["displayname"],
            unreadCount: roomDic["unreadCount"],
            lastMessage: roomDic["lastMessage"],
            timeCreated: roomDic["timeCreated"],
            avatarUrl: roomDic["avatarUrl"],
          );
          roomModels.add(roomModel);
        }
        if (_rooms != null) {
          _rooms!(roomModels);
        }
      }
    });
  }

}