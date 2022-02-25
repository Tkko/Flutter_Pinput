part of 'pinput.dart';

extension TextEditingControllerExt on TextEditingController {
  int get length => this.text.length;

  void delete() {
    if (text.isEmpty) return;
    final pin = this.text.substring(0, this.length - 1);
    this.text = pin;
    this.moveCursorToEnd();
  }

  void moveCursorToEnd() {
    this.selection = TextSelection.collapsed(offset: this.length);
  }

  void append(String s, int maxLength) {
    if (this.length == maxLength) return;
    this.text = '${this.text}$s';
    this.moveCursorToEnd();
  }
}
