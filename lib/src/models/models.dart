part of '../pinput.dart';

/// A widget builder that represents a single pin field.
typedef PinItemWidgetBuilder = Widget Function(
  BuildContext context,
  PinItemState pinItemBuilderState,
);

/// An enum that represents the state of a pin item.
enum PinItemStateType {
  /// The default state of the pin item.
  initial,

  /// The state of the pin item when it is focused.
  focused,

  /// The state of the pin item when it is filled
  submitted,

  /// The state of the pin item when it is following.
  following,

  /// The state of the pin item when it is disabled.
  disabled,

  /// The state of the pin item when it has an error.
  error,
}

/// A class that represents the state of a pin item.
class PinItemState {
  /// Creates a new instance of [PinItemState].
  const PinItemState({
    required this.value,
    required this.index,
    required this.type,
  });

  /// The value of the individual pin item.
  final String value;

  /// The index of the individual pin item.
  final int index;

  /// The state of the individual pin item.
  final PinItemStateType type;
}

class _PinItemBuilder {
  const _PinItemBuilder({
    required this.itemBuilder,
  });

  final PinItemWidgetBuilder itemBuilder;
}
