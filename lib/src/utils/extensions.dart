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
  /// The length of the Pinput value
  int get length => text.length;

  /// Sets Pinput value
  void setText(String pin) {
    text = pin;
    moveCursorToEnd();
  }

  /// Deletes the last character of Pinput value
  void delete() {
    if (text.isEmpty) {
      return;
    }
    final pin = text.substring(0, length - 1);
    text = pin;
    moveCursorToEnd();
  }

  /// Appends character at the end of the Pinput
  void append(String s, int maxLength) {
    if (length == maxLength) {
      return;
    }
    text = '$text$s';
    moveCursorToEnd();
  }

  /// Moves cursor at the end
  void moveCursorToEnd() {
    selection = TextSelection.collapsed(offset: length);
  }
}
