# PinPut

🔥🚀
Flutter package to create Pin code input text field with every pixel customization possibility 🎨 with beautiful animations

## Enhanced Documentation coming soon 🔥

## Breaking changes in version 0.2.0-dev.1 changed widget building logic so now it supports:
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

Use `submittedFieldDecoration`, `selectedFieldDecoration`, `followingFieldDecoration`,
properties to add field decoration, border, fill color, shape, radius etc.  
provide different values to them in order to achieve nice implicit animations

<img  src="https://raw.githubusercontent.com/Tkko/Flutter_PinPut/master/example/media/new_pinput_demo_1.gif"  alt="drawing"  width="220"/>
First example configuration
```
BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15),
    );
}

PinPut(
    fieldsCount: 5,
    onSubmit: (String pin) => print(pin),
    focusNode: _pinPutFocusNode,
    controller: _pinPutController,
    submittedFieldDecoration: _pinPutDecoration.copyWith(
        borderRadius: BorderRadius.circular(20)),
    selectedFieldDecoration: _pinPutDecoration,
    followingFieldDecoration: _pinPutDecoration.copyWith(
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: Colors.deepPurpleAccent.withOpacity(.5),
      ),
    ),
  )
```



### Installation

Install the latest version [from pub](https://pub.dartlang.org/packages/pinput).

## Properties

    @required this.fieldsCount,
    this.onSubmit,
    this.onSaved,
    this.onChanged,
    this.onTap,
    this.onClipboardFound,
    this.controller,
    this.focusNode,
    this.textStyle,
    this.submittedFieldDecoration,
    this.selectedFieldDecoration,
    this.followingFieldDecoration,
    this.disabledDecoration,
    this.eachFieldWidth,
    this.eachFieldHeight,
    this.fieldsAlignment = MainAxisAlignment.spaceBetween,
    this.eachFieldMargin,
    this.eachFieldPadding,
    this.eachFieldConstraints =
        const BoxConstraints(minHeight: 40, minWidth: 40),
    this.inputDecoration = const InputDecoration(
      contentPadding: EdgeInsets.all(0),
      border: InputBorder.none,
      counterText: '',
    ),
    this.animationCurve = Curves.linear,
    this.animationDuration = const Duration(milliseconds: 160),
    this.pinAnimationType = PinAnimationType.slide,
    this.slideTransitionBeginOffset,
    this.enabled = true,
    this.autofocus = false,
    this.autoValidate = false,
    this.keyboardAppearance,
    this.inputFormatters,
    this.validator,
    this.keyboardType = TextInputType.number,
    this.obscureText,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.toolbarOptions,

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