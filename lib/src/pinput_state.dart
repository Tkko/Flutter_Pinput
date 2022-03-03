part of 'pinput.dart';

class _PinputState extends State<Pinput> with WidgetsBindingObserver {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  late TextEditingValue _recentControllerValue;

  int get selectedIndex => _recentControllerValue.selection.baseOffset;

  String get pin => _controller.text;

  bool get _completed => pin.length == widget.length;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _recentControllerValue = _controller.value;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onTextChangedListener);
    _focusNode.addListener(_focusListener);
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    _controller.removeListener(_onTextChangedListener);
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChangedListener() {
    final textChanged = _recentControllerValue.text != _controller.value.text;

    _recentControllerValue = _controller.value;
    if (textChanged) {
      if (_completed) {
        widget.onCompleted?.call(pin);
        if (widget.closeKeyboardWhenCompleted) {
          _focusNode.unfocus();
        }
      }
      _maybeUseHaptic();
      widget.onChanged?.call(pin);
      setState(() {});
    }
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

  void _focusListener() {
    if (mounted) setState(() {});
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
    if (text.length == widget.length) {
      widget.onClipboardFound!.call(text);
    }
  }

  void _handleTap() {
    final isKeyboardHidden =
        MediaQueryData.fromWindow(window).viewInsets.bottom == 0;

    if (_focusNode.hasFocus && isKeyboardHidden) {
      _focusNode.unfocus();
      Future.delayed(
          const Duration(microseconds: 1), () => _focusNode.requestFocus());
    } else {
      _focusNode.requestFocus();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          widget.enableInteractiveSelection ? _fields() : _hiddenTextField(),
          !widget.enableInteractiveSelection ? _fields() : _hiddenTextField(),
        ],
      ),
    );
  }

  Widget _hiddenTextField() {
    return AbsorbPointer(
      absorbing: !widget.enableInteractiveSelection,
      child: TextFormField(
        controller: _controller,
        onTap: widget.onTap,
        onEditingComplete: widget.onEditingComplete,
        onFieldSubmitted: widget.onSubmitted,
        textInputAction: widget.textInputAction,
        focusNode: _focusNode,
        enabled: widget.useNativeKeyboard,
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
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        autocorrect: false,
        showCursor: false,
        style: _hiddenTextStyle,
        scrollPadding: EdgeInsets.zero,
        decoration: _hiddenInputDecoration,
        restorationId: widget.restorationId,
        textDirection: widget.textDirection,
        obscuringCharacter: widget.obscuringCharacter,
        selectionControls: widget.selectionControls,
        enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
      ),
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
        height: pinTheme.height,
        width: pinTheme.width,
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

  PinTheme _getDefaultPinTheme() => widget.defaultPinTheme ?? _defaultPinTheme;

  PinTheme _pinThemeOrDefault(PinTheme? theme) =>
      theme ?? _getDefaultPinTheme();

  Widget _buildFieldContent(int index, PinTheme pinTheme) {
    final key = ValueKey<String>(index < pin.length ? pin[index] : '');
    final isSubmittedPin = index < pin.length;

    if (isSubmittedPin) {
      if (widget.obscureText && widget.obscuringWidget != null) {
        return SizedBox(key: key, child: widget.obscuringWidget);
      }

      return Text(
        widget.obscureText ? widget.obscuringCharacter : pin[index],
        key: key,
        style: pinTheme.textStyle,
      );
    }

    final isActiveField = index == pin.length;
    final focused = _focusNode.hasFocus || !widget.useNativeKeyboard;

    if (widget.showCursor && isActiveField && focused) {
      return _PinputCursor(
          textStyle: pinTheme.textStyle, cursor: widget.cursor);
    }

    if (widget.preFilledWidget != null) {
      return SizedBox(key: key, child: widget.preFilledWidget);
    }

    return Text('', key: key, style: pinTheme.textStyle);
  }

  PinTheme _pinTheme(int index) {
    /// Disabled pin or default
    if (!widget.enabled) {
      return _pinThemeOrDefault(widget.disabledPinTheme);
    }

    final isLastPin = selectedIndex == widget.length;
    final hasFocus =
        _focusNode.hasFocus || (!widget.useNativeKeyboard && !isLastPin);

    if (!hasFocus && widget.showError) {
      return _pinThemeOrDefault(widget.errorPinTheme);
    }

    /// Focused pin or default
    if (hasFocus && index == selectedIndex.clamp(0, widget.length - 1)) {
      return _pinThemeOrDefault(widget.focusedPinTheme);
    }

    /// Submitted pin or default
    if (index < selectedIndex) {
      return _pinThemeOrDefault(widget.submittedPinTheme);
    }

    /// Following pin or default
    return _pinThemeOrDefault(widget.followingPinTheme);
  }

  Widget _getTransition(Widget child, Animation animation) {
    if (child is _PinputCursor) {
      return child;
    }

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
