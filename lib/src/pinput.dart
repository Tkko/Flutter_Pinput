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

part 'models/pin_obscuring.dart';

part 'models/models.dart';

part 'models/sms_retriever.dart';

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
/// - Copy From Clipboard
/// - Ready For Custom Keyboard
/// - Standard Paste option
/// - Obscuring Character
/// - Obscuring Widget
/// - Haptic Feedback
/// - Close Keyboard After Completion
/// - Beautiful [Examples](https://github.com/Tkko/Flutter_PinPut/tree/master/example/lib/demo)
class Pinput extends StatefulWidget {
  /// Creates a PinPut widget
  const Pinput({
    this.length = PinputConstants._defaultLength,
    this.smsRetriever,
    this.theme,
    this.onChanged,
    this.onCompleted,
    this.onSubmitted,
    this.onTap,
    this.onLongPress,
    this.onTapOutside,
    this.onTapUpOutside,
    this.controller,
    this.focusNode,
    this.separatorBuilder,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.pinContentAlignment = Alignment.center,
    this.pinAnimation = const PinAnimation.scale(),
    this.inputMode = PinInputMode.editable,
    this.autofocus = false,
    this.obscuring,
    this.cursor = const PinCursor.blinking(),
    this.pinEditMode = PinEditMode.overwrite,
    this.enableIMEPersonalizedLearning = false,
    this.enableInteractiveSelection,
    this.enableSuggestions = true,
    this.hapticFeedbackType = HapticFeedbackType.disabled,
    this.closeKeyboardWhenCompleted = true,
    this.keyboardType = TextInputType.number,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardAppearance,
    this.inputFormatters = const [],
    this.textInputAction,
    this.autofillHints = const [AutofillHints.oneTimeCode],
    this.selectionControls,
    this.restorationId,
    this.onClipboardFound,
    this.onAppPrivateCommand,
    this.mouseCursor,
    this.validationState = const PinputValidationState.idle(),
    this.errorBuilder,
    this.errorTextStyle,
    this.scrollPadding = const EdgeInsets.all(20),
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    super.key,
  }) : assert(length > 0),
       assert(
         textInputAction != TextInputAction.newline,
         'Pinput is not multiline',
       ),
       _builder = null;

  /// Creates a PinPut widget with custom pin item builder
  /// This gives you full control over the pin item widget
  Pinput.builder({
    required PinItemWidgetBuilder builder,
    this.smsRetriever,
    this.length = PinputConstants._defaultLength,
    this.onChanged,
    this.onCompleted,
    this.onSubmitted,
    this.onTap,
    this.onLongPress,
    this.onTapOutside,
    this.onTapUpOutside,
    this.controller,
    this.focusNode,
    this.separatorBuilder,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.inputMode = PinInputMode.editable,
    this.obscuring,
    this.autofocus = false,
    this.pinEditMode = PinEditMode.overwrite,
    this.enableIMEPersonalizedLearning = false,
    this.enableInteractiveSelection,
    this.enableSuggestions = true,
    this.hapticFeedbackType = HapticFeedbackType.disabled,
    this.closeKeyboardWhenCompleted = true,
    this.keyboardType = TextInputType.number,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardAppearance,
    this.inputFormatters = const [],
    this.textInputAction,
    this.autofillHints = const [AutofillHints.oneTimeCode],
    this.selectionControls,
    this.restorationId,
    this.onClipboardFound,
    this.onAppPrivateCommand,
    this.mouseCursor,
    this.validationState = const PinputValidationState.idle(),
    this.errorBuilder,
    this.errorTextStyle,
    this.scrollPadding = const EdgeInsets.all(20),
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    super.key,
  }) : assert(length > 0),
       assert(
         textInputAction != TextInputAction.newline,
         'Pinput is not multiline',
       ),
       _builder = _PinItemBuilder(itemBuilder: builder),
       theme = null,
       pinContentAlignment = Alignment.center,
       pinAnimation = const PinAnimation.scale(),
       cursor = const PinCursor.hidden();

  /// Themes of the pin items per state, see [PinThemes].
  /// If null the built-in theme is used.
  final PinThemes? theme;

  /// If true keyboard will be closed
  final bool closeKeyboardWhenCompleted;

  /// Displayed fields count. PIN code length.
  final int length;

  /// By default Android autofill is Disabled, you can enable it by passing [smsRetriever]
  /// SmsRetriever exposes methods to listen for incoming SMS and extract code from it
  /// Recommended package to get sms code on Android is smart_auth https://pub.dev/packages/smart_auth
  final SmsRetriever? smsRetriever;

  /// Fires when user completes pin input
  final ValueChanged<String>? onCompleted;

  /// Called every time input value changes.
  final ValueChanged<String>? onChanged;

  /// See [EditableText.onSubmitted]
  final ValueChanged<String>? onSubmitted;

  /// Called when user clicks on PinPut
  final VoidCallback? onTap;

  /// Triggered when a pointer has remained in contact with the Pinput at the
  /// same location for a long period of time.
  final VoidCallback? onLongPress;

  /// Used to get, modify PinPut value and more.
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

  /// Builds a [Pinput] separator
  /// If null SizedBox(width: 8) will be used
  final JustIndexedWidgetBuilder? separatorBuilder;

  /// Builds a [Pinput] item
  /// If null the default _PinItem will be used
  final _PinItemBuilder? _builder;

  /// Defines how [Pinput] fields are being placed inside [Row]
  final MainAxisAlignment mainAxisAlignment;

  /// Defines how [Pinput] and its error content are placed inside [Column].
  final CrossAxisAlignment crossAxisAlignment;

  /// Defines how each [Pinput] field are being placed within the container
  final AlignmentGeometry pinContentAlignment;

  /// Content transition for each pin. Defaults to [PinAnimation.scale].
  /// Its duration and curve also drive decoration and error-layout animations.
  final PinAnimation pinAnimation;

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
  final PinEditMode pinEditMode;

  /// Whether to enable that the IME update personalized data such as typing history and user dictionary data.
  //
  // This flag only affects Android. On iOS, there is no equivalent flag.
  //
  // Defaults to false. Cannot be null.
  final bool enableIMEPersonalizedLearning;

  /// Whether to enable text selection and interactive features like copy/paste.
  /// When enabled, users can select text, use Ctrl+V to paste, and access context menus.
  ///
  /// This is useful for desktop applications where copy/paste is expected behavior.
  /// On mobile, consider using SMS auto-fill or [onClipboardFound] callback instead.
  ///
  /// If null, uses [EditableText]'s default. Set false to disable selection
  /// gestures and keyboard selection shortcuts. To hide only the context menu,
  /// set [contextMenuBuilder] to null instead.
  final bool? enableInteractiveSelection;

  /// Cursor of the default renderer: blinking, static, or hidden. Defaults to
  /// [PinCursor.blinking]. Pass a `child` to customize its appearance.
  final PinCursor cursor;

  /// The appearance of the keyboard.
  /// This setting is only honored on iOS devices.
  /// If unset, defaults to system brightness.
  final Brightness? keyboardAppearance;

  /// See [EditableText.inputFormatters]
  final List<TextInputFormatter> inputFormatters;

  /// See [EditableText.keyboardType]
  final TextInputType keyboardType;

  /// Optional masking of filled pins. Null displays the original text.
  ///
  /// Also enables native text obscuring. Custom item builders must mask their
  /// own visible content; they still receive the original value.
  final PinObscuring? obscuring;

  /// See [EditableText.textCapitalization]
  final TextCapitalization textCapitalization;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  final TextInputAction? textInputAction;

  /// See [EditableText.autofillHints]
  final Iterable<String>? autofillHints;

  /// See [EditableText.enableSuggestions]
  final bool enableSuggestions;

  /// See [EditableText.selectionControls]
  final TextSelectionControls? selectionControls;

  /// See [TextField.restorationId]
  final String? restorationId;

  /// Fires when clipboard has text of Pinput's length
  final ValueChanged<String>? onClipboardFound;

  /// Use haptic feedback everytime user types on keyboard
  /// See more details in [HapticFeedback]
  final HapticFeedbackType hapticFeedbackType;

  /// See [EditableText.onAppPrivateCommand]
  final AppPrivateCommandCallback? onAppPrivateCommand;

  /// See [EditableText.mouseCursor]
  final MouseCursor? mouseCursor;

  /// App-owned validation feedback. Defaults to [PinputValidationState.idle].
  ///
  /// Pinput does not execute validation or register a field with a [Form].
  /// Validate using [onChanged], [onCompleted], [onSubmitted], or an explicit
  /// submit action, then supply the result here. The app is responsible for
  /// clearing stale results on edits and ignoring outdated async responses.
  ///
  /// Invalid feedback remains visible while focused and is not cleared by
  /// editing. Other states use the normal pin appearance without feedback.
  /// This state never changes text, focus, [inputMode].
  final PinputValidationState validationState;

  /// Style of the default error text. Ignored when [errorBuilder] is supplied.
  final TextStyle? errorTextStyle;

  /// Replaces the default error content when [validationState] is invalid.
  /// Called even when the invalid state has no message.
  final PinputErrorBuilder? errorBuilder;

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
        defaultValue: PinputConstants._defaultLength,
      ),
    );
    properties.add(
      DiagnosticsProperty<SmsRetriever?>(
        'smsRetriever',
        smsRetriever,
        defaultValue: null,
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
      DiagnosticsProperty<JustIndexedWidgetBuilder?>(
        'separatorBuilder',
        separatorBuilder,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<MainAxisAlignment>(
        'mainAxisAlignment',
        mainAxisAlignment,
        defaultValue: MainAxisAlignment.center,
      ),
    );
    properties.add(
      DiagnosticsProperty<CrossAxisAlignment>(
        'crossAxisAlignment',
        crossAxisAlignment,
        defaultValue: CrossAxisAlignment.start,
      ),
    );
    properties.add(
      DiagnosticsProperty<AlignmentGeometry>(
        'pinContentAlignment',
        pinContentAlignment,
        defaultValue: Alignment.center,
      ),
    );
    properties.add(
      DiagnosticsProperty<PinAnimation>(
        'pinAnimation',
        pinAnimation,
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
        'pinEditMode',
        pinEditMode,
        defaultValue: PinEditMode.overwrite,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'enableIMEPersonalizedLearning',
        enableIMEPersonalizedLearning,
        defaultValue: false,
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
      DiagnosticsProperty<bool>(
        'enableSuggestions',
        enableSuggestions,
        defaultValue: true,
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
      DiagnosticsProperty<TextInputType>(
        'keyboardType',
        keyboardType,
        defaultValue: TextInputType.number,
      ),
    );
    properties.add(
      EnumProperty<TextCapitalization>(
        'textCapitalization',
        textCapitalization,
        defaultValue: TextCapitalization.none,
      ),
    );
    properties.add(
      DiagnosticsProperty<Brightness?>(
        'keyboardAppearance',
        keyboardAppearance,
        defaultValue: null,
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
      DiagnosticsProperty<TextInputAction?>(
        'textInputAction',
        textInputAction,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Iterable<String>?>(
        'autofillHints',
        autofillHints,
        defaultValue: const [AutofillHints.oneTimeCode],
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
      DiagnosticsProperty<ValueChanged<String>?>(
        'onClipboardFound',
        onClipboardFound,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<AppPrivateCommandCallback?>(
        'onAppPrivateCommand',
        onAppPrivateCommand,
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
      DiagnosticsProperty<PinputValidationState>(
        'validationState',
        validationState,
        defaultValue: const PinputValidationState.idle(),
      ),
    );
    properties.add(
      DiagnosticsProperty<PinputErrorBuilder?>(
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
      DiagnosticsProperty<EditableTextContextMenuBuilder?>(
        'contextMenuBuilder',
        contextMenuBuilder,
        defaultValue: _defaultContextMenuBuilder,
      ),
    );
  }
}
