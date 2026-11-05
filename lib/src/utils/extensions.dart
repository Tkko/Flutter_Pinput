part of '../pinput.dart';

/// Helper methods for Pinput to easily set, delete, append the value programmatically
/// ``` dart
/// final controller = TextEditingController();
///
/// controller.setText('1234');
///
/// Pinput(
///   controller: controller,
/// );
/// ```
///
extension PinputControllerExt on TextEditingController {
  /// The number of pins in the value, counted in user-perceived characters.
  int get pinLength => text.characters.length;

  /// Sets Pinput value
  void setText(String pin) {
    text = pin;
    moveCursorToEnd();
  }

  /// Deletes the last pin of the value.
  void deleteLastPin() {
    if (text.isEmpty) return;
    text = text.characters.skipLast(1).string;
    moveCursorToEnd();
  }

  /// Appends [pin] at the end of the value, up to [maxLength] pins in total.
  void appendPin(String pin, int maxLength) {
    final remaining = maxLength - pinLength;
    if (remaining <= 0) return;
    text = '$text${pin.characters.take(remaining).string}';
    moveCursorToEnd();
  }

  /// Moves cursor at the end
  void moveCursorToEnd() {
    selection = TextSelection.collapsed(offset: text.length);
  }
}
