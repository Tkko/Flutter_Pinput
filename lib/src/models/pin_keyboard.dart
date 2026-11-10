part of '../pinput.dart';

/// Keyboard and autofill settings of the hidden input behind the pins.
@immutable
class PinKeyboard {
  /// Creates a keyboard configuration.
  const PinKeyboard({
    this.keyboardType = TextInputType.number,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.keyboardAppearance,
    this.enableSuggestions = true,
    this.autofillHints = const [AutofillHints.oneTimeCode],
  }) : assert(
         textInputAction != TextInputAction.newline,
         'Pinput is not multiline',
       );

  /// See [EditableText.keyboardType]
  final TextInputType keyboardType;

  /// See [EditableText.textCapitalization]
  final TextCapitalization textCapitalization;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.done] if null.
  final TextInputAction? textInputAction;

  /// The appearance of the keyboard.
  /// This setting is only honored on iOS devices.
  /// If unset, defaults to system brightness.
  final Brightness? keyboardAppearance;

  /// See [EditableText.enableSuggestions]
  final bool enableSuggestions;

  /// See [EditableText.autofillHints]. Null disables autofill.
  final Iterable<String>? autofillHints;

  /// Creates a copy of this keyboard configuration with the given fields replaced.
  PinKeyboard copyWith({
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    TextInputAction? textInputAction,
    Brightness? keyboardAppearance,
    bool? enableSuggestions,
    Iterable<String>? autofillHints,
  }) {
    return PinKeyboard(
      keyboardType: keyboardType ?? this.keyboardType,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      textInputAction: textInputAction ?? this.textInputAction,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
      enableSuggestions: enableSuggestions ?? this.enableSuggestions,
      autofillHints: autofillHints ?? this.autofillHints,
    );
  }

  @override
  String toString() =>
      'PinKeyboard(keyboardType: $keyboardType, textCapitalization: $textCapitalization, textInputAction: $textInputAction, keyboardAppearance: $keyboardAppearance, enableSuggestions: $enableSuggestions, autofillHints: $autofillHints)';

  @override
  bool operator ==(Object other) =>
      other is PinKeyboard &&
      runtimeType == other.runtimeType &&
      keyboardType == other.keyboardType &&
      textCapitalization == other.textCapitalization &&
      textInputAction == other.textInputAction &&
      keyboardAppearance == other.keyboardAppearance &&
      enableSuggestions == other.enableSuggestions &&
      listEquals(autofillHints?.toList(), other.autofillHints?.toList());

  @override
  int get hashCode => Object.hash(
    runtimeType,
    keyboardType,
    textCapitalization,
    textInputAction,
    keyboardAppearance,
    enableSuggestions,
    autofillHints == null ? null : Object.hashAll(autofillHints!),
  );
}
