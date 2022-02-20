import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'pin_put_view.dart';

part 'widgets.dart';

part 'pin_animation_type.dart';

part 'always_disabled_focus_node.dart';

class PinPut extends FormField<String> {
  PinPut({
    this.fieldsCount = 4,
    this.controller,
    this.focusNode,
    double? eachFieldHeight,
    double? eachFieldWidth,
    String? initialValue,
    InputDecoration inputDecoration = const InputDecoration(
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      counter: SizedBox.shrink(),
      counterStyle: TextStyle(fontSize: .000001, height: 0),
      counterText: '',
    ),
    TextInputType keyboardType = TextInputType.number,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? textStyle,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions? toolbarOptions = const ToolbarOptions(paste: true),
    bool showCursor = false,
    String obscuringCharacter = '•',
    bool obscureText = false,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    bool enableInteractiveSelection = true,
    Brightness? keyboardAppearance,
    TextSelectionControls? selectionControls,
    Iterable<String>? autofillHints,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    String? restorationId,
    bool enableIMEPersonalizedLearning = true,
    MainAxisAlignment fieldsAlignment = MainAxisAlignment.spaceBetween,
    AlignmentGeometry eachFieldAlignment = Alignment.center,
    BoxConstraints? eachFieldConstraints,
    BoxDecoration? disabledDecoration,
    BoxDecoration? followingFieldDecoration,
    BoxDecoration? selectedFieldDecoration,
    BoxDecoration? submittedFieldDecoration,
    Curve animationCurve = Curves.linear,
    Duration animationDuration = const Duration(milliseconds: 160),
    EdgeInsetsGeometry? eachFieldMargin,
    EdgeInsetsGeometry? eachFieldPadding,
    List<int>? separatorPositions,
    Offset? slideTransitionBeginOffset,
    PinAnimationType pinAnimationType = PinAnimationType.scale,
    ValueChanged<String>? onSubmit,
    this.onClipboardFound,
    Widget? cursor,
    Widget? preFilledWidget,
    Widget? separator,
    bool useNativeKeyboard = true,
    PinPutErrorBuilder? errorBuilder,
    TextStyle? errorTextStyle,
    EdgeInsetsGeometry errorWidgetPadding = const EdgeInsets.only(top: 8),
    Key? key,
  })  : assert(
          initialValue == null || controller == null,
          'Either initialValue or controller must be null',
        ),
        assert(obscuringCharacter.length == 1),
        super(
          key: key,
          restorationId: restorationId,
          initialValue:
              controller != null ? controller.text : (initialValue ?? ''),
          onSaved: onSaved,
          validator: validator,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<String> field) {
            final _PinPutFormFieldState state = field as _PinPutFormFieldState;

            void onChangedHandler(String value) {
              field.didChange(value);
              if (value.length == fieldsCount) onSubmit?.call(value);
              if (onChanged != null) onChanged(value);
            }

            return UnmanagedRestorationScope(
              bucket: field.bucket,
              child: _PinPutView(
                fieldsCount: fieldsCount,
                eachFieldWidth: eachFieldWidth,
                eachFieldHeight: eachFieldHeight,
                controller: state._effectiveController,
                focusNode: state._effectiveFocusNode,
                inputDecoration: inputDecoration,
                keyboardType: keyboardType,
                textCapitalization: textCapitalization,
                textInputAction: textInputAction,
                textStyle: textStyle,
                strutStyle: strutStyle,
                textDirection: textDirection,
                autofocus: autofocus,
                readOnly: readOnly,
                toolbarOptions: toolbarOptions,
                showCursor: showCursor,
                obscuringCharacter: obscuringCharacter,
                obscureText: obscureText,
                smartDashesType: smartDashesType,
                smartQuotesType: smartQuotesType,
                enableSuggestions: enableSuggestions,
                onChanged: onChangedHandler,
                onTap: onTap,
                onEditingComplete: onEditingComplete,
                onFieldSubmitted: onFieldSubmitted,
                onSaved: onSaved,
                validator: validator,
                inputFormatters: inputFormatters,
                enabled: enabled,
                enableInteractiveSelection: enableInteractiveSelection,
                keyboardAppearance: keyboardAppearance,
                selectionControls: selectionControls,
                autofillHints: autofillHints,
                autovalidateMode: autovalidateMode,
                restorationId: restorationId,
                enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
                fieldsAlignment: fieldsAlignment,
                eachFieldAlignment: eachFieldAlignment,
                eachFieldConstraints: eachFieldConstraints,
                disabledDecoration: disabledDecoration,
                followingFieldDecoration: followingFieldDecoration,
                selectedFieldDecoration: selectedFieldDecoration,
                submittedFieldDecoration: submittedFieldDecoration,
                animationCurve: animationCurve,
                animationDuration: animationDuration,
                eachFieldMargin: eachFieldMargin,
                eachFieldPadding: eachFieldPadding,
                separatorPositions: separatorPositions,
                slideTransitionBeginOffset: slideTransitionBeginOffset,
                pinAnimationType: pinAnimationType,
                onSubmit: onSubmit,
                cursor: cursor,
                preFilledWidget: preFilledWidget,
                separator: separator,
                useNativeKeyboard: useNativeKeyboard,
                errorText: state.errorText,
                errorTextStyle: errorTextStyle,
                errorBuilder: errorBuilder,
                errorWidgetPadding: errorWidgetPadding,
              ),
            );
          },
        );

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController] and
  /// initialize its [TextEditingController.text] with [initialValue].
  final TextEditingController? controller;

  final FocusNode? focusNode;

  final ValueChanged<String>? onClipboardFound;

  final int fieldsCount;

  @override
  FormFieldState<String> createState() => _PinPutFormFieldState();
}

class _PinPutFormFieldState extends FormFieldState<String>
    with WidgetsBindingObserver {
  RestorableTextEditingController? _controller;
  late final FocusNode _focusNode;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!.value;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focusNode;

  @override
  PinPut get widget => super.widget as PinPut;

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
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();

    _effectiveFocusNode.addListener(_focusListener);

    if (widget.controller == null) {
      _createLocalController(widget.initialValue != null
          ? TextEditingValue(text: widget.initialValue!)
          : null);
    } else {
      widget.controller!.addListener(_handleControllerChanged);
    }
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    if (widget.onClipboardFound != null &&
        appLifecycleState == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    final ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    final String text = clipboardData?.text ?? '';
    if (text.length == widget.fieldsCount) {
      widget.onClipboardFound!.call(text);
    }
  }

  void _focusListener() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void didUpdateWidget(PinPut oldWidget) {
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
    _focusNode.removeListener(_focusListener);
    _focusNode.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    if (_effectiveController.text != value)
      _effectiveController.text = value ?? '';
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
    if (_effectiveController.text != value)
      didChange(_effectiveController.text);
  }
}
