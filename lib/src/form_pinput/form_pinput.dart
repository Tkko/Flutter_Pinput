part of '../pinput.dart';

class PinputForm extends FormField<String> {
  PinputForm({
    Key? key,
    this.controller,
    final PinTheme? defaultPinTheme,
    final PinTheme? focusedPinTheme,
    final PinTheme? submittedPinTheme,
    final PinTheme? followingPinTheme,
    final PinTheme? disabledPinTheme,
    final PinTheme? errorPinTheme,
    final bool closeKeyboardWhenCompleted = true,
    final TextStyle? errorTextStyle,
    final PinputErrorBuilder? errorBuilder,
    final int length = 4,
    final ValueChanged<String>? onCompleted,
    final ValueChanged<String>? onChanged,
    final ValueChanged<String>? onSubmitted,
    final VoidCallback? onTap,
    final VoidCallback? onLongPress,
    final FocusNode? focusNode,
    final Widget? preFilledWidget,
    final List<int>? separatorPositions,
    final Widget? separator = const SizedBox(width: 8),
    final MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    final AlignmentGeometry pinContentAlignment = Alignment.center,
    final Curve animationCurve = Curves.easeIn,
    final Duration animationDuration = const Duration(milliseconds: 170),
    final PinAnimationType pinAnimationType = PinAnimationType.scale,
    final Offset? slideTransitionBeginOffset,
    final bool enabled = true,
    final bool readOnly = false,
    final bool autofocus = false,
    final bool useNativeKeyboard = true,
    final bool toolbarEnabled = true,
    final bool showCursor = true,
    final Widget? cursor,
    final Brightness? keyboardAppearance,
    final List<TextInputFormatter> inputFormatters = const [],
    final TextInputType keyboardType = TextInputType.number,
    final String obscuringCharacter = '•',
    final Widget? obscuringWidget,
    final bool obscureText = false,
    final TextCapitalization textCapitalization = TextCapitalization.none,
    final TextInputAction? textInputAction,
    final ToolbarOptions toolbarOptions = const ToolbarOptions(paste: true),
    final Iterable<String>? autofillHints,
    final bool enableSuggestions = true,
    final TextSelectionControls? selectionControls,
    final String? restorationId,
    final ValueChanged<String>? onClipboardFound,
    final HapticFeedbackType hapticFeedbackType = HapticFeedbackType.disabled,
    final AppPrivateCommandCallback? onAppPrivateCommand,
    final MouseCursor? mouseCursor,
    final AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    final String? initialValue,
    final VoidCallback? onEditingComplete,
    final ValueChanged<String>? onFieldSubmitted,
    final FormFieldSetter<String>? onSaved,
    final FormFieldValidator<String>? validator,
  })  : assert(initialValue == null || controller == null),
        super(
          key: key,
          restorationId: restorationId,
          initialValue: controller != null ? controller.text : (initialValue ?? ''),
          onSaved: onSaved,
          validator: validator,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<String> field) {
            final _PinputFormFieldState state = field as _PinputFormFieldState;

            void onChangedHandler(String value) {
              field.didChange(value);
              if (onChanged != null) {
                onChanged(value);
              }
            }

            return UnmanagedRestorationScope(
              bucket: field.bucket,
              child: Pinput(
                controller: state._effectiveController,
                onChanged: onChangedHandler,
                length: length,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                followingPinTheme: followingPinTheme,
                disabledPinTheme: disabledPinTheme,
                errorPinTheme: errorPinTheme,
                onCompleted: onCompleted,
                onSubmitted: onSubmitted,
                onTap: onTap,
                onLongPress: onLongPress,
                focusNode: focusNode,
                preFilledWidget: preFilledWidget,
                separatorPositions: separatorPositions,
                separator: separator,
                mainAxisAlignment: mainAxisAlignment,
                pinContentAlignment: pinContentAlignment,
                animationCurve: animationCurve,
                animationDuration: animationDuration,
                pinAnimationType: pinAnimationType,
                enabled: enabled,
                readOnly: readOnly,
                useNativeKeyboard: useNativeKeyboard,
                toolbarEnabled: toolbarEnabled,
                autofocus: autofocus,
                obscureText: obscureText,
                showCursor: showCursor,
                enableSuggestions: enableSuggestions,
                hapticFeedbackType: hapticFeedbackType,
                closeKeyboardWhenCompleted: closeKeyboardWhenCompleted,
                keyboardType: keyboardType,
                textCapitalization: textCapitalization,
                toolbarOptions: toolbarOptions,
                slideTransitionBeginOffset: slideTransitionBeginOffset,
                cursor: cursor,
                keyboardAppearance: keyboardAppearance,
                inputFormatters: inputFormatters,
                textInputAction: textInputAction,
                autofillHints: autofillHints,
                errorTextStyle: errorTextStyle,
                obscuringCharacter: obscuringCharacter,
                obscuringWidget: obscuringWidget,
                selectionControls: selectionControls,
                restorationId: restorationId,
                onClipboardFound: onClipboardFound,
                errorBuilder: errorBuilder,
                onAppPrivateCommand: onAppPrivateCommand,
                mouseCursor: mouseCursor,
              ),
            );
          },
        );

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController] and
  /// initialize its [TextEditingController.text] with [initialValue].
  final TextEditingController? controller;

  @override
  FormFieldState<String> createState() => _PinputFormFieldState();
}

class _PinputFormFieldState extends FormFieldState<String> {
  RestorableTextEditingController? _controller;

  TextEditingController get _effectiveController => widget.controller ?? _controller!.value;

  @override
  PinputForm get widget => super.widget as PinputForm;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    super.restoreState(oldBucket, initialRestore);
    if (_controller != null) {
      _registerController();
    }
    // Make sure to update the internal [FormFieldState] value to sync up with
    // text editing controller value.
    setValue(_effectiveController.text);
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null ? RestorableTextEditingController() : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createLocalController(widget.initialValue != null ? TextEditingValue(text: widget.initialValue!) : null);
    } else {
      widget.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(PinputForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _createLocalController(oldWidget.controller!.value);
      }

      if (widget.controller != null) {
        setValue(widget.controller!.text);
        if (oldWidget.controller == null) {
          unregisterFromRestoration(_controller!);
          _controller!.dispose();
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);

    if (_effectiveController.text != value) _effectiveController.text = value ?? '';
  }

  @override
  void reset() {
    // setState will be called in the superclass, so even though state is being
    // manipulated, no setState call is needed here.
    _effectiveController.text = widget.initialValue ?? '';
    super.reset();
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.text != value) didChange(_effectiveController.text);
  }
}
