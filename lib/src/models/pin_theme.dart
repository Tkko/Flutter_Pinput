part of '../pinput.dart';

/// Resolves the [PinTheme] of a pin item from the item (its index, value and
/// state) and the app-supplied validation state.
typedef PinThemeResolver =
    PinTheme Function(PinItemState item, PinValidationState validation);

/// Theme of the individual pin items for each [PinItemStateType].
@immutable
class PinTheme {
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
  /// interpolated; it switches at the midpoint.
  static PinTheme? lerp(PinTheme? a, PinTheme? b, double t) {
    if (identical(a, b)) return a;
    return PinTheme(
      width: lerpDouble(a?.width, b?.width, t),
      height: lerpDouble(a?.height, b?.height, t),
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      textStyle: TextStyle.lerp(a?.textStyle, b?.textStyle, t),
      decoration: Decoration.lerp(a?.decoration, b?.decoration, t),
      constraints: BoxConstraints.lerp(a?.constraints, b?.constraints, t),
      placeholder: t < 0.5 ? a?.placeholder : b?.placeholder,
      alignment: AlignmentGeometry.lerp(a?.alignment, b?.alignment, t),
    );
  }

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

  @override
  bool operator ==(Object other) =>
      other is PinTheme &&
      runtimeType == other.runtimeType &&
      width == other.width &&
      height == other.height &&
      margin == other.margin &&
      padding == other.padding &&
      textStyle == other.textStyle &&
      decoration == other.decoration &&
      constraints == other.constraints &&
      placeholder == other.placeholder &&
      alignment == other.alignment;

  @override
  int get hashCode => Object.hash(
    runtimeType,
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
abstract class PinThemes {
  /// Abstract const constructor for subclasses.
  const PinThemes._();

  /// Uses the theme for each state, falling back to [fallback] for states you
  /// leave out. Without a [fallback] the built-in look is used, which marks the
  /// focused, disabled and error states. A state theme is used exactly as
  /// written and is not merged with [fallback], so derive it with
  /// [PinTheme.copyWith].
  ///
  /// [valid] and [validating] apply to every pin that is not disabled or in the
  /// error state while the app supplies [PinValidationState.valid] or
  /// [PinValidationState.validating]. When they are null, validation does not
  /// change the look of the pins.
  const factory PinThemes({
    PinTheme? fallback,
    PinTheme? focused,
    PinTheme? filled,
    PinTheme? empty,
    PinTheme? disabled,
    PinTheme? error,
    PinTheme? valid,
    PinTheme? validating,
  }) = _PinThemesNamed;

  /// Resolves the theme with [callback]. Use a `switch` without a wildcard to
  /// get compile-time exhaustiveness over [PinItemStateType].
  const factory PinThemes.resolveWith(PinThemeResolver callback) =
      _PinThemesResolveWith;

  /// Uses [theme] in every state, so focus, disabled input and errors do not
  /// change the look of the pins.
  const factory PinThemes.all(PinTheme theme) = _PinThemesAll;

  /// Returns the theme for [item] under the current [validation] state.
  PinTheme resolve(PinItemState item, PinValidationState validation);
}

class _PinThemesResolveWith extends PinThemes {
  const _PinThemesResolveWith(this._callback) : super._();

  final PinThemeResolver _callback;

  @override
  PinTheme resolve(PinItemState item, PinValidationState validation) =>
      _callback(item, validation);
}

class _PinThemesAll extends PinThemes {
  const _PinThemesAll(this._theme) : super._();

  final PinTheme _theme;

  @override
  PinTheme resolve(PinItemState item, PinValidationState validation) => _theme;
}

class _PinThemesNamed extends PinThemes {
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

  final PinTheme? fallback;
  final PinTheme? focused;
  final PinTheme? filled;
  final PinTheme? empty;
  final PinTheme? disabled;
  final PinTheme? error;
  final PinTheme? valid;
  final PinTheme? validating;

  @override
  PinTheme resolve(PinItemState item, PinValidationState validation) {
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
    return theme ??
        fallback ??
        switch (type) {
          PinItemStateType.focused => PinTheme._defaultFocused,
          PinItemStateType.disabled => PinTheme._defaultDisabled,
          PinItemStateType.error => PinTheme._defaultError,
          PinItemStateType.filled ||
          PinItemStateType.empty => PinTheme.defaults,
        };
  }
}
