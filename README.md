# PinPut

🔥🚀
Flutter package to create Pin code input text field with every pixel customization possibility 🎨 with beautiful animations

## Breaking changes in version 0.2.0+ changed widget building logic so now it supports:
-    Backspace on keyboard
-    Every pixel customization
-    Nice animations
-    Form validation
-    Ios auto fill - testing needed
-    PreFilledSymbol

## Contents

- [Support](#support)

- [Contribute](#contribute)

- [Overview](#overview)

- [Installation](#installation)

- [Properties](#properties)

- [Example](#example)


## Support
First thing first give it a star ⭐

Discord [Channel](https://discord.gg/ssE8eh)


## Contribute

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## Overview

Use `submittedFieldDecoration`, `selectedFieldDecoration`, `followingFieldDecoration`
properties to add field decoration, border, fill color, shape, radius etc.
provide different values to them in order to achieve nice implicit animations

<img src="https://raw.githubusercontent.com/Tkko/Flutter_PinPut/master/example/media/all_pin_put_demo.gif" width="300em" /><img src="https://raw.githubusercontent.com/Tkko/Flutter_PinPut/master/example/media/pin_put_demo_1.gif" width="300em" /><img src="https://raw.githubusercontent.com/Tkko/Flutter_PinPut/master/example/media/pin_put_demo_2.gif" width="300em" />
<img src="https://raw.githubusercontent.com/Tkko/Flutter_PinPut/master/example/media/pin_put_demo_3.gif" width="300em" />
<img src="https://raw.githubusercontent.com/Tkko/Flutter_PinPut/master/example/media/pin_put_demo_4.gif" width="300em" />


## Installation


### 1. Depend on it
Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  pinput: ^0.2.0
```

### 2. Install it

You can install packages from the command line:

with `pub`:

```css
$ pub get
```

with `Flutter`:

```css
$ flutter packages get
```

### 3. Import it

Now in your `Dart` code, you can use:

```dart
import 'package:pinput/pin_put/pin_put.dart';
```



## Properties

     @required this.fieldsCount,
    this.onSubmit,
    this.onSaved,
    this.onChanged,
    this.onTap,
    this.onClipboardFound,
    this.controller,
    this.focusNode,
    this.preFilledChar,
    this.preFilledCharStyle,
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

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        hintColor: Colors.green,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(
          builder: (context) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(20),
                      child: PinPut(
                        fieldsCount: 5,
                        onSubmit: (String pin) => _showSnackBar(pin, context),
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
                      ),
                    ),
                    SizedBox(height: 30),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton(
                          child: Text('Focus'),
                          onPressed: () => _pinPutFocusNode.requestFocus(),
                        ),
                        FlatButton(
                          child: Text('Unfocus'),
                          onPressed: () => _pinPutFocusNode.unfocus(),
                        ),
                        FlatButton(
                          child: Text('Clear All'),
                          onPressed: () => _pinPutController.text = '',
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
      backgroundColor: Colors.deepPurpleAccent,
    );
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

```

