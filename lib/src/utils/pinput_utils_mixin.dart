// ignore_for_file: discarded_futures

part of '../pinput.dart';

mixin _PinputUtilsMixin {
  void _maybeUseHaptic(HapticFeedbackType hapticFeedbackType) {
    switch (hapticFeedbackType) {
      case HapticFeedbackType.disabled:
        break;
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
    }
  }

  Future<String> _getClipboardOrEmpty() async {
    final ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    return clipboardData?.text ?? '';
  }
}
