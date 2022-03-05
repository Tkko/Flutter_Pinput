part of '../pinput.dart';

const _hiddenTextStyle = TextStyle(fontSize: 1, height: 1, color: Colors.transparent);

const _defaultPinFillColor = Color.fromRGBO(222, 231, 240, .57);

const _defaultPinputDecoration = BoxDecoration(
  color: _defaultPinFillColor,
  borderRadius: BorderRadius.all(Radius.circular(8)),
);

const _defaultPinTheme = PinTheme(
  width: 56,
  height: 60,
  textStyle: TextStyle(),
  decoration: _defaultPinputDecoration,
);
