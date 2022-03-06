part of '../pinput.dart';

enum PinAnimationType {
  none,
  scale,
  fade,
  slide,
  rotation,
}

enum HapticFeedbackType {
  disabled,
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}

enum PinputAutovalidateMode {
  /// No auto validation will occur.
  disabled,

  /// Used to auto-validate [Pinput] only after [Pinput.onCompleted] or [Pinput.onSubmitted] is called
  onSubmit,
}

typedef PinputErrorBuilder = Widget Function(String? errorText, String pin);
