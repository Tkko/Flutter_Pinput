part of '../pinput.dart';

/// The constant values for Pinput
class _PinputConstants {
  const _PinputConstants._();

  /// The default value [PinAnimation.duration]
  static const _animationDuration = Duration(milliseconds: 180);

  /// The default blink interval of [PinCursor.blinking]
  static const _cursorBlinkDuration = Duration(milliseconds: 450);

  /// The default value [Pinput.length]
  static const _defaultLength = 6;

  static const _defaultSeparator = SizedBox(width: 8);

  static const _transparent = Color(0x00000000);

  // Error text colors (modern, clean, accessible contrast)
  static const _defaultLightErrorColor = Color(0xFFDC2626);
  static const _defaultDarkErrorColor = Color(0xFFF87171);

  // Context menu colors (clean minimalist floating popover palette)
  static const _menuDarkBackground = Color(0xFF1E1E20);
  static const _menuLightBackground = Color(0xFFFFFFFF);
  static const _menuDarkForeground = Color(0xFFFFFFFF);
  static const _menuLightForeground = Color(0xFF1C1C1E);
  static const _menuDarkBorder = Color(0x33FFFFFF);
  static const _menuLightBorder = Color(0x1F000000);
  static const _menuDarkShadow = Color(0x80000000);
  static const _menuLightShadow = Color(0x1A000000);
  static const _menuDarkHighlight = Color(0x1FFFFFFF);
  static const _menuLightHighlight = Color(0x0F000000);

  /// The hidden text under the Pinput
  static const _hiddenTextStyle = TextStyle(
    fontSize: 1,
    height: 1,
    color: _transparent,
  );

  ///
  static const _defaultPinFillColor = Color.fromRGBO(222, 231, 240, .57);
  static const _defaultPinRadius = BorderRadius.all(Radius.circular(8));
  static const _defaultFocusColor = Color(0xFF64748B);
  static const _defaultDisabledFillColor = Color.fromRGBO(222, 231, 240, .25);
  static const _defaultDisabledTextColor = Color(0xFF94A3B8);

  static const _defaultPinputDecoration = BoxDecoration(
    color: _defaultPinFillColor,
    borderRadius: _defaultPinRadius,
  );
  static const _defaultFocusedDecoration = BoxDecoration(
    color: _defaultPinFillColor,
    borderRadius: _defaultPinRadius,
    border: Border.fromBorderSide(
      BorderSide(color: _defaultFocusColor, width: 1.5),
    ),
  );
  static const _defaultDisabledDecoration = BoxDecoration(
    color: _defaultDisabledFillColor,
    borderRadius: _defaultPinRadius,
  );
  static const _defaultErrorDecoration = BoxDecoration(
    color: _defaultPinFillColor,
    borderRadius: _defaultPinRadius,
    border: Border.fromBorderSide(
      BorderSide(color: _defaultLightErrorColor, width: 1.5),
    ),
  );
}
