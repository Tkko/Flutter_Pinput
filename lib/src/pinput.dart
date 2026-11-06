import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

part 'pinput_state.dart';

part 'utils/enums.dart';

part 'utils/pinput_constants.dart';

part 'widgets/widgets.dart';

part 'models/pin_theme.dart';

part 'models/validation_state.dart';

part 'models/pin_animation.dart';

part 'models/pin_cursor.dart';

part 'models/pin_layout.dart';

part 'models/pin_keyboard.dart';

part 'models/pin_obscuring.dart';

part 'models/models.dart';

part 'utils/extensions.dart';

part 'utils/_pin_overwrite_text_input_formatter.dart';

part 'widgets/_pin_item.dart';

part 'utils/pinput_utils_mixin.dart';

part 'widgets/_pinput_selection_gesture_detector_builder.dart';

/// Flutter package to create easily customizable Pin code input field.
///
/// ## Features:
/// - Animated Decoration Switching
/// - App-controlled validation feedback
/// - SMS Autofill on iOS
/// - SMS Autofill on Android
/// - Standard Cursor
/// - Custom Cursor
/// - Cursor Animation
/// - Ready For Custom Keyboard
/// - Standard Paste option
/// - Obscuring Character
/// - Obscuring Widget
/// - Haptic Feedback
/// - Close Keyboard After Completion
/// - Beautiful [Examples](https://github.com/Tkko/Flutter_Pinput/tree/main/example/lib/demo)
class Pinput extends StatefulWidget {
  /// Creates a PinPut widget.
  ///
  /// Pass [itemBuilder] to take full control over the pin item widget; then
  /// [theme] and [cursor] are not used.
  const Pinput({
    this.length = _PinputConstants._defaultLength,
    this.theme,
    this.itemBuilder,
    this.onChanged,
    this.onCompleted,
    this.onSubmitted,
    this.onTap,
    this.onLongPress,
    this.onTapOutside,
    this.onTapUpOutside,
    this.controller,
    this.focusNode,
    this.layout = const PinLayout(),
    this.animation = const PinAnimation.scale(),
    this.inputMode = PinInputMode.editable,
    this.autofocus = false,
    this.obscuring,
    this.cursor = const PinCursor.blinking(),
    this.editMode = PinEditMode.overwrite,
    this.enableInteractiveSelection,
    this.hapticFeedbackType = HapticFeedbackType.disabled,
    this.closeKeyboardWhenCompleted = true,
    this.keyboard = const PinKeyboard(),
    this.inputFormatters = const [],
    this.selectionControls,
    this.restorationId,
    this.mouseCursor,
    this.validationState = const PinValidationState.idle(),
    this.errorBuilder,
    this.errorTextStyle,
    this.semanticsLabel,
    this.scrollPadding = const EdgeInsets.all(20),
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    super.key,
  }) : assert(length > 0);

  /// Themes of the pin items per state, see [PinThemes].
  /// If null the closest [DefaultPinThemes] is used, then the built-in theme.
  final PinThemes? theme;

  /// Builds every pin item. When set, [theme] and [cursor] are not used and the
  /// builder is responsible for the content, including masking
  /// ([obscuring] only enables native text obscuring).
  final PinItemWidgetBuilder? itemBuilder;

  /// Layout of the pins and the error content, see [PinLayout].
  final PinLayout layout;

  /// If true keyboard will be closed
  final bool closeKeyboardWhenCompleted;

  /// Displayed fields count. PIN code length.
  final int length;

  /// Fires when user completes pin input
  final ValueChanged<String>? onCompleted;

  /// Called every time input value changes. The value is contiguous: an empty
  /// slot left by [PinEditMode.overwrite] is not represented in it.
  final ValueChanged<String>? onChanged;

  /// See [EditableText.onSubmitted]
  final ValueChanged<String>? onSubmitted;

  /// Called when user clicks on PinPut
  final VoidCallback? onTap;

  /// Triggered when a pointer has remained in contact with the Pinput at the
  /// same location for a long period of time.
  final VoidCallback? onLongPress;

  /// Used to get, modify PinPut value and more.
  /// Text longer than [length] is cut to [length], as it is for typed text.
  /// Don't forget to dispose controller
  /// ``` dart
  ///   @override
  ///   void dispose() {
  ///     controller.dispose();
  ///     super.dispose();
  ///   }
  /// ```
  final TextEditingController? controller;

  /// Defines the keyboard focus for this
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  /// Don't forget to dispose focusNode
  /// ``` dart
  ///   @override
  ///   void dispose() {
  ///     focusNode.dispose();
  ///     super.dispose();
  ///   }
  /// ```
  final FocusNode? focusNode;

  /// Content transition for each pin. Defaults to [PinAnimation.scale].
  /// Its duration and curve also drive decoration and error-layout animations.
  ///
  /// With [itemBuilder] the builder owns the pin content, so only the duration
  /// and curve apply, animating the error layout.
  final PinAnimation animation;

  /// How the user can input the PIN. Defaults to [PinInputMode.editable].
  final PinInputMode inputMode;

  /// See [EditableText.autofocus]
  final bool autofocus;

  /// How editing previous pins behaves when tapping on a filled slot.
  ///
  /// - [PinEditMode.overwrite] (default): Tapping a previous pin focuses that slot. Typing replaces
  ///   the digit in-place and preserves following pins.
  /// - [PinEditMode.clearFollowing]: Tapping a previous pin focuses that slot. Typing replaces
  ///   the digit and clears all following pins (lazy clear on edit).
  /// - [PinEditMode.none]: Editing previous pins is disabled; cursor is locked to the end of the input (legacy behavior).
  /// The first filled slot is selected on tap to make native backspace possible
  /// at the start of the input. Other slots use a collapsed cursor.
  final PinEditMode editMode;

  /// Whether to enable text selection and interactive features like copy/paste.
  /// When enabled, users can select text, use Ctrl+V to paste, and access context menus.
  ///
  /// This is useful for desktop applications where copy/paste is expected behavior.
  /// On mobile, consider using SMS auto-fill instead.
  ///
  /// If null, uses [EditableText]'s default. Set false to disable selection
  /// gestures and keyboard selection shortcuts. To hide only the context menu,
  /// set [contextMenuBuilder] to null instead.
  final bool? enableInteractiveSelection;

  /// Cursor of the default renderer: blinking, static, or hidden. Defaults to
  /// [PinCursor.blinking]. Pass a `child` to customize its appearance.
  final PinCursor cursor;

  /// Keyboard and autofill settings, see [PinKeyboard].
  final PinKeyboard keyboard;

  /// See [EditableText.inputFormatters]
  final List<TextInputFormatter> inputFormatters;

  /// Optional masking of filled pins. Null displays the original text.
  ///
  /// Also enables native text obscuring. Custom item builders must mask their
  /// own visible content; they still receive the original value.
  final PinObscuring? obscuring;

  /// See [EditableText.selectionControls]
  final TextSelectionControls? selectionControls;

  /// See [TextField.restorationId]
  final String? restorationId;

  /// Use haptic feedback everytime user types on keyboard
  /// See more details in [HapticFeedback]
  final HapticFeedbackType hapticFeedbackType;

  /// See [EditableText.mouseCursor]
  final MouseCursor? mouseCursor;

  /// App-owned validation feedback. Defaults to [PinValidationState.idle].
  ///
  /// Pinput does not execute validation or register a field with a [Form].
  /// Validate using [onChanged], [onCompleted], [onSubmitted], or an explicit
  /// submit action, then supply the result here. The app is responsible for
  /// clearing stale results on edits and ignoring outdated async responses.
  ///
  /// Invalid feedback remains visible while focused and is not cleared by
  /// editing. Other states use the normal pin appearance without feedback.
  /// This state never changes text, focus or [inputMode].
  final PinValidationState validationState;

  /// Style of the default error text. Ignored when [errorBuilder] is supplied.
  final TextStyle? errorTextStyle;

  /// Replaces the default error content when [validationState] is invalid.
  /// Called even when the invalid state has no message. Unlike the default
  /// error text, its content is not a live region; add
  /// `Semantics(liveRegion: true)` to announce new errors.
  final PinErrorBuilder? errorBuilder;

  /// Accessibility label announced for the whole field, for example
  /// "Verification code".
  final String? semanticsLabel;

  /// When this widget receives focus and is not completely visible (for example scrolled partially
  /// off the screen or overlapped by the keyboard)
  /// then it will attempt to make itself visible by scrolling a surrounding [Scrollable], if one is present.
  /// This value controls how far from the edges of a [Scrollable] the TextField will be positioned after the scroll.
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.EditableText.contextMenuBuilder}
  ///
  /// If not provided, builds a decoupled default menu with actions like Paste,
  /// Copy, Cut, and Select All.
  ///
  /// To use the platform's native Material or Cupertino context menu, pass
  /// `AdaptiveTextSelectionToolbar.editableText(editableTextState: editableTextState)`.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// A callback to be invoked when a tap is detected outside of this [TapRegion]
  /// The [PointerDownEvent] passed to the function is the event that caused the
  /// notification. If this region is part of a group
  /// then it's possible that the event may be outside of this immediate region,
  /// although it will be within the region of one of the group members.
  /// This is useful if you want to un-focus the [Pinput] when user taps outside of it
  final TapRegionCallback? onTapOutside;

  /// Called for each tap up that occurs outside of the [TextFieldTapRegion]
  /// group when the text field is focused.
  ///
  /// This is useful if you want to un-focus the [Pinput] when user taps outside of it,
  /// but not when user scrolls outside of it :
  /// ```dart
  /// onTapOutside: (event) => tapPosition = event.position,
  /// onTapUpOutside: (event) {
  ///   if (event.position == tapPosition) _focusNode.unfocus();
  ///   tapPosition = null;
  /// },
  /// ```
  ///
  /// See also: [EditableText.onTapUpOutside].
  final TapRegionUpCallback? onTapUpOutside;

  static Widget _defaultContextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    return _PinputDefaultContextMenu(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: editableTextState.contextMenuButtonItems,
    );
  }

  @override
  State<Pinput> createState() => _PinputState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<PinThemes?>('theme', theme, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<int>(
        'length',
        length,
        defaultValue: _PinputConstants._defaultLength,
      ),
    );
    properties.add(
      DiagnosticsProperty<ValueChanged<String>?>(
        'onChanged',
        onChanged,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<ValueChanged<String>?>(
        'onCompleted',
        onCompleted,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<ValueChanged<String>?>(
        'onSubmitted',
        onSubmitted,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<VoidCallback?>('onTap', onTap, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<VoidCallback?>(
        'onLongPress',
        onLongPress,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TapRegionCallback?>(
        'onTapOutside',
        onTapOutside,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TapRegionUpCallback?>(
        'onTapUpOutside',
        onTapUpOutside,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextEditingController?>(
        'controller',
        controller,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<FocusNode?>(
        'focusNode',
        focusNode,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<PinAnimation>(
        'animation',
        animation,
        defaultValue: const PinAnimation.scale(),
      ),
    );
    properties.add(
      EnumProperty<PinInputMode>(
        'inputMode',
        inputMode,
        defaultValue: PinInputMode.editable,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>('autofocus', autofocus, defaultValue: false),
    );
    properties.add(
      DiagnosticsProperty<PinObscuring?>(
        'obscuring',
        obscuring,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<PinCursor>(
        'cursor',
        cursor,
        defaultValue: const PinCursor.blinking(),
      ),
    );
    properties.add(
      EnumProperty<PinEditMode>(
        'editMode',
        editMode,
        defaultValue: PinEditMode.overwrite,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool?>(
        'enableInteractiveSelection',
        enableInteractiveSelection,
        defaultValue: null,
      ),
    );
    properties.add(
      EnumProperty<HapticFeedbackType>(
        'hapticFeedbackType',
        hapticFeedbackType,
        defaultValue: HapticFeedbackType.disabled,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'closeKeyboardWhenCompleted',
        closeKeyboardWhenCompleted,
        defaultValue: true,
      ),
    );
    properties.add(
      DiagnosticsProperty<List<TextInputFormatter>>(
        'inputFormatters',
        inputFormatters,
        defaultValue: const <TextInputFormatter>[],
      ),
    );
    properties.add(
      DiagnosticsProperty<TextSelectionControls?>(
        'selectionControls',
        selectionControls,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<String?>(
        'restorationId',
        restorationId,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<MouseCursor?>(
        'mouseCursor',
        mouseCursor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<PinValidationState>(
        'validationState',
        validationState,
        defaultValue: const PinValidationState.idle(),
      ),
    );
    properties.add(
      DiagnosticsProperty<PinErrorBuilder?>(
        'errorBuilder',
        errorBuilder,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle?>(
        'errorTextStyle',
        errorTextStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsets>(
        'scrollPadding',
        scrollPadding,
        defaultValue: const EdgeInsets.all(20),
      ),
    );
    properties.add(
      DiagnosticsProperty<PinLayout>(
        'layout',
        layout,
        defaultValue: const PinLayout(),
      ),
    );
    properties.add(
      DiagnosticsProperty<PinKeyboard>(
        'keyboard',
        keyboard,
        defaultValue: const PinKeyboard(),
      ),
    );
    properties.add(
      DiagnosticsProperty<PinItemWidgetBuilder?>(
        'itemBuilder',
        itemBuilder,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<String?>(
        'semanticsLabel',
        semanticsLabel,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EditableTextContextMenuBuilder?>(
        'contextMenuBuilder',
        contextMenuBuilder,
        defaultValue: _defaultContextMenuBuilder,
      ),
    );
  }
}
