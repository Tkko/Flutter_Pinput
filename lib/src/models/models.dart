part of '../pinput.dart';

/// A widget builder that represents a single pin field.
typedef PinItemWidgetBuilder =
    Widget Function(BuildContext context, PinItemState pinItemBuilderState);

/// An enum that represents the state of a pin item.
enum PinItemStateType {
  /// The pin has the focus.
  focused,

  /// The pin holds a value.
  filled,

  /// The pin holds no value.
  empty,

  /// The input is disabled.
  disabled,

  /// The app supplied [PinValidationState.invalid]. Applies to every pin, use
  /// [PinItemState.isFocused] to find the focused one.
  error,
}

/// A class that represents the state of a pin item.
@immutable
class PinItemState {
  /// Creates a new instance of [PinItemState].
  const PinItemState({
    required this.value,
    required this.index,
    required this.type,
    this.isFocused = false,
    this.showCursor = false,
  });

  /// The value of the individual pin item.
  final String value;

  /// The index of the individual pin item.
  final int index;

  /// The state of the individual pin item.
  final PinItemStateType type;

  /// Whether this pin has the focus, also while [type] is
  /// [PinItemStateType.error]. When the PIN is full the last pin stays focused.
  final bool isFocused;

  /// Whether the cursor is on this pin. Unlike [isFocused] this is false for
  /// every pin once the cursor moves past the last pin of a full PIN.
  final bool showCursor;

  /// Whether this pin holds a value.
  bool get isFilled => value.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is PinItemState &&
      runtimeType == other.runtimeType &&
      value == other.value &&
      index == other.index &&
      type == other.type &&
      isFocused == other.isFocused &&
      showCursor == other.showCursor;

  @override
  int get hashCode =>
      Object.hash(runtimeType, value, index, type, isFocused, showCursor);
}
