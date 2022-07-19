
import 'dart:async';

import 'package:flutter/services.dart';

class Tnexchat {
  static Tnexchat? _instance;
  static get instance => _instance ??= Tnexchat._();
  Tnexchat._() {
    _channel.setMethodCallHandler(_fromNative);
  }
  static const MethodChannel _channel = MethodChannel('tnexchat');

  static void Function(MethodCall call)? callback;

  static Future<void> _fromNative(MethodCall call) async {
    if (call.method == 'getPlatformVersion') {
      print('callTest result = ${call.arguments}');
    }
    if (callback != null) {
      callback!(call);
    }
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> platformVersionWithParams(dynamic method) async {
    final String? version = await _channel.invokeMethod('getPlatformVersion', method);
    return version;
  }

  static Future<bool> initMatrixWithToken(dynamic method) async {
    _channel.setMethodCallHandler(_fromNative);
    final bool isSuccess = await _channel.invokeMethod('initMatrixWithToken', method);
    return isSuccess;
  }

  static Future<bool> updateUserUploadInfo(dynamic method) async {
    final bool isSuccess = await _channel.invokeMethod('updateUserUploadInfo', method);
    return isSuccess;
  }

  static Future<bool> updateUserUploadToken(dynamic method) async {
    final bool isSuccess = await _channel.invokeMethod('updateUserUploadToken', method);
    return isSuccess;
  }

  static Future<String> openRoomWithId(dynamic method) async {
    final String userID = await _channel.invokeMethod('openRoomWithId', method);
    return userID;
  }
}
