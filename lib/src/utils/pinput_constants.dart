part of '../pinput.dart';

/// The constant values for Pinput
class PinputConstants {
  const PinputConstants._();

  /// The default value [Pinput.animationDuration]
  static const _animationDuration = Duration(milliseconds: 180);

  /// The default value [Pinput.length]
  static const _defaultLength = 4;

  static const _defaultSeparator = SizedBox(width: 8);

  static const _transparent = Color(0x00000000);

  // Error text colors
  static const _defaultLightErrorColor = Color(0xFFB00020);
  static const _defaultDarkErrorColor = Color(0xFFCF6679);

  // Context menu colors
  static const _menuDarkBackground = Color(0xFF2A2A2A);
  static const _menuLightBackground = Color(0xFFFFFFFF);
  static const _menuDarkForeground = Color(0xFFFFFFFF);
  static const _menuLightForeground = Color(0xFF000000);
  static const _menuDarkShadow = Color(0x66000000);
  static const _menuLightShadow = Color(0x26000000);
  static const _menuDarkHighlight = Color(0x1FFFFFFF);
  static const _menuLightHighlight = Color(0x14000000);

  /// The hidden text under the Pinput
  static const _hiddenTextStyle = TextStyle(
    fontSize: 1,
    height: 1,
    color: _transparent,
  );

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
