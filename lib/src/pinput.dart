import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:universal_platform/universal_platform.dart';

part 'pinput_state.dart';

part 'utils/enums.dart';

part 'utils/pinput_constants.dart';

part 'widgets/widgets.dart';

part 'models/pin_theme.dart';

part 'utils/extensions.dart';

part 'widgets/_pin_item.dart';

part 'utils/pinput_utils_mixin.dart';

part 'widgets/_pinput_selection_gesture_detector_builder.dart';

/// Flutter package to create easily customizable Pin code input field, that your designers can't even draw in Figma 🤭
///
/// ## Features:
/// - Animated Decoration Switching
/// - Form validation
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
  const Pinput({
    this.length = PinputConstants._defaultLength,
    this.defaultPinTheme,
    this.focusedPinTheme,
    this.submittedPinTheme,
    this.followingPinTheme,
    this.disabledPinTheme,
    this.errorPinTheme,
    this.onChanged,
    this.onCompleted,
    this.onSubmitted,
    this.onTap,
    this.onLongPress,
    this.controller,
    this.focusNode,
    this.preFilledWidget,
    this.separatorPositions,
    this.separator = PinputConstants._defaultSeparator,
    this.smsCodeMatcher = PinputConstants.defaultSmsCodeMatcher,
    this.senderPhoneNumber,
    this.androidSmsAutofillMethod = AndroidSmsAutofillMethod.none,
    this.listenForMultipleSmsOnAndroid = false,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.pinContentAlignment = Alignment.center,
    this.animationCurve = Curves.easeIn,
    this.animationDuration = PinputConstants._animationDuration,
    this.pinAnimationType = PinAnimationType.scale,
    this.enabled = true,
    this.readOnly = false,
    this.useNativeKeyboard = true,
    this.toolbarEnabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.showCursor = true,
    this.isCursorAnimationEnabled = true,
    this.enableIMEPersonalizedLearning = false,
    this.enableSuggestions = true,
    this.hapticFeedbackType = HapticFeedbackType.disabled,
    this.closeKeyboardWhenCompleted = true,
    this.keyboardType = TextInputType.number,
    this.textCapitalization = TextCapitalization.none,
    this.slideTransitionBeginOffset,
    this.cursor,
    this.keyboardAppearance,
    this.inputFormatters = const [],
    this.textInputAction,
    this.autofillHints,
    this.obscuringCharacter = '•',
    this.obscuringWidget,
    this.selectionControls,
    this.restorationId,
    this.onClipboardFound,
    this.onAppPrivateCommand,
    this.mouseCursor,
    this.forceErrorState = false,
    this.errorText,
    this.validator,
    this.errorBuilder,
    this.errorTextStyle,
    this.pinputAutovalidateMode = PinputAutovalidateMode.onSubmit,
    this.scrollPadding = const EdgeInsets.all(20),
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    this.onTapOutside,
    Key? key,
  })  : assert(obscuringCharacter.length == 1),
        assert(length > 0),
        assert(
          textInputAction != TextInputAction.newline,
          'Pinput is not multiline',
        ),
        super(key: key);

  /// Theme of the pin in default state
  final PinTheme? defaultPinTheme;

  /// Theme of the pin in focused state
  final PinTheme? focusedPinTheme;

  /// Theme of the pin in submitted state
  final PinTheme? submittedPinTheme;

  /// Theme of the pin in following state
  final PinTheme? followingPinTheme;

  /// Theme of the pin in disabled state
  final PinTheme? disabledPinTheme;

  /// Theme of the pin in error state
  final PinTheme? errorPinTheme;

  /// If true keyboard will be closed
  final bool closeKeyboardWhenCompleted;

  /// Displayed fields count. PIN code length.
  final int length;

  /// By default Android autofill is Disabled, you cane enable it by using any of options listed below
  ///
  /// First option is [AndroidSmsAutofillMethod.smsRetrieverApi] it automatically reads sms without user interaction
  /// More about Sms Retriever API https://developers.google.com/identity/sms-retriever/overview?hl=en
  ///
  /// Second option requires user interaction to confirm reading a SMS, See readme for more details
  /// [AndroidSmsAutofillMethod.smsUserConsentApi]
  /// More about SMS User Consent API https://developers.google.com/identity/sms-retriever/user-consent/overview
  final AndroidSmsAutofillMethod androidSmsAutofillMethod;

  /// If true [androidSmsAutofillMethod] is not [AndroidSmsAutofillMethod.none]
  /// Pinput will listen multiple sms codes, helpful if user request another sms code
  final bool listenForMultipleSmsOnAndroid;

  /// Used to extract code from SMS for Android Autofill if [androidSmsAutofillMethod] is enabled
  /// By default it is [PinputConstants.defaultSmsCodeMatcher]
  final String smsCodeMatcher;

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

  /// Widget that is displayed before field submitted.
  final Widget? preFilledWidget;

  /// Sets the positions where the separator should be shown
  final List<int>? separatorPositions;

  /// Builds a Pinput separator
  final Widget? separator;

  /// Defines how [Pinput] fields are being placed inside [Row]
  final MainAxisAlignment mainAxisAlignment;

  /// Defines how [Pinput] and ([errorText] or [errorBuilder]) are being placed inside [Column]
  final CrossAxisAlignment crossAxisAlignment;

  /// Defines how each [Pinput] field are being placed within the container
  final AlignmentGeometry pinContentAlignment;

  /// curve of every [Pinput] Animation
  final Curve animationCurve;

  /// Duration of every [Pinput] Animation
  final Duration animationDuration;

  /// Animation Type of each [Pinput] field
  /// options:
  /// none, scale, fade, slide, rotation
  final PinAnimationType pinAnimationType;

  /// Begin Offset of ever [Pinput] field when [pinAnimationType] is slide
  final Offset? slideTransitionBeginOffset;

  /// Defines [Pinput] state
  final bool enabled;

  /// See [EditableText.readOnly]
  final bool readOnly;

  /// See [EditableText.autofocus]
  final bool autofocus;

  /// Whether to use Native keyboard or custom one
  /// when flag is set to false [Pinput] wont be focusable anymore
  /// so you should set value of [Pinput]'s [TextEditingController] programmatically
  final bool useNativeKeyboard;

  /// If true, paste button will appear on longPress event
  final bool toolbarEnabled;

  /// Whether show cursor or not
  /// Default cursor '|' or [cursor]
  final bool showCursor;

  final bool isCursorAnimationEnabled;

  /// Whether to enable that the IME update personalized data such as typing history and user dictionary data.
  //
  // This flag only affects Android. On iOS, there is no equivalent flag.
  //
  // Defaults to false. Cannot be null.
  final bool enableIMEPersonalizedLearning;

  /// If [showCursor] true the focused field will show passed Widget
  final Widget? cursor;

  /// The appearance of the keyboard.
  /// This setting is only honored on iOS devices.
  /// If unset, defaults to [ThemeData.brightness].
  final Brightness? keyboardAppearance;

  /// See [EditableText.inputFormatters]
  final List<TextInputFormatter> inputFormatters;

  /// See [EditableText.keyboardType]
  final TextInputType keyboardType;

  /// Provide any symbol to obscure each [Pinput] pin
  /// Recommended ●
  final String obscuringCharacter;

  /// IF [obscureText] is true typed text will be replaced with passed Widget
  final Widget? obscuringWidget;

  /// Whether hide typed pin or not
  final bool obscureText;

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

  /// If true [errorPinTheme] will be applied and [errorText] will be displayed under the Pinput
  final bool forceErrorState;

  /// Text displayed under the Pinput if Pinput is invalid
  final String? errorText;

  /// Style of error text
  final TextStyle? errorTextStyle;

  /// If [Pinput] has error and [errorBuilder] is passed it will be rendered under the Pinput
  final PinputErrorBuilder? errorBuilder;

  /// Return null if pin is valid or any String otherwise
  final FormFieldValidator<String>? validator;

  /// Return null if pin is valid or any String otherwise
  final PinputAutovalidateMode pinputAutovalidateMode;

  /// When this widget receives focus and is not completely visible (for example scrolled partially
  /// off the screen or overlapped by the keyboard)
  /// then it will attempt to make itself visible by scrolling a surrounding [Scrollable], if one is present.
  /// This value controls how far from the edges of a [Scrollable] the TextField will be positioned after the scroll.
  final EdgeInsets scrollPadding;

  /// Optional parameter for Android SMS User Consent API.
  final String? senderPhoneNumber;

  /// {@macro flutter.widgets.EditableText.contextMenuBuilder}
  ///
  /// If not provided, will build a default menu based on the platform.
  ///
  /// See also:
  ///
  ///  * [AdaptiveTextSelectionToolbar], which is built by default.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// A callback to be invoked when a tap is detected outside of this [TapRegion]
  /// The [PointerDownEvent] passed to the function is the event that caused the
  /// notification. If this region is part of a group
  /// then it's possible that the event may be outside of this immediate region,
  /// although it will be within the region of one of the group members.
  /// This is useful if you want to unfocus the [Pinput] when user taps outside of it
  final TapRegionCallback? onTapOutside;

  static Widget _defaultContextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  @override
  State<Pinput> createState() => _PinputState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<PinTheme>(
        'defaultPinTheme',
        defaultPinTheme,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<PinTheme>(
        'focusedPinTheme',
        focusedPinTheme,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<PinTheme>(
        'submittedPinTheme',
        submittedPinTheme,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<PinTheme>(
        'followingPinTheme',
        followingPinTheme,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<PinTheme>(
        'disabledPinTheme',
        disabledPinTheme,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<PinTheme>(
        'errorPinTheme',
        errorPinTheme,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextEditingController>(
        'controller',
        controller,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<FocusNode>(
        'focusNode',
        focusNode,
        defaultValue: null,
      ),
    );
    properties
        .add(DiagnosticsProperty<bool>('enabled', enabled, defaultValue: true));
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
      DiagnosticsProperty<int>(
        'length',
        length,
        defaultValue: PinputConstants._defaultLength,
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
        'onChanged',
        onChanged,
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
      DiagnosticsProperty<Widget?>(
        'preFilledWidget',
        preFilledWidget,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Widget?>('cursor', cursor, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<Widget?>(
        'separator',
        separator,
        defaultValue: PinputConstants._defaultSeparator,
      ),
    );
    properties.add(
      DiagnosticsProperty<Widget?>(
        'obscuringWidget',
        obscuringWidget,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<List<int>?>(
        'separatorPositions',
        separatorPositions,
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
      DiagnosticsProperty<AlignmentGeometry>(
        'pinContentAlignment',
        pinContentAlignment,
        defaultValue: Alignment.center,
      ),
    );
    properties.add(
      DiagnosticsProperty<Curve>(
        'animationCurve',
        animationCurve,
        defaultValue: Curves.easeIn,
      ),
    );
    properties.add(
      DiagnosticsProperty<Duration>(
        'animationDuration',
        animationDuration,
        defaultValue: PinputConstants._animationDuration,
      ),
    );
    properties.add(
      DiagnosticsProperty<PinAnimationType>(
        'pinAnimationType',
        pinAnimationType,
        defaultValue: PinAnimationType.scale,
      ),
    );
    properties.add(
      DiagnosticsProperty<Offset?>(
        'slideTransitionBeginOffset',
        slideTransitionBeginOffset,
        defaultValue: null,
      ),
    );
    properties
        .add(DiagnosticsProperty<bool>('enabled', enabled, defaultValue: true));
    properties.add(
      DiagnosticsProperty<bool>('readOnly', readOnly, defaultValue: false),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'obscureText',
        obscureText,
        defaultValue: false,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>('autofocus', autofocus, defaultValue: false),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'useNativeKeyboard',
        useNativeKeyboard,
        defaultValue: false,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'toolbarEnabled',
        toolbarEnabled,
        defaultValue: true,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'showCursor',
        showCursor,
        defaultValue: true,
      ),
    );
    properties.add(
      DiagnosticsProperty<String>(
        'obscuringCharacter',
        obscuringCharacter,
        defaultValue: '•',
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'obscureText',
        obscureText,
        defaultValue: false,
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
      DiagnosticsProperty<List<TextInputFormatter>>(
        'inputFormatters',
        inputFormatters,
        defaultValue: const <TextInputFormatter>[],
      ),
    );
    properties.add(
      EnumProperty<TextInputAction>(
        'textInputAction',
        textInputAction,
        defaultValue: TextInputAction.done,
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
      DiagnosticsProperty<Brightness>(
        'keyboardAppearance',
        keyboardAppearance,
        defaultValue: null,
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
      DiagnosticsProperty<Iterable<String>?>(
        'autofillHints',
        autofillHints,
        defaultValue: null,
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
      DiagnosticsProperty<TextStyle?>(
        'errorTextStyle',
        errorTextStyle,
        defaultValue: null,
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
      DiagnosticsProperty<FormFieldValidator<String>?>(
        'validator',
        validator,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<PinputAutovalidateMode>(
        'pinputAutovalidateMode',
        pinputAutovalidateMode,
        defaultValue: PinputAutovalidateMode.onSubmit,
      ),
    );
    properties.add(
      DiagnosticsProperty<HapticFeedbackType>(
        'hapticFeedbackType',
        hapticFeedbackType,
        defaultValue: HapticFeedbackType.disabled,
      ),
    );
    properties.add(
      DiagnosticsProperty<String?>(
        'senderPhoneNumber',
        senderPhoneNumber,
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
