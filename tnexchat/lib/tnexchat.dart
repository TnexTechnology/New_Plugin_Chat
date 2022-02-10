
import 'dart:async';

import 'package:flutter/services.dart';

class Tnexchat {
  static const MethodChannel _channel = MethodChannel('tnexchat');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
