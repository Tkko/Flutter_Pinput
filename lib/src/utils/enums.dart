part of '../pinput.dart';

/// The mode which determines the Pinput validation method
enum PinputAutovalidateMode {
  /// No auto validation will occur.
  disabled,

  /// Used to auto-validate [Pinput] only after [Pinput.onCompleted] or [Pinput.onSubmitted] is called
  onSubmit,
}

/// The method that is used to get the sms code on Android
enum AndroidSmsAutofillMethod {
  /// Disabled SMS autofill on Android
  none,

  /// Automatically reads sms without user interaction
  /// Requires SMS to contain The App signature, see readme for more details
  /// More about Sms Retriever API https://developers.google.com/identity/sms-retriever/overview?hl=en
  smsRetrieverApi,

  /// Requires user interaction to confirm reading a SMS, see readme for more details
  /// [AndroidSmsAutofillMethod.smsUserConsentApi]
  /// More about SMS User Consent API https://developers.google.com/identity/sms-retriever/user-consent/overview
  smsUserConsentApi,
}

/// The animation type if Pin item
enum PinAnimationType {
  none,
  scale,
  fade,
  slide,
  rotation,
}

/// The vibration type when user types
enum HapticFeedbackType {
  disabled,
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}

/// Error widget builder of Pinput
typedef PinputErrorBuilder = Widget Function(String? errorText, String pin);
