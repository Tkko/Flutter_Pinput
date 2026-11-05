part of '../pinput.dart';

/// App-owned validation feedback, independent of focus and editing state.
@immutable
sealed class PinValidationState {
  const PinValidationState._();

  /// No current validation result.
  const factory PinValidationState.idle() = PinValidationIdle;

  /// Validation is pending. Does not disable input or display an error.
  const factory PinValidationState.validating() = PinValidationValidating;

  /// Validation passed for the current PIN.
  const factory PinValidationState.valid() = PinValidationValid;

  /// Validation failed. Applies the error pin theme with an optional [message].
  /// The built-in theme marks the pins with a border; a custom [PinThemes] needs
  /// an `error` theme for the pins to change.
  ///
  /// Without a message, only error styling is shown unless an error builder
  /// provides custom content.
  const factory PinValidationState.invalid([String? message]) =
      PinValidationInvalid;

  @override
  bool operator ==(Object other) =>
      other is PinValidationState && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// No current validation result.
final class PinValidationIdle extends PinValidationState {
  /// Creates feedback with no current validation result.
  const PinValidationIdle() : super._();
}

/// Validation is pending.
final class PinValidationValidating extends PinValidationState {
  /// Creates feedback for a pending check.
  const PinValidationValidating() : super._();
}

/// Validation passed for the current PIN.
final class PinValidationValid extends PinValidationState {
  /// Creates feedback for successful validation.
  const PinValidationValid() : super._();
}

/// Validation failed with an optional [message].
final class PinValidationInvalid extends PinValidationState {
  /// Creates feedback for a failed check.
  const PinValidationInvalid([this.message]) : super._();

  /// The optional error message displayed by Pinput.
  final String? message;

  @override
  bool operator ==(Object other) =>
      other is PinValidationInvalid && message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, message);
}
