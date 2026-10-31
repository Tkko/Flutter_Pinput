part of '../pinput.dart';

class _PinOverwriteTextInputFormatter extends TextInputFormatter {
  final _PinputState state;
  const _PinOverwriteTextInputFormatter(this.state);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Range selections use native replacement semantics, not slot deletion.
    if (state.widget.pinEditMode == PinEditMode.none ||
        (newValue.composing.isValid && !newValue.composing.isCollapsed)) {
      return newValue;
    }

    final oldText = oldValue.text;
    final newText = newValue.text;
    final length = state.widget.length;
    final activeSlot = state.selectedIndex;

    if (!oldValue.selection.isCollapsed) {
      if (!state._hasPinTapSelection || oldText == newText) return newValue;
      final start = oldValue.selection.start;
      final prefix = oldText.substring(0, start);
      final suffix = oldText.substring(oldValue.selection.end);
      if (!newText.startsWith(prefix) ||
          !newText.endsWith(suffix) ||
          newText.length < prefix.length + suffix.length) {
        return state._replacePinText(newText);
      }
      final inserted = newText.substring(start, newText.length - suffix.length);
      if (inserted.isEmpty) return state._deletePinAt(activeSlot);
      if (inserted.characters.length >= length) {
        return state._replacePinText(inserted);
      }
      return state._insertPinText(inserted, activeSlot);
    }

    if (newText.length > oldText.length) {
      final diff = newText.length - oldText.length;
      final insertOffset = oldValue.selection.start.clamp(0, oldText.length);
      final oldPrefix = oldText.substring(0, insertOffset);
      final oldSuffix = oldText.substring(insertOffset);

      // Whole-value replacement (e.g. OTP autofill)
      if (!newText.startsWith(oldPrefix) || !newText.endsWith(oldSuffix)) {
        return state._replacePinText(newText);
      }

      final insertedChars = newText.substring(
        insertOffset,
        insertOffset + diff,
      );
      // Full paste (>= length): replace entire input from beginning.
      if (insertedChars.characters.length >= length) {
        return state._replacePinText(insertedChars);
      }

      return state._insertPinText(insertedChars, activeSlot);
    }

    if (newText.length < oldText.length) {
      if (newText.isEmpty) {
        state._syncSlotsFromExternalText('');
        return TextEditingValue.empty;
      }
      // Only reinterpret a single-character deletion adjacent to the caret.
      // Autofill and IMEs can replace the whole value with shorter text.
      final offset = oldValue.selection.start.clamp(0, oldText.length);
      final previous = oldText.substring(0, offset).characters;
      final following = oldText.substring(offset).characters;
      final backspaceText = previous.isEmpty
          ? null
          : previous.take(previous.length - 1).string + following.string;
      final deleteText = following.isEmpty
          ? null
          : previous.string + following.skip(1).string;
      if (newText != backspaceText && newText != deleteText) {
        return state._replacePinText(newText);
      }
      return state._deletePinAt(activeSlot);
    }

    return newValue;
  }
}
