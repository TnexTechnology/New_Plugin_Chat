import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tnexchat/tnexchat.dart';
import 'package:tnexchat_example/ios-widget.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  static const MethodChannel methodChannel =
      MethodChannel('samples.flutter.io/battery');
  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/charging');
  String _batteryLevel = 'Battery level: unknown.';
  String _chargingStatus = 'Battery status: unknown.';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await Tnexchat.platformVersionWithParams('olala') ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                child: const Text('Open route'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyAppTest()),
                  );
                },
              )
            ]
          )
        ),
      ),
    );
  }
// @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text(_batteryLevel, key: const Key('Battery level label')),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: ElevatedButton(
//                   onPressed: _getBatteryLevel,
//                   child: const Text('Refresh'),
//                 ),
//               ),
//             ],
//           ),
//           Text(_chargingStatus),
//         ],
//       ),
//     );
//   }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int? result = await methodChannel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level: $result%.';
      print('Battery level: $result%.');
    } on PlatformException {
      batteryLevel = 'Failed to get battery level.';
    }
    // setState(() {
    //   _batteryLevel = batteryLevel;
    // });
  }

  void _onEvent(Object? event) {
    // setState(() {
    //   _chargingStatus =
    //       "Battery status: ${event == 'charging' ? '' : 'dis'}charging.";
    //   print('Battery level: $_chargingStatus');
    //   _loginMatrixNative();
    // });
    _loginMatrixNative();
  }

  void _onError(Object error) {
    setState(() {
      _chargingStatus = 'Battery status: unknown.';
      print('1111Battery level: $_chargingStatus');
    });
  }
  Future _loginMatrixNative() async {
    try {
      final int result = await methodChannel.invokeMethod('getBatteryLevel', "matricInfo");
      print('Resul: $result');
    } on Exception catch (e) {
      print("Failed: ....");
    }
  }


}