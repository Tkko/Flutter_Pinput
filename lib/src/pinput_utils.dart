part of 'pinput.dart';

mixin PinputUtils {
  AutovalidateMode _mappedAutoValidateMode(PinputValidateMode pinputValidateMode) {
    switch (pinputValidateMode) {
      case PinputValidateMode.disabled:
        return AutovalidateMode.disabled;
      case PinputValidateMode.onSubmit:
        return AutovalidateMode.disabled;
      case PinputValidateMode.onUserInteraction:
        return AutovalidateMode.onUserInteraction;
      case PinputValidateMode.always:
        return AutovalidateMode.always;
    }
  }

  void _maybeUseHaptic(HapticFeedbackType hapticFeedbackType) {
    switch (hapticFeedbackType) {
      case HapticFeedbackType.disabled:
        break;
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }
}
