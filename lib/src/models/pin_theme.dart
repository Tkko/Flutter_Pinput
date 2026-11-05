part of '../pinput.dart';

/// Resolves the [PinTheme] of a pin item from the item (its index, value and
/// state) and the app-supplied validation state.
typedef PinThemeResolver =
    PinTheme Function(PinItemState item, PinputValidationState validation);

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

  ///  Decoration of each pin item, for example a [BoxDecoration] or a
  ///  [ShapeDecoration]. You can customize every pixel with it.
  ///  Properties are being animated implicitly when the value changes.
  ///  The [BoxDecoration] properties are:
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
  final Decoration? decoration;

  /// Widget displayed in an empty pin that does not show the cursor.
  final Widget? placeholder;

  /// Defines how content within the pin container is aligned.
  final AlignmentGeometry? alignment;

  /// The built-in theme used when no [Pinput.theme] is set. Derive from it with
  /// [copyWith] to change only part of the default look.
  static const PinTheme defaults = PinTheme(
    width: 56,
    height: 60,
    textStyle: TextStyle(),
    decoration: PinputConstants._defaultPinputDecoration,
  );

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
    this.alignment,
  });

  /// Create a new [PinTheme] from the current instance
  PinTheme copyWith({
    double? width,
    double? height,
    TextStyle? textStyle,
    BoxConstraints? constraints,
    Decoration? decoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Widget? placeholder,
    AlignmentGeometry? alignment,
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
      alignment: alignment ?? this.alignment,
    );
  }

  /// Create a new [PinTheme] from the current instance with new decoration.
  /// Requires [decoration] to be a [BoxDecoration].
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
    assert(
      decoration is BoxDecoration,
      'copyDecorationWith requires a BoxDecoration',
    );
    return copyWith(
      decoration: (decoration as BoxDecoration).copyWith(
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

  /// Create a new [PinTheme] from the current instance with new border.
  /// Requires [decoration] to be a [BoxDecoration].
  PinTheme copyBorderWith({required Border border}) {
    assert(
      decoration is BoxDecoration,
      'copyBorderWith requires a BoxDecoration',
    );
    return copyWith(
      decoration: (decoration as BoxDecoration).copyWith(border: border),
    );
  }
}

/// Themes of the pin items, resolved per [PinItemStateType].
///
/// Mirrors [WidgetStateProperty]:
/// ```dart
/// Pinput(
///   theme: PinThemes(fallback: base, focused: focused, error: error),
/// )
///
/// Pinput(
///   theme: PinThemes.resolveWith((item, validation) => switch (item.type) {
///     PinItemStateType.focused => focused,
///     PinItemStateType.submitted => base,
///     PinItemStateType.following => base,
///     PinItemStateType.disabled => base,
///     PinItemStateType.error => error,
///   }),
/// )
/// ```
///
/// Implement this class to share a theme as your own type; only [resolve] is
/// required.
// ignore: one_member_abstracts
abstract class PinThemes {
  /// Abstract const constructor for subclasses.
  const PinThemes._();

  /// Uses the theme for each state, falling back to [fallback] (or
  /// [PinTheme.defaults] when null) for states you leave out. A state theme is
  /// used exactly as written and is not merged with [fallback], so derive it
  /// with [PinTheme.copyWith].
  ///
  /// [valid] and [validating] apply to every pin that is not disabled or in the
  /// error state while the app supplies [PinputValidationState.valid] or
  /// [PinputValidationState.validating]. When they are null, validation does not
  /// change the look of the pins.
  const factory PinThemes({
    PinTheme? fallback,
    PinTheme? focused,
    PinTheme? submitted,
    PinTheme? following,
    PinTheme? disabled,
    PinTheme? error,
    PinTheme? valid,
    PinTheme? validating,
  }) = _PinThemesNamed;

  /// Resolves the theme with [callback]. Use a `switch` without a wildcard to
  /// get compile-time exhaustiveness over [PinItemStateType].
  const factory PinThemes.resolveWith(PinThemeResolver callback) =
      _PinThemesResolveWith;

  /// Uses [theme] in every state.
  const factory PinThemes.all(PinTheme theme) = _PinThemesAll;

  /// Returns the theme for [item] under the current [validation] state.
  PinTheme resolve(PinItemState item, PinputValidationState validation);
}

class _PinThemesResolveWith extends PinThemes {
  const _PinThemesResolveWith(this._callback) : super._();

  final PinThemeResolver _callback;

  @override
  PinTheme resolve(PinItemState item, PinputValidationState validation) =>
      _callback(item, validation);
}

class _PinThemesAll extends PinThemes {
  const _PinThemesAll(this._theme) : super._();

  final PinTheme _theme;

  @override
  PinTheme resolve(PinItemState item, PinputValidationState validation) =>
      _theme;
}

class _PinThemesNamed extends PinThemes {
  const _PinThemesNamed({
    this.fallback,
    this.focused,
    this.submitted,
    this.following,
    this.disabled,
    this.error,
    this.valid,
    this.validating,
  }) : super._();

  final PinTheme? fallback;
  final PinTheme? focused;
  final PinTheme? submitted;
  final PinTheme? following;
  final PinTheme? disabled;
  final PinTheme? error;
  final PinTheme? valid;
  final PinTheme? validating;

  @override
  PinTheme resolve(PinItemState item, PinputValidationState validation) {
    final type = item.type;
    if (type != PinItemStateType.disabled && type != PinItemStateType.error) {
      final feedback = switch (validation) {
        PinputValidationValid() => valid,
        PinputValidationValidating() => validating,
        _ => null,
      };
      if (feedback != null) return feedback;
    }
    final theme = switch (type) {
      PinItemStateType.focused => focused,
      PinItemStateType.submitted => submitted,
      PinItemStateType.following => following,
      PinItemStateType.disabled => disabled,
      PinItemStateType.error => error,
    };
    return theme ?? fallback ?? PinTheme.defaults;
  }
}
