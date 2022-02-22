part of 'pin_put.dart';

typedef PinPutErrorBuilder<T> = Widget Function(String? errorText);

const _hiddenTextStyle = TextStyle(fontSize: 0, height: 0, color: Colors.transparent);
const _hiddenInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.zero,
  border: InputBorder.none,
  focusedBorder: InputBorder.none,
  enabledBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  focusedErrorBorder: InputBorder.none,
  errorText: '',
  counter: SizedBox.shrink(),
  counterStyle: _hiddenTextStyle,
  helperStyle: _hiddenTextStyle,
  errorStyle: _hiddenTextStyle,
  floatingLabelStyle: _hiddenTextStyle,
  suffixStyle: _hiddenTextStyle,
  hintStyle: _hiddenTextStyle,
  labelStyle: _hiddenTextStyle,
  prefixStyle: _hiddenTextStyle,
  filled: true,
  counterText: '',
);

const _defaultPinFillColor = Color.fromRGBO(222, 231, 240, .57);

const _defaultPinPutDecoration = BoxDecoration(
  color: _defaultPinFillColor,
  borderRadius: BorderRadius.all(Radius.circular(8)),
);

const _defaultPinTheme = PinTheme(
  width: 56,
  height: 60,
  textStyle: TextStyle(),
  decoration: _defaultPinPutDecoration,
);

class _PinPutState extends State<PinPut> with WidgetsBindingObserver {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;

  String get pin => _controller.value.text;

  int get selectedIndex => pin.length - 1;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_focusListener);
    WidgetsBinding.instance!.addObserver(this);
  }

  void _focusListener() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    if (widget.onClipboardFound != null && appLifecycleState == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    final ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    final String text = clipboardData?.text ?? '';
    if (text.length == widget.length) {
      widget.onClipboardFound!.call(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _fields(),
          _hiddenTextField(),
        ],
      ),
    );
  }

  void _handleTap() {
    // final focus = FocusScope.of(context);
    // if (_focusNode.hasFocus) _focusNode.unfocus();
    // if (focus.hasFocus) focus.unfocus();
    // focus.requestFocus(FocusNode());
    // Future.delayed(Duration.zero, () => focus.requestFocus(_focusNode));
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    widget.onTap?.call();
  }

  bool get _completed => pin.length == widget.length;

  void _handleTextChange(String s) {
    setState(() {});
    if (_completed) {
      widget.onCompleted?.call(s);
      if (widget.closeKeyboardWhenCompleted) {
        _focusNode.unfocus();
      }
    }
    _maybeUseHaptic();
    widget.onChanged?.call(s);
  }

  void _maybeUseHaptic() {
    switch (widget.hapticFeedbackType) {
      case HapticFeedbackType.disabled:
        break;
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  Widget _hiddenTextField() {
    return TextField(
      controller: _controller,
      onTap: widget.onTap,
      onChanged: _handleTextChange,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      focusNode: _focusNode,
      enabled: widget.enabled,
      enableSuggestions: widget.enableSuggestions,
      autofocus: widget.autofocus,
      readOnly: !widget.useNativeKeyboard,
      obscureText: widget.obscureText,
      autofillHints: widget.autofillHints,
      keyboardAppearance: widget.keyboardAppearance,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      toolbarOptions: widget.toolbarOptions,
      maxLength: widget.length,
      showCursor: true,
      autocorrect: false,
      scrollPadding: EdgeInsets.zero,
      decoration: _hiddenInputDecoration,
      style: _hiddenTextStyle,
      restorationId: widget.restorationId,
      textDirection: widget.textDirection,
      obscuringCharacter: widget.obscuringCharacter,
      smartDashesType:
          widget.smartDashesType ?? (widget.obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
      smartQuotesType:
          widget.smartQuotesType ?? (widget.obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
      selectionControls: widget.selectionControls,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
    );
  }

  Widget _fields() {
    return _SeparatedRaw(
      children: Iterable<int>.generate(widget.length).map(_getField).toList(),
      separator: widget.separator,
      separatorPositions: widget.separatorPositions,
      mainAxisAlignment: widget.mainAxisAlignment,
    );
  }

  Widget _getField(int index) {
    final pinTheme = _pinTheme(index);

    return Flexible(
      child: AnimatedContainer(
        height: pinTheme.width,
        width: pinTheme.height,
        constraints: pinTheme.constraints,
        padding: pinTheme.padding,
        margin: pinTheme.margin,
        decoration: pinTheme.decoration,
        alignment: widget.pinContentAlignment,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        child: AnimatedSwitcher(
          switchInCurve: widget.animationCurve,
          switchOutCurve: widget.animationCurve,
          duration: widget.animationDuration,
          transitionBuilder: (child, animation) {
            return _getTransition(child, animation);
          },
          child: _buildFieldContent(index, pinTheme),
        ),
      ),
    );
  }

  PinTheme _getDefaultPinTheme() => widget.pinTheme ?? _defaultPinTheme;

  PinTheme _pinThemeOrDefault(PinTheme? theme) => theme ?? _getDefaultPinTheme();

  Widget _buildFieldContent(int index, PinTheme pinTheme) {
    final key = ValueKey<String>(index < pin.length ? pin[index] : '');

    if (index < pin.length) {
      return Text(
        widget.obscureText ? widget.obscuringCharacter : pin[index],
        key: key,
        style: pinTheme.textStyle,
      );
    }

    final isActiveField = index == pin.length;
    final focused = _focusNode.hasFocus || !widget.useNativeKeyboard;

    if (widget.showCursor && isActiveField && focused) {
      return _PinPutCursor(textStyle: pinTheme.textStyle, cursor: widget.cursor);
    }

    if (widget.preFilledWidget != null) {
      return SizedBox(key: key, child: widget.preFilledWidget);
    }

    return Text('', key: key, style: pinTheme.textStyle);
  }

  PinTheme _pinTheme(int index) {
    if (!widget.enabled) return _pinThemeOrDefault(widget.disabledPinTheme);
    if (index < selectedIndex && (_focusNode.hasFocus || !widget.useNativeKeyboard)) {
      return _pinThemeOrDefault(widget.submittedPinTheme);
    }

    if (index == selectedIndex && (_focusNode.hasFocus || !widget.useNativeKeyboard)) {
      return _pinThemeOrDefault(widget.focusedPinTheme);
    }

    return _pinThemeOrDefault(widget.followingPinTheme);
  }

  Widget _getTransition(Widget child, Animation animation) {
    switch (widget.pinAnimationType) {
      case PinAnimationType.none:
        return child;
      case PinAnimationType.fade:
        return FadeTransition(
          opacity: animation as Animation<double>,
          child: child,
        );
      case PinAnimationType.scale:
        return ScaleTransition(
          scale: animation as Animation<double>,
          child: child,
        );
      case PinAnimationType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: widget.slideTransitionBeginOffset ?? Offset(0.8, 0),
            end: Offset.zero,
          ).animate(animation as Animation<double>),
          child: child,
        );
      case PinAnimationType.rotation:
        return RotationTransition(
          turns: animation as Animation<double>,
          child: child,
        );
    }
  }
}
