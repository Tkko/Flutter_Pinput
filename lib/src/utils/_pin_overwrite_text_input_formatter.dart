part of '../pinput.dart';

class _PinOverwriteTextInputFormatter extends TextInputFormatter {
  final int maxLength;
  final PinEditMode mode;
  const _PinOverwriteTextInputFormatter(this.maxLength, this.mode);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (mode == PinEditMode.none) return newValue;

    final oldText = oldValue.text;
    final newText = newValue.text;

    // Only handle insertions when text length has increased.
    if (newText.length > oldText.length && oldValue.selection.isCollapsed) {
      final insertIndex = oldValue.selection.baseOffset;
      if (insertIndex >= 0 && insertIndex < oldText.length) {
        final diff = newText.length - oldText.length;
        final oldPrefix = oldText.substring(0, insertIndex);
        final oldSuffix = oldText.substring(insertIndex);

        // Only treat the update as a typed/pasted insertion at the cursor.
        // Whole-value replacements (e.g. OTP autofill) must pass through untouched.
        if (!newText.startsWith(oldPrefix) || !newText.endsWith(oldSuffix)) {
          return newValue;
        }
        final insertedChars = newText.substring(insertIndex, insertIndex + diff);

        // If user pasted a full code (>= maxLength), replace entire text from beginning.
        if (insertedChars.characters.length >= maxLength) {
          final clamped = insertedChars.characters.take(maxLength).string;
          return TextEditingValue(
            text: clamped,
            selection: TextSelection.collapsed(offset: clamped.length),
          );
        }

        final prefix = oldPrefix;

        if (mode == PinEditMode.clearFollowing) {
          // Truncate all characters after insertIndex.
          final combined = prefix + insertedChars;
          final clamped = combined.characters.length > maxLength
              ? combined.characters.take(maxLength).string
              : combined;
          return TextEditingValue(
            text: clamped,
            selection: TextSelection.collapsed(offset: clamped.length),
          );
        }

        // In-place overwrite starting at insertIndex.
        final suffixStart = min(insertIndex + diff, oldText.length);
        final suffix = oldText.substring(suffixStart);
        final combinedAll = prefix + insertedChars + suffix;
        final clamped = combinedAll.characters.length > maxLength
            ? combinedAll.characters.take(maxLength).string
            : combinedAll;

        final newOffset = min(insertIndex + diff, clamped.length);
        return TextEditingValue(
          text: clamped,
          selection: TextSelection.collapsed(offset: newOffset),
        );
      }
    }

    return newValue;
  }
}
