# PinPut

🔥🚀
Flutter package to create Pin code input text field with every pixel customization possibility 🎨 with beautiful animations

## Enhanced Documentation coming soon 🔥

## Breaking changes in version 0.2.0 changed widget building logic so now it supports:
-    Backspace on keyboard
-    Every pixel customization
-    Nice animations
-    Form validation
-    Ios auto fill - testing needed

## Contents

- [Overview](#overview)

- [Installation](#installation)

- [Properties](#properties)

- [Example](#example)

- [Contribute](#contribute)

## Overview

This widget keeps whole width of parent widget and layouts textfields in a way to create PIN code input field look it accepts string of any length and calls the onSubmit method when all fields are filled.

<img  src="https://raw.githubusercontent.com/Tkko/Flutter_PinPut/master/example/media/new_pinput_demo.gif"  alt="drawing"  width="180"/>

### Installation

Install the latest version [from pub](https://pub.dartlang.org/packages/pinput).

## Properties

    @required this.fieldsCount,
    @required this.onSubmit,
    this.animationCurve = Curves.linear,
    this.fieldMargin,
    this.fieldPadding,
    this.fieldConstraints = const BoxConstraints(minHeight: 40, minWidth: 40),
    this.animationDuration = const Duration(milliseconds: 160),
    this.autoFocus = false,
    this.controller,
    this.enabled = true,
    this.submittedFieldDecoration,
    this.selectedFieldDecoration,
    this.pinAnimationType = PinAnimationType.slide,
    this.followingFieldDecoration,
    this.disabledDecoration,
    this.focusNode,
    this.inputDecoration = const InputDecoration(
      contentPadding: EdgeInsets.all(0),
      border: InputBorder.none,
      counterText: '',
    ),
    this.inputFormatters,
    this.keyboardAppearance,
    this.keyboardType = TextInputType.number,
    this.obscureText,
    this.onChanged,
    this.onTap,
    this.slideTransitionBeginOffset,
    this.onClipboardFound,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.textStyle = const TextStyle(fontSize: 30),
    this.fieldsAlignment = MainAxisAlignment.spaceBetween,
    this.toolbarOptions,
    this.onSaved,
    this.validator,
    this.autoValidate = false,

## Example

Import the package:

```dart
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

void main() => runApp(PinPutTest());

class PinPutTest extends StatefulWidget {
  @override
  PinPutTestState createState() => PinPutTestState();
}

class PinPutTestState extends State<PinPutTest> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showSemanticsDebugger: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        hintColor: Colors.green,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Center(
                        child: PinPut(
                          fieldsCount: 5,
                          autoFocus: false,
                          controller: _pinPutController,
                          onSubmit: (String pin) => _showSnackBar(pin, context),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          child: Text('Unfocus'),
                          onPressed: () => FocusScope.of(context).unfocus(),
                        ),
                        RaisedButton(
                          child: Text('Focus'),
                          onPressed: () {
                            FocusScope.of(context)
                                .requestFocus(_pinPutFocusNode);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

```

## 👍 Support

## Contribute

1. Fork it

2. Create your feature branch (git checkout -b my-new-feature)

3. Commit your changes (git commit -am 'Add some feature')

4. Push to the branch (git push origin my-new-feature)

5. Create new Pull Request