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
  int get length => this.text.length;

  /// Sets Pinput value
  void setText(String pin) {
    this.text = pin;
    this.moveCursorToEnd();
  }

  /// Deletes the last character of Pinput value
  void delete() {
    if (text.isEmpty) return;
    final pin = this.text.substring(0, this.length - 1);
    this.text = pin;
    this.moveCursorToEnd();
  }

  /// Appends character at the end of the Pinput
  void append(String s, int maxLength) {
    if (this.length == maxLength) return;
    this.text = '${this.text}$s';
    this.moveCursorToEnd();
  }

  /// Moves cursor at the end
  void moveCursorToEnd() {
    this.selection = TextSelection.collapsed(offset: this.length);
  }
}
