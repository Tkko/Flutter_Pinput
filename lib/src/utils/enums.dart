part of '../pinput.dart';

/// The animation type if Pin item
enum _PinAnimationType {
  /// No animation
  none,

  /// Scale animation
  scale,

  /// Fade animation
  fade,

  /// Slide animation
  slide,

  /// Rotation animation
  rotation,

  /// Animation built by the app
  custom,
}

/// The cursor type of [PinCursor]
enum _PinCursorType {
  /// Displays an animated cursor.
  blinking,

  /// Displays a cursor without animation.
  static,

  /// Does not display a cursor.
  hidden,
}

/// The vibration type when user types
enum HapticFeedbackType {
  /// No vibration
  disabled,

  /// Provides a haptic feedback corresponding a collision impact with a light mass.
  ///
  /// On iOS versions 10 and above, this uses a `UIImpactFeedbackGenerator` with
  /// `UIImpactFeedbackStyleLight`. This call has no effects on iOS versions
  /// below 10.
  ///
  /// On Android, this uses `HapticFeedbackConstants.VIRTUAL_KEY`.
  lightImpact,

  /// Provides a haptic feedback corresponding a collision impact with a medium mass.
  ///
  /// On iOS versions 10 and above, this uses a `UIImpactFeedbackGenerator` with
  /// `UIImpactFeedbackStyleMedium`. This call has no effects on iOS versions
  /// below 10.
  ///
  /// On Android, this uses `HapticFeedbackConstants.KEYBOARD_TAP`.
  mediumImpact,

  /// Provides a haptic feedback corresponding a collision impact with a heavy mass.
  ///
  /// On iOS versions 10 and above, this uses a `UIImpactFeedbackGenerator` with
  /// `UIImpactFeedbackStyleHeavy`. This call has no effects on iOS versions
  /// below 10.
  ///
  /// On Android, this uses `HapticFeedbackConstants.CONTEXT_CLICK` on API levels
  /// 23 and above. This call has no effects on Android API levels below 23.
  heavyImpact,

  /// Provides a haptic feedback indication selection changing through discrete values.
  ///
  /// On iOS versions 10 and above, this uses a `UISelectionFeedbackGenerator`.
  /// This call has no effects on iOS versions below 10.
  ///
  /// On Android, this uses `HapticFeedbackConstants.CLOCK_TICK`.
  selectionClick,

  /// Provides vibration haptic feedback to the user for a short duration.
  ///
  /// On iOS devices that support haptic feedback, this uses the default system
  /// vibration value (`kSystemSoundID_Vibrate`).
  ///
  /// On Android, this uses the platform haptic feedback API to simulate a
  /// response to a long press (`HapticFeedbackConstants.LONG_PRESS`).
  vibrate,
}

/// Error widget builder of Pinput
typedef PinErrorBuilder =
    Widget Function(BuildContext context, String? errorText, String pin);

/// How editing previous pins behaves when tapping on a filled pin slot.
///
/// Notes that apply to [overwrite] and [clearFollowing]:
/// - Pressing backspace removes the focused digit. [overwrite] leaves following
///   digits in their original slots; [clearFollowing] also removes them.
///   Backspace on an empty slot removes the preceding digit.
/// - Replacing or deleting a range selection uses native text editing semantics;
///   the resulting text is displayed in contiguous slots.
/// - Tapping the first filled slot selects its digit so native keyboards can
///   delete it with backspace at the start of the input. This tap-created
///   selection retains the selected edit mode's slot behavior.
/// - [Pinput.onCompleted] (and closing the keyboard with
///   [Pinput.closeKeyboardWhenCompleted]) only happens when the PIN is full and
///   the cursor is at the end. Editing a middle pin of a full PIN with
///   [overwrite] therefore does not call it until the user types the last pin;
///   read the value from [Pinput.onChanged] or the controller to submit
///   explicitly (e.g. a "Continue" button).
/// - Pin taps are not available with [PinInputMode.customKeyboard]; a custom
///   keyboard can move the cursor by setting `controller.selection`, and the
///   `appendPin`/`deleteLastPin` helpers always work at the end of the input.
/// - Text stays contiguous, so an empty slot left by [overwrite] is not visible
///   in the value: clearing the second pin of `1234` reports `134`.
enum PinEditMode {
  /// Editing previous pins is disabled; the cursor is locked to the end of the input.
  none,

  /// Tapping a previous pin focuses that slot. Typing replaces that digit in-place and preserves following pins.
  overwrite,

  /// Tapping a previous pin focuses that slot. Typing replaces that digit and clears following pins.
  clearFollowing,
}

/// How the user can input the PIN.
enum PinInputMode {
  /// The native keyboard edits the PIN.
  editable,

  /// The PIN is focusable and selectable, but cannot be edited. See
  /// [EditableText.readOnly].
  readOnly,

  /// The PIN ignores input and uses the disabled pin state.
  disabled,

  /// [Pinput] never opens the native keyboard and ignores pointer input, but
  /// stays focusable (for example for focus traversal and accessibility). Set
  /// the value of its [TextEditingController] programmatically, for example
  /// from an on-screen keypad.
  customKeyboard,
}
