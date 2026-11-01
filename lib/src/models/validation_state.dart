part of '../pinput.dart';

/// App-owned validation feedback, independent of focus and editing state.
@immutable
sealed class PinputValidationState {
  const PinputValidationState._();

  /// No current validation result.
  const factory PinputValidationState.idle() = PinputValidationIdle;

  /// Validation is pending. Does not disable input or display an error.
  const factory PinputValidationState.validating() = PinputValidationPending;

  /// Validation passed for the current PIN.
  const factory PinputValidationState.valid() = PinputValidationValid;

  /// Validation failed. Applies the error pin theme with an optional [message].
  ///
  /// Without a message, only error styling is shown unless an error builder
  /// provides custom content.
  const factory PinputValidationState.invalid([String? message]) =
      PinputValidationInvalid;

  @override
  bool operator ==(Object other) =>
      other is PinputValidationState && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// No current validation result.
final class PinputValidationIdle extends PinputValidationState {
  /// Creates feedback with no current validation result.
  const PinputValidationIdle() : super._();
}

/// Validation is pending.
final class PinputValidationPending extends PinputValidationState {
  /// Creates feedback for a pending check.
  const PinputValidationPending() : super._();
}

/// Validation passed for the current PIN.
final class PinputValidationValid extends PinputValidationState {
  /// Creates feedback for successful validation.
  const PinputValidationValid() : super._();
}

/// Validation failed with an optional [message].
final class PinputValidationInvalid extends PinputValidationState {
  /// Creates feedback for a failed check.
  const PinputValidationInvalid([this.message]) : super._();

  /// The optional error message displayed by Pinput.
  final String? message;

  @override
  bool operator ==(Object other) =>
      other is PinputValidationInvalid && message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, message);
}
