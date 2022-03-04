part of 'pinput.dart';

class _PinputState extends State<Pinput> with WidgetsBindingObserver, RestorationMixin, PinputUtils {
  final _errorTextNotifier = ValueNotifier<String?>(null);
  late TextEditingValue _recentControllerValue;
  RestorableTextEditingController? _controller;
  FocusNode? _focusNode;

  TextEditingController get _effectiveController => widget.controller ?? _controller!.value;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? (_focusNode ??= FocusNode());

  String? get errorText => _errorTextNotifier.value ?? widget.errorText;

  bool get hasError => errorText != null || widget.showError;

  int get selectedIndex => pin.length;

  String get pin => _effectiveController.text;

  bool get _completed => pin.length == widget.length;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createLocalController();
      _registerController();
    }
    _recentControllerValue = _effectiveController.value;
    _effectiveController.addListener(_onTextChangedListener);
    _effectiveFocusNode.addListener(_focusListener);
    WidgetsBinding.instance!.addObserver(this);
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

  bool get _canRequestFocus {
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ?? NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return widget.enabled;
      case NavigationMode.directional:
        return true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _effectiveFocusNode.canRequestFocus = _canRequestFocus;
  }

  @override
  void didUpdateWidget(covariant Pinput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChangedListener);
      widget.controller?.addListener(_onTextChangedListener);
    }
    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
    }

    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _focusNode)?.removeListener(_focusListener);
      (widget.focusNode ?? _focusNode)?.addListener(_focusListener);
    }
    _effectiveFocusNode.canRequestFocus = _canRequestFocus;
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_focusListener);
    _focusNode?.dispose();
    _effectiveController.removeListener(_onTextChangedListener);
    _controller?.dispose();
    _errorTextNotifier.dispose();
    super.dispose();
  }

  void _onTextChangedListener() {
    final textChanged = _recentControllerValue.text != _effectiveController.value.text;

    _recentControllerValue = _effectiveController.value;
    if (textChanged) {
      if (_completed) {
        _validateOnSubmit(pin);
        widget.onCompleted?.call(pin);
        if (widget.closeKeyboardWhenCompleted) {
          _effectiveFocusNode.unfocus();
        }
      }
      widget.onChanged?.call(pin);
      _maybeUseHaptic(widget.hapticFeedbackType);
      _maybeClearError(pin);
      setState(() {});
    }
  }

  void _maybeClearError(String pin) {
    if (widget.pinputValidateMode == PinputValidateMode.onSubmit && pin.length < widget.length) {
      _errorTextNotifier.value = null;
    }
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

  void _handleTap() {
    final isKeyboardHidden = MediaQueryData.fromWindow(window).viewInsets.bottom == 0;

    if (_effectiveFocusNode.hasFocus && isKeyboardHidden) {
      _effectiveFocusNode.unfocus();
      Future.delayed(const Duration(microseconds: 1), () => _effectiveFocusNode.requestFocus());
    } else {
      _effectiveFocusNode.requestFocus();
    }
    widget.onTap?.call();
  }

  void _validateOnSubmit(String s) {
    if (widget.validator != null && widget.pinputValidateMode == PinputValidateMode.onSubmit) {
      final res = widget.validator!.call(s);
      _setErrorText(res);
    }
    widget.onSubmitted?.call(s);
  }

  String? _validator(String? s) {
    if (widget.pinputValidateMode == PinputValidateMode.onSubmit) {
      return null;
    }
    final res = widget.validator!.call(s);
    _setErrorText(res);
    return res;
  }

  void _setErrorText(String? text) async {
    await Future<void>.delayed(Duration.zero);
    _errorTextNotifier.value = text;
  }

  @override
  Widget build(BuildContext context) {
    return _PasteWrapper(
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      controller: _effectiveController,
      length: widget.length,
      toolbarEnabled: widget.toolbarEnabled,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _buildFields(),
          _buildHiddenTextField(),
        ],
      ),
    );
  }

  Widget _buildHiddenTextField() {
    return AbsorbPointer(
      absorbing: true,
      child: Theme(
        data: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.redAccent,
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.transparent,
            selectionColor: Colors.transparent,
            selectionHandleColor: Colors.transparent,
          ),
        ),
        child: TextFormField(
          controller: _effectiveController,
          focusNode: _effectiveFocusNode,
          onTap: widget.onTap,
          toolbarOptions: ToolbarOptions(),
          enableInteractiveSelection: false,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: _validateOnSubmit,
          textInputAction: widget.textInputAction,
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
          maxLength: widget.length,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          textAlign: TextAlign.center,
          autocorrect: false,
          showCursor: false,
          style: _hiddenTextStyle,
          scrollPadding: EdgeInsets.zero,
          decoration: _hiddenInputDecoration,
          restorationId: widget.restorationId,
          textDirection: widget.textDirection,
          obscuringCharacter: widget.obscuringCharacter,
          enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
          validator: widget.validator != null ? _validator : null,
          autovalidateMode: _mappedAutoValidateMode(widget.pinputValidateMode),
        ),
      ),
    );
  }

  Widget _buildFields() {
    Widget _onlyFields() {
      return _SeparatedRaw(
        children: Iterable<int>.generate(widget.length).map(_getField).toList(),
        separator: widget.separator,
        separatorPositions: widget.separatorPositions,
        mainAxisAlignment: widget.mainAxisAlignment,
      );
    }

    if (widget.pinputValidateMode == PinputValidateMode.disabled) {
      return _onlyFields();
    }

    return ValueListenableBuilder<String?>(
      valueListenable: _errorTextNotifier,
      builder: (BuildContext context, errorText, Widget? child) {
        return AnimatedSize(
          duration: widget.animationDuration,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_onlyFields(), _buildError()],
          ),
        );
      },
    );
  }

  Widget _buildError() {
    if (hasError) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!.call(errorText!);
      }

      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(errorText!, style: widget.errorTextStyle ?? _errorTextStyle),
      );
    }

    return SizedBox.shrink();
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

  PinTheme _getDefaultPinTheme() => widget.defaultPinTheme ?? _defaultPinTheme;

  PinTheme _pinThemeOrDefault(PinTheme? theme) => theme ?? _getDefaultPinTheme();

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
    final focused = _effectiveFocusNode.hasFocus || !widget.useNativeKeyboard;

    if (widget.showCursor && isActiveField && focused) {
      return _PinputCursor(textStyle: pinTheme.textStyle, cursor: widget.cursor);
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
    final hasFocus = _effectiveFocusNode.hasFocus || (!widget.useNativeKeyboard && !isLastPin);

    if (!hasFocus && hasError) {
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
}
