
import 'dart:async';

import 'package:flutter/services.dart';

class Tnexchat {
  static const MethodChannel _channel = MethodChannel('tnexchat');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> platformVersionWithParams(dynamic method) async {
    final String? version = await _channel.invokeMethod('getPlatformVersion', method);
    return version;
  }

  static Future<bool> initMatrixWithToken(dynamic method) async {
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
