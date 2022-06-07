import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyAppTest extends StatefulWidget {
  final String dat;
  const MyAppTest(this.dat, {Key? key}) : super(key: key);

  @override
  State<MyAppTest> createState() => _MyAppTestState();
}

class _MyAppTestState extends State<MyAppTest> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      child: Text("OKeeeeee")

    );
  }

}