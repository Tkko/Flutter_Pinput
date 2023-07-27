part of '../pinput.dart';

/// The constant values for Pinput
class PinputConstants {
  const PinputConstants._();

  /// The default value [Pinput.smsCodeMatcher]
  static const defaultSmsCodeMatcher = '\\d{4,7}';

  /// The default value [Pinput.animationDuration]
  static const _animationDuration = Duration(milliseconds: 180);

  /// The default value [Pinput.length]
  static const _defaultLength = 4;

  static const _defaultSeparator = SizedBox(width: 8);

  /// The hidden text under the Pinput
  static const _hiddenTextStyle =
      TextStyle(fontSize: 1, height: 1, color: Colors.transparent);

  ///
  static const _defaultPinFillColor = Color.fromRGBO(222, 231, 240, .57);
  static const _defaultPinputDecoration = BoxDecoration(
    color: _defaultPinFillColor,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  /// The default value [Pinput.defaultPinTheme]
  static const _defaultPinTheme = PinTheme(
    width: 56,
    height: 60,
    textStyle: TextStyle(),
    decoration: _defaultPinputDecoration,
  );
}
