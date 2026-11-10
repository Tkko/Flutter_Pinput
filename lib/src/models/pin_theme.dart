part of '../pinput.dart';

/// Resolves the [PinTheme] of a pin item from the item (its index, value and
/// state) and the app-supplied validation state.
typedef PinThemeResolver<T extends Decoration> =
    PinTheme<T> Function(PinItemState item, PinValidationState validation);

/// Theme of the individual pin items for each [PinItemStateType].
@immutable
class PinTheme<T extends Decoration> {
  /// width of each [Pinput] field
  final double? width;

  /// height of each [Pinput] field
  final double? height;

  /// The style of the pin content.
  /// If null, inherits the ambient [DefaultTextStyle].
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
  final T? decoration;

  /// Widget displayed in an empty pin that does not show the cursor.
  final Widget? placeholder;

  /// Defines how content within the pin container is aligned.
  final AlignmentGeometry? alignment;

  /// The built-in theme used when no [Pinput.theme] is set. Derive from it with
  /// [copyWith] to change only part of the default look.
  static const defaults = PinTheme(
    width: 56,
    height: 60,
    textStyle: TextStyle(),
    decoration: _PinputConstants._defaultPinputDecoration,
  );

  static const _defaultFocused = PinTheme(
    width: 56,
    height: 60,
    textStyle: TextStyle(),
    decoration: _PinputConstants._defaultFocusedDecoration,
  );

  static const _defaultDisabled = PinTheme(
    width: 56,
    height: 60,
    textStyle: TextStyle(color: _PinputConstants._defaultDisabledTextColor),
    decoration: _PinputConstants._defaultDisabledDecoration,
  );

  static const _defaultError = PinTheme(
    width: 56,
    height: 60,
    textStyle: TextStyle(),
    decoration: _PinputConstants._defaultErrorDecoration,
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

  /// Linearly interpolates between two themes. [placeholder] is not
  /// interpolated; it switches at the midpoint. If the decoration's
  /// interpolation returns a value outside [T], the decoration switches
  /// between the endpoints at the midpoint.
  static PinTheme<T>? lerp<T extends Decoration>(
    PinTheme<T>? a,
    PinTheme<T>? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    final decoration = Decoration.lerp(a?.decoration, b?.decoration, t);
    return PinTheme<T>(
      width: lerpDouble(a?.width, b?.width, t),
      height: lerpDouble(a?.height, b?.height, t),
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      textStyle: TextStyle.lerp(a?.textStyle, b?.textStyle, t),
      decoration: decoration is T
          ? decoration
          : t < 0.5
          ? a?.decoration
          : b?.decoration,
      constraints: BoxConstraints.lerp(a?.constraints, b?.constraints, t),
      placeholder: t < 0.5 ? a?.placeholder : b?.placeholder,
      alignment: AlignmentGeometry.lerp(a?.alignment, b?.alignment, t),
    );
  }

  /// Create a new [PinTheme] from the current instance
  PinTheme<T> copyWith({
    double? width,
    double? height,
    TextStyle? textStyle,
    BoxConstraints? constraints,
    T? decoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Widget? placeholder,
    AlignmentGeometry? alignment,
  }) {
    return PinTheme<T>(
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

  @override
  String toString() =>
      'PinTheme(width: $width, height: $height, textStyle: $textStyle, margin: $margin, padding: $padding, constraints: $constraints, decoration: $decoration, placeholder: $placeholder, alignment: $alignment)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinTheme &&
          width == other.width &&
          height == other.height &&
          margin == other.margin &&
          padding == other.padding &&
          textStyle == other.textStyle &&
          decoration == other.decoration &&
          constraints == other.constraints &&
          placeholder == other.placeholder &&
          alignment == other.alignment);

  @override
  int get hashCode => Object.hash(
    PinTheme,
    width,
    height,
    margin,
    padding,
    textStyle,
    decoration,
    constraints,
    placeholder,
    alignment,
  );
}

/// Provides the [PinThemes] of every descendant [Pinput] that has no
/// [Pinput.theme], so an app can style its pins in one place.
class DefaultPinThemes extends InheritedWidget {
  /// Creates a widget that provides [themes] to its descendants.
  const DefaultPinThemes({
    required this.themes,
    required super.child,
    super.key,
  });

  /// The themes of the descendant [Pinput] widgets.
  final PinThemes themes;

  /// The closest [themes] above [context], or null if there is none.
  static PinThemes? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DefaultPinThemes>()?.themes;

  @override
  bool updateShouldNotify(DefaultPinThemes oldWidget) =>
      themes != oldWidget.themes;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'DefaultPinThemes(themes: $themes)';
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
///     PinItemStateType.filled => base,
///     PinItemStateType.empty => base,
///     PinItemStateType.disabled => base,
///     PinItemStateType.error => error,
///   }),
/// )
/// ```
///
/// Implement this class to share a theme as your own type; only [resolve] is
/// required.
// ignore: one_member_abstracts
abstract class PinThemes<T extends Decoration> {
  /// Abstract const constructor for subclasses.
  const PinThemes._();

  /// Uses the theme for each state, falling back to [fallback] for states you
  /// leave out. Without a [fallback] the built-in look is used, which marks the
  /// focused, disabled and error states. A built-in decoration is included
  /// only when it matches [T]. A state theme is used exactly as written and is
  /// not merged with [fallback], so derive it with [PinTheme.copyWith].
  ///
  /// [valid] and [validating] apply to every pin that is not disabled or in the
  /// error state while the app supplies [PinValidationState.valid] or
  /// [PinValidationState.validating]. When they are null, validation does not
  /// change the look of the pins.
  const factory PinThemes({
    PinTheme<T>? fallback,
    PinTheme<T>? focused,
    PinTheme<T>? filled,
    PinTheme<T>? empty,
    PinTheme<T>? disabled,
    PinTheme<T>? error,
    PinTheme<T>? valid,
    PinTheme<T>? validating,
  }) = _PinThemesNamed<T>;

  /// Resolves the theme with [callback]. Use a `switch` without a wildcard to
  /// get compile-time exhaustiveness over [PinItemStateType].
  const factory PinThemes.resolveWith(PinThemeResolver<T> callback) =
      _PinThemesResolveWith<T>;

  /// Uses [theme] in every state, so focus, disabled input and errors do not
  /// change the look of the pins.
  const factory PinThemes.all(PinTheme<T> theme) = _PinThemesAll<T>;

  /// Returns the theme for [item] under the current [validation] state.
  PinTheme<T> resolve(PinItemState item, PinValidationState validation);
}

class _PinThemesResolveWith<T extends Decoration> extends PinThemes<T> {
  const _PinThemesResolveWith(this._callback) : super._();

  final PinThemeResolver<T> _callback;

  @override
  PinTheme<T> resolve(PinItemState item, PinValidationState validation) =>
      _callback(item, validation);

  @override
  String toString() => 'PinThemes.resolveWith(...)';
}

class _PinThemesAll<T extends Decoration> extends PinThemes<T> {
  const _PinThemesAll(this._theme) : super._();

  final PinTheme<T> _theme;

  @override
  PinTheme<T> resolve(PinItemState item, PinValidationState validation) =>
      _theme;

  @override
  bool operator ==(Object other) =>
      other is _PinThemesAll<T> &&
      runtimeType == other.runtimeType &&
      _theme == other._theme;

  @override
  int get hashCode => Object.hash(runtimeType, _theme);

  @override
  String toString() => 'PinThemes.all($_theme)';
}

class _PinThemesNamed<T extends Decoration> extends PinThemes<T> {
  const _PinThemesNamed({
    this.fallback,
    this.focused,
    this.filled,
    this.empty,
    this.disabled,
    this.error,
    this.valid,
    this.validating,
  }) : super._();

  final PinTheme<T>? fallback;
  final PinTheme<T>? focused;
  final PinTheme<T>? filled;
  final PinTheme<T>? empty;
  final PinTheme<T>? disabled;
  final PinTheme<T>? error;
  final PinTheme<T>? valid;
  final PinTheme<T>? validating;

  @override
  PinTheme<T> resolve(PinItemState item, PinValidationState validation) {
    final type = item.type;
    if (type != PinItemStateType.disabled && type != PinItemStateType.error) {
      final feedback = switch (validation) {
        PinValidationValid() => valid,
        PinValidationValidating() => validating,
        _ => null,
      };
      if (feedback != null) return feedback;
    }
    final theme = switch (type) {
      PinItemStateType.focused => focused,
      PinItemStateType.filled => filled,
      PinItemStateType.empty => empty,
      PinItemStateType.disabled => disabled,
      PinItemStateType.error => error,
    };
    if (theme != null) return theme;
    final fallbackTheme = fallback;
    if (fallbackTheme != null) return fallbackTheme;

    final defaultTheme = switch (type) {
      PinItemStateType.focused => PinTheme._defaultFocused,
      PinItemStateType.disabled => PinTheme._defaultDisabled,
      PinItemStateType.error => PinTheme._defaultError,
      PinItemStateType.filled || PinItemStateType.empty => PinTheme.defaults,
    };
    final decoration = defaultTheme.decoration;
    return PinTheme<T>(
      width: defaultTheme.width,
      height: defaultTheme.height,
      textStyle: defaultTheme.textStyle,
      margin: defaultTheme.margin,
      padding: defaultTheme.padding,
      constraints: defaultTheme.constraints,
      decoration: decoration is T ? decoration as T : null,
      placeholder: defaultTheme.placeholder,
      alignment: defaultTheme.alignment,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _PinThemesNamed<T> &&
      runtimeType == other.runtimeType &&
      fallback == other.fallback &&
      focused == other.focused &&
      filled == other.filled &&
      empty == other.empty &&
      disabled == other.disabled &&
      error == other.error &&
      valid == other.valid &&
      validating == other.validating;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    fallback,
    focused,
    filled,
    empty,
    disabled,
    error,
    valid,
    validating,
  );

  @override
  String toString() =>
      'PinThemes(fallback: $fallback, focused: $focused, filled: $filled, empty: $empty, disabled: $disabled, error: $error, valid: $valid, validating: $validating)';
}
