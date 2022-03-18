part of '../pinput.dart';

enum PinputAutovalidateMode {
  /// No auto validation will occur.
  disabled,

  /// Used to auto-validate [Pinput] only after [Pinput.onCompleted] or [Pinput.onSubmitted] is called
  onSubmit,
}

enum AndroidSmsAutofillMethod {
  /// Disabled SMS autofill on Android
  none,

  /// Automatically reads sms without user interaction
  /// Requires SMS to contain The App signature, see readme for more details
  /// More about Sms Retriever API [https://developers.google.com/identity/sms-retriever/overview?hl=en]
  smsRetrieverApi,

  /// Requires user interaction to confirm reading a SMS, see readme for more details
  /// [AndroidSmsAutofillMethod.smsUserConsentApi]
  /// More about SMS User Consent API [https://developers.google.com/identity/sms-retriever/user-consent/overview]
  smsUserConsentApi,
}

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

typedef PinputErrorBuilder = Widget Function(String? errorText, String pin);
