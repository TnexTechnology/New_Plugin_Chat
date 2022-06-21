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
  Function(List<RoomModel>)? _handleRooms = null;
  List<RoomModel> _rooms = [];

  static final ChatIOSNative _singleton = ChatIOSNative._internal();
  ChatIOSNative._internal() {
    handleMethod();
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }
  factory ChatIOSNative() {
    return _singleton;
  }

  void _onEvent(dynamic event) {
    final eventDic = Map.from(event);
    if (eventDic["roomId"] != null)  {
      //Can toi uu lai cho nay -> Tu tinh toan va sap xep lai data
    final String roomId = eventDic["roomId"];
    final index = this._rooms.indexWhere((room) {
      return room.id == roomId;
    });
    if (index == null || eventDic["roomInfo"] == null) {
      //Cuoc hoi thoai moi hoac khong xac dinh thi reload lai list rooms
      print("khong dc");
      print("$index");
      _chatChannel.invokeMethod('rooms');
      return;
    }
    final roomDic = Map.from(eventDic["roomInfo"]);
    final roomModel = _convertDicToRoom(roomDic);
    if (index == 0) {
      _rooms[0] = roomModel;
    } else {
      _rooms.removeAt(index);
      _rooms.insert(0, roomModel);
    }
    print("reload okkkk!!!");
    _handleRooms!(_rooms);
    }
  }

  void _onError(Object error) {
    print("error!!!");
  }

  void getRooms(Function(List<RoomModel>) listrooms) async {
    _handleRooms = listrooms;
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
        for (final room in call.arguments) {
          final roomDic = Map.from(room);
          final roomModel = _convertDicToRoom(roomDic);
          roomModels.add(roomModel);
        }
        _rooms = roomModels;
        if (_handleRooms != null) {
          _handleRooms!(roomModels);
        }
      }
    });
  }

  RoomModel _convertDicToRoom(Map<dynamic, dynamic> roomDic) {
    final roomModel = RoomModel(
      id: roomDic["id"],
      displayname: roomDic["displayname"],
      unreadCount: roomDic["unreadCount"],
      lastMessage: roomDic["lastMessage"],
      timeCreated: roomDic["timeCreated"],
      avatarUrl: roomDic["avatarUrl"],
    );
    return roomModel;
  }

}