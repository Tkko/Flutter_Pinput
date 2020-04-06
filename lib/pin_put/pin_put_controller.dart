import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PinPutController extends ValueNotifier<PinPutValue> {
  PinPutController({bool focused = false}) : super(PinPutValue());

  PinPutController.fromValue(PinPutValue value) : super(value ?? PinPutValue());

  void unFocus() {
    value.focused = false;
    notifyListeners();
  }

  void focus(int focusIndex) {
    value.focusIndex = focusIndex;
    notifyListeners();
    value.focusIndex = null;
  }

  @override
  String toString() {
    return 'PinPutController{ value ${value.toString()} }';
  }
}

class PinPutValue {
  bool focused;
  int focusIndex;

  PinPutValue();

  @override
  String toString() {
    return 'PinPutt{focused: $focused}';
  }
}
