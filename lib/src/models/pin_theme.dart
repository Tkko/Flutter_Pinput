part of '../pinput.dart';

/// Resolves the [PinTheme] of a pin item from its state.
typedef PinThemeResolver = PinTheme Function(PinItemStateType state);

/// Theme of the individual pin items for each [PinItemStateType].
class PinTheme {
  /// width of each [Pinput] field
  final double? width;

  /// height of each [Pinput] field
  final double? height;

  /// The style to use for PinPut
  /// If null, defaults to the `subhead` text style from the current [Theme].
  final TextStyle? textStyle;

  /// Empty space to surround the [Pinput] field container.
  final EdgeInsetsGeometry? margin;

  /// Empty space to inscribe the [Pinput] field container.
  /// For example space between border and text
  final EdgeInsetsGeometry? padding;

  /// Additional constraints to apply to the each field container.
  /// properties
  /// ```dart
  ///  this.minWidth = 0.0,
  ///  this.maxWidth = double.infinity,
  ///  this.minHeight = 0.0,
  ///  this.maxHeight = double.infinity,
  ///  ```
  final BoxConstraints? constraints;

  ///  Box decoration of following properties of Pin item
  ///  You can customize every pixel with it
  ///  properties are being animated implicitly when value changes
  ///  ```dart
  ///  this.color,
  ///  this.image,
  ///  this.border,
  ///  this.borderRadius,
  ///  this.boxShadow,
  ///  this.gradient,
  ///  this.backgroundBlendMode,
  ///  this.shape = BoxShape.rectangle,
  ///  ```
  /// The decoration of each [Pinput] submitted field
  final BoxDecoration? decoration;

  /// Widget displayed in an empty pin that does not show the cursor.
  final Widget? placeholder;

  /// Theme of the individual pin items for each [PinItemStateType].
  const PinTheme({
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.textStyle,
    this.decoration,
    this.constraints,
    this.placeholder,
  });

  /// Merge two [PinTheme] into one
  PinTheme apply({required PinTheme theme}) {
    return PinTheme(
      width: this.width ?? theme.width,
      height: this.height ?? theme.height,
      textStyle: this.textStyle ?? theme.textStyle,
      constraints: this.constraints ?? theme.constraints,
      decoration: this.decoration ?? theme.decoration,
      padding: this.padding ?? theme.padding,
      margin: this.margin ?? theme.margin,
      placeholder: this.placeholder ?? theme.placeholder,
    );
  }

  /// Create a new [PinTheme] from the current instance
  PinTheme copyWith({
    double? width,
    double? height,
    TextStyle? textStyle,
    BoxConstraints? constraints,
    BoxDecoration? decoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Widget? placeholder,
  }) {
    return PinTheme(
      width: width ?? this.width,
      height: height ?? this.height,
      textStyle: textStyle ?? this.textStyle,
      constraints: constraints ?? this.constraints,
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      placeholder: placeholder ?? this.placeholder,
    );
  }

  /// Create a new [PinTheme] from the current instance with new decoration
  PinTheme copyDecorationWith({
    Color? color,
    DecorationImage? image,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape? shape,
  }) {
    assert(decoration != null);
    return copyWith(
      decoration: decoration?.copyWith(
        color: color,
        image: image,
        border: border,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        gradient: gradient,
        backgroundBlendMode: backgroundBlendMode,
        shape: shape,
      ),
    );
  }

  /// Create a new [PinTheme] from the current instance with new border
  PinTheme copyBorderWith({required Border border}) {
    assert(decoration != null);
    return copyWith(decoration: decoration?.copyWith(border: border));
  }
}

/// Themes of the pin items, resolved per [PinItemStateType].
///
/// Mirrors [WidgetStateProperty]:
/// ```dart
/// Pinput(
///   theme: PinThemes(initial: base, focused: focused, error: error),
/// )
///
/// Pinput(
///   theme: PinThemes.resolveWith((state) => switch (state) {
///     PinItemStateType.initial => base,
///     PinItemStateType.focused => focused,
///     PinItemStateType.submitted => base,
///     PinItemStateType.following => base,
///     PinItemStateType.disabled => base,
///     PinItemStateType.error => error,
///   }),
/// )
/// ```
// ignore: one_member_abstracts
abstract class PinThemes {
  /// Abstract const constructor for subclasses.
  const PinThemes._();

  /// Uses the theme for each state, falling back to [initial] (then the
  /// built-in theme). States are not merged: a state theme replaces the initial
  /// one, so derive it with [PinTheme.copyWith].
  const factory PinThemes({
    PinTheme? initial,
    PinTheme? focused,
    PinTheme? submitted,
    PinTheme? following,
    PinTheme? disabled,
    PinTheme? error,
  }) = _PinThemesNamed;

  /// Resolves the theme with [callback]. Use a `switch` without a wildcard to
  /// get compile-time exhaustiveness over [PinItemStateType].
  const factory PinThemes.resolveWith(PinThemeResolver callback) =
      _PinThemesResolveWith;

  /// Uses [theme] in every state.
  const factory PinThemes.all(PinTheme theme) = _PinThemesAll;

  /// Returns the theme for [state].
  PinTheme resolve(PinItemStateType state);
}

class _PinThemesResolveWith extends PinThemes {
  const _PinThemesResolveWith(this._callback) : super._();

  final PinThemeResolver _callback;

  @override
  PinTheme resolve(PinItemStateType state) => _callback(state);
}

class _PinThemesAll extends PinThemes {
  const _PinThemesAll(this._theme) : super._();

  final PinTheme _theme;

  @override
  PinTheme resolve(PinItemStateType state) => _theme;
}

class _PinThemesNamed extends PinThemes {
  const _PinThemesNamed({
    this.initial,
    this.focused,
    this.submitted,
    this.following,
    this.disabled,
    this.error,
  }) : super._();

  final PinTheme? initial;
  final PinTheme? focused;
  final PinTheme? submitted;
  final PinTheme? following;
  final PinTheme? disabled;
  final PinTheme? error;

  @override
  PinTheme resolve(PinItemStateType state) {
    final theme = switch (state) {
      PinItemStateType.initial => initial,
      PinItemStateType.focused => focused,
      PinItemStateType.submitted => submitted,
      PinItemStateType.following => following,
      PinItemStateType.disabled => disabled,
      PinItemStateType.error => error,
    };
    return theme ?? initial ?? PinputConstants._defaultPinTheme;
  }
}
