import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

void main() => runApp(PinPutTest());

class PinPutTest extends StatefulWidget {
  @override
  PinPutTestState createState() => PinPutTestState();
}

class PinPutTestState extends State<PinPutTest> {
  bool _unFocus = false;

  @override
  void initState() {
    setTimeOut();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.green,
          hintColor: Colors.green,
        ),
        home: Scaffold(
            body: Builder(
          builder: (context) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Center(
                  child: PinPut(
                    fieldsCount: 5,
                    unFocusWhen: _unFocus,
                    onSubmit: (String pin) => _showSnackBar(pin, context),
                  ),
                ),
              ),
        )));
  }

  void _showSnackBar(String pin, BuildContext context) {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: Container(
          height: 80.0,
          child: Center(
            child: Text(
              'Pin Submitted. Value: $pin',
              style: TextStyle(fontSize: 25.0),
            ),
          )),
      backgroundColor: Colors.greenAccent,
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void setTimeOut() {
    Stream<void>.periodic(Duration(seconds: 5)).listen((r) {
      setState(() {
        _unFocus = !_unFocus;
      });
    });
  }
}
