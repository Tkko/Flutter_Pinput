# PinPut

100% Dart based and lightweight PIN input field widget for Flutter

## Contents

- [Overview](#overview)

- [Installation](#installation)

- [Properties](#properties)

- [Example](#example)

- [Contribute](#contribute)

## Overview

This widget keeps whole width of parent widget and layouts textfields in a way to create PIN code input field look it accepts string of any length and calls the onSubmit method when all fields are filled.

<img  src="https://raw.githubusercontent.com/Tkko/Flutter_PinPut/master/example/pinput_demo.gif"  alt="drawing"  width="180"/>

### Installation

Install the latest version [from pub](https://pub.dartlang.org/packages/pinput).

## Properties

| Property | Default |

|------------|:---------------------:|

| onSubmit | Function |

| fieldsCount | 4 |

| isTextObscure | false |

| fontSize | 40.0 |

| borderRadius | 5.0 |

| keybaordType | number |

| keyboardAction | next |

## Example

Import the package:

```dart

import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

void main() => runApp(PinPutTest());

class PinPutTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.green,
          hintColor: Colors.green,
        ),
        home: Scaffold(
            body: Builder(
          builder: (context) => Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: PinPut(
                    fieldsCount: 4,
                    onSubmit: (String pin) => _showSnackBar(pin, context),
                  ),
                ),
              ),
        )));
  }

  void _showSnackBar(String pin, BuildContext context) {
    final snackBar = SnackBar(
      duration: Duration(seconds: 5),
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
}
```

## 👍 Support

## Contribute

1. Fork it

2. Create your feature branch (git checkout -b my-new-feature)

3. Commit your changes (git commit -am 'Add some feature')

4. Push to the branch (git push origin my-new-feature)

5. Create new Pull Request