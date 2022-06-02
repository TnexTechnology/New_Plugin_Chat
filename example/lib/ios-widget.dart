
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tnexchat/tnexchat.dart';
import 'package:tnexchat/tnexchat.dart';


class MyPluginAppTest extends StatefulWidget {
  const MyPluginAppTest({Key? key}) : super(key: key);

  @override
  State<MyPluginAppTest> createState() => _MyPluginTestState();
}

class _MyPluginTestState extends State<MyPluginAppTest> {

  @override
  Widget build(BuildContext context) {
    const String viewType = '<platform-view-type>';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    return Scaffold(
      appBar: AppBar(
        title: Text("Native OS")
      ),
      //
      body: MyPluginAppTest()
    );
  }
}

class TogetherWidget extends StatelessWidget {
  const TogetherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = '<platform-view-type>';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}