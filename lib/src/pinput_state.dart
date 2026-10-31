part of 'pinput.dart';

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? _ambiguate<T>(T? value) => value;

class _PinputState extends State<Pinput>
    with RestorationMixin, WidgetsBindingObserver, _PinputUtilsMixin
    implements TextSelectionGestureDetectorBuilderDelegate, AutofillClient {
  @override
  late bool forcePressEnabled;

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get selectionEnabled => widget.toolbarEnabled;

  @override
  String get autofillId => _editableText!.autofillId;

  @override
  String? get restorationId => widget.restorationId;

  late TextEditingValue _recentControllerValue;
  late final _PinputSelectionGestureDetectorBuilder _gestureDetectorBuilder;
  RestorableTextEditingController? _controller;
  FocusNode? _focusNode;
  bool _isHovering = false;
  String? _validatorErrorText;
  SmsRetriever? _smsRetriever;

  String? get _errorText => widget.errorText ?? _validatorErrorText;

  bool get _canRequestFocus {
    final NavigationMode mode =
        MediaQuery.maybeOf(context)?.navigationMode ??
        NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return isEnabled && widget.useNativeKeyboard;
      case NavigationMode.directional:
        return true && widget.useNativeKeyboard;
    }
  }

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!.value;

  @protected
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  @protected
  bool get hasError => widget.forceErrorState || _validatorErrorText != null;

  @protected
  bool get isEnabled => widget.enabled;

  int get _currentLength => _effectiveController.value.text.characters.length;

  EditableTextState? get _editableText => editableTextKey.currentState;

  /// Index of the active pin. Converts the controller's UTF-16 selection offset
  /// to a grapheme index so it stays consistent with [_currentLength].
  int get selectedIndex {
    if (widget.pinEditMode == PinEditMode.none) return _currentLength;
    final selection = _effectiveController.selection;
    if (!selection.isValid || selection.baseOffset < 0) {
      return _currentLength;
    }
    final text = _effectiveController.text;
    // For ranges (e.g. desktop drag selection) always use the leading edge.
    final offset = min(selection.start, text.length);
    return text.substring(0, offset).characters.length.clamp(
      0,
      _currentLength,
    );
  }

  /// Converts a grapheme index to a UTF-16 offset in the controller text.
  int _offsetOfIndex(int index) =>
      _effectiveController.text.characters.take(index).string.length;

  String get pin => _effectiveController.text;

  bool get _completed => _currentLength == widget.length;

  @override
  void initState() {
    super.initState();
    _gestureDetectorBuilder = _PinputSelectionGestureDetectorBuilder(
      state: this,
    );
    if (widget.controller != null) {
      _recentControllerValue = widget.controller!.value;
      widget.controller!.addListener(_handleTextEditingControllerChanges);
    } else {
      _createLocalController();
      _recentControllerValue = TextEditingValue.empty;
    }

    _effectiveFocusNode.canRequestFocus = isEnabled && widget.useNativeKeyboard;
    _maybeInitSmartAuth();
    _maybeCheckClipboard();
    // https://github.com/Tkko/Flutter_Pinput/issues/89
    _ambiguate(WidgetsBinding.instance)!.addObserver(this);
  }

  /// Android Autofill
  void _maybeInitSmartAuth() async {
    if (_smsRetriever == null && widget.smsRetriever != null) {
      _smsRetriever = widget.smsRetriever!;
      _listenForSmsCode();
    }
  }

  void _listenForSmsCode() async {
    final res = await _smsRetriever!.getSmsCode();
    if (res != null && res.length == widget.length) {
      _effectiveController.setText(res);
    }
    // Listen for multiple sms codes
    if (_smsRetriever!.listenForMultipleSms) {
      _listenForSmsCode();
    }
  }

  void _handleTextEditingControllerChanges() {
    final textChanged =
        _recentControllerValue.text != _effectiveController.value.text;
    _recentControllerValue = _effectiveController.value;
    if (textChanged) {
      _onChanged(pin);
    }
  }

  void _onChanged(String pin) {
    widget.onChanged?.call(pin);
    if (_completed) {
      // While the user edits a pin in the middle, the PIN is only "completed"
      // once the cursor reaches the end, so auto-submitting apps never receive
      // a half-edited code. Validation still runs to keep the error state fresh.
      final cursorAtEnd = selectedIndex == widget.length;
      if (cursorAtEnd) widget.onCompleted?.call(pin);
      _maybeValidateForm();
      if (cursorAtEnd) _maybeCloseKeyboard();
    }
  }

  void _maybeValidateForm() {
    if (widget.pinputAutovalidateMode == PinputAutovalidateMode.onSubmit) {
      _validator();
    }
  }

  void _maybeCloseKeyboard() {
    if (widget.closeKeyboardWhenCompleted) {
      if (selectedIndex == widget.length) {
        _effectiveFocusNode.unfocus();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _effectiveFocusNode.canRequestFocus = _canRequestFocus;
  }

  @override
  void didUpdateWidget(Pinput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);
      _controller!.removeListener(_handleTextEditingControllerChanges);
      _controller!.dispose();
      _controller = null;
    }

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleTextEditingControllerChanges);
      widget.controller?.addListener(_handleTextEditingControllerChanges);
    }

    _effectiveFocusNode.canRequestFocus = _canRequestFocus;
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
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
    _controller!.addListener(_handleTextEditingControllerChanges);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleTextEditingControllerChanges);
    _controller?.removeListener(_handleTextEditingControllerChanges);
    _controller?.dispose();
    _focusNode?.dispose();
    _smsRetriever?.dispose();
    // https://github.com/Tkko/Flutter_Pinput/issues/89
    _ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    super.dispose();
  }

  void _requestKeyboard() {
    if (_effectiveFocusNode.canRequestFocus) {
      _editableText?.requestKeyboard();
    }
  }

  void _handleSelectionChanged(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    if (widget.pinEditMode != PinEditMode.none) {
      if (selection.isCollapsed && selection.baseOffset > _currentLength) {
        _effectiveController.selection = TextSelection.collapsed(
          offset: _currentLength,
        );
      }
    } else {
      // Selecting part of the text is not allowed.
      final allSelected = selection.start == 0 && selection.end == _currentLength;
      final lastCharSelected =
          selection.start == _currentLength - 1 &&
          selection.end == _currentLength;
      if (!allSelected && !lastCharSelected) {
        _effectiveController.selection = TextSelection.collapsed(
          offset: _currentLength,
        );
      }
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
      case TargetPlatform.android:
        if (cause == SelectionChangedCause.longPress ||
            cause == SelectionChangedCause.drag) {
          _editableText?.bringIntoView(selection.extent);
        }
        break;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.android:
        break;
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        if (cause == SelectionChangedCause.drag) {
          _editableText?.hideToolbar();
        }
        break;
    }
  }

  /// Toggle the toolbar when a selection handle is tapped.
  void _handleSelectionHandleTapped() {
    if (_effectiveController.selection.isCollapsed) {
      _editableText!.toggleToolbar();
    }
  }

  void _handleHover(bool hovering) {
    if (hovering != _isHovering) {
      setState(() => _isHovering = hovering);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) async {
    if (appLifecycleState == AppLifecycleState.resumed) {
      _maybeCheckClipboard();
    }
  }

  void _maybeCheckClipboard() async {
    if (widget.onClipboardFound != null) {
      final clipboard = await _getClipboardOrEmpty();
      if (clipboard.length == widget.length) {
        widget.onClipboardFound!.call(clipboard);
      }
    }
  }

  String? _validator([String? _]) {
    final res = widget.validator?.call(pin);
    setState(() => _validatorErrorText = res);
    return res;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final isDense = widget.mainAxisAlignment == MainAxisAlignment.center;

    return isDense ? IntrinsicWidth(child: _buildPinput()) : _buildPinput();
  }

  Widget _buildPinput() {
    VoidCallback? handleDidGainAccessibilityFocus;
    TextSelectionControls? textSelectionControls = widget.selectionControls;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        forcePressEnabled = true;
        textSelectionControls ??= _pinputSelectionControls;
        break;
      case TargetPlatform.macOS:
        forcePressEnabled = false;
        textSelectionControls ??= _pinputSelectionControls;
        handleDidGainAccessibilityFocus = () {
          if (!_effectiveFocusNode.hasFocus &&
              _effectiveFocusNode.canRequestFocus) {
            _effectiveFocusNode.requestFocus();
          }
        };
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        forcePressEnabled = false;
        textSelectionControls ??= _pinputSelectionControls;
        break;
      case TargetPlatform.linux:
        forcePressEnabled = false;
        textSelectionControls ??= _pinputSelectionControls;
        break;
      case TargetPlatform.windows:
        forcePressEnabled = false;
        textSelectionControls ??= _pinputSelectionControls;
        handleDidGainAccessibilityFocus = () {
          if (!_effectiveFocusNode.hasFocus &&
              _effectiveFocusNode.canRequestFocus) {
            _effectiveFocusNode.requestFocus();
          }
        };
        break;
    }

    return _PinputFormField(
      enabled: isEnabled,
      validator: _validator,
      initialValue: _effectiveController.text,
      builder: (field) {
        return MouseRegion(
          cursor: _effectiveMouseCursor,
          onEnter: (PointerEnterEvent event) => _handleHover(true),
          onExit: (PointerExitEvent event) => _handleHover(false),
          child: TextFieldTapRegion(
            child: IgnorePointer(
              ignoring: !isEnabled || !widget.useNativeKeyboard,
              child: AnimatedBuilder(
                animation: _effectiveController,
                builder: (_, Widget? child) => Semantics(
                  maxValueLength: widget.length,
                  currentValueLength: _currentLength,
                  enabled: isEnabled,
                  onTap: widget.readOnly ? null : _semanticsOnTap,
                  onDidGainAccessibilityFocus: handleDidGainAccessibilityFocus,
                  onFocus: isEnabled
                      ? () {
                          if (_effectiveFocusNode.canRequestFocus &&
                              !_effectiveFocusNode.hasFocus) {
                            _effectiveFocusNode.requestFocus();
                          } else if (!widget.readOnly) {
                            _requestKeyboard();
                          }
                        }
                      : null,
                  child: child,
                ),
                child: _gestureDetectorBuilder.buildGestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // the editable need to be the full size, otherwise the focus is not correct when getting the render box from the focus
                      Positioned.fill(
                        child: _buildEditable(textSelectionControls, field),
                      ),
                      _buildFields(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditable(
    TextSelectionControls? textSelectionControls,
    FormFieldState<String> field,
  ) {
    final formatters = <TextInputFormatter>[
      ...widget.inputFormatters,
      if (widget.pinEditMode != PinEditMode.none)
        _PinOverwriteTextInputFormatter(widget.length, widget.pinEditMode),
      LengthLimitingTextInputFormatter(
        widget.length,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
      ),
    ];

    return RepaintBoundary(
      child: UnmanagedRestorationScope(
        bucket: bucket,
        child: EditableText(
          key: editableTextKey,
          maxLines: 1,
          style: PinputConstants._hiddenTextStyle,
          onChanged: (value) {
            field.didChange(value);
            _maybeUseHaptic(widget.hapticFeedbackType);
          },
          expands: false,
          showCursor: false,
          autocorrect: false,
          autofillClient: this,
          showSelectionHandles: false,
          rendererIgnoresPointer: true,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          selectionColor: PinputConstants._transparent,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          onSubmitted: (s) {
            widget.onSubmitted?.call(s);
            _maybeValidateForm();
          },
          onTapOutside: widget.onTapOutside,
          onTapUpOutside: widget.onTapUpOutside,
          mouseCursor: MouseCursor.defer,
          focusNode: _effectiveFocusNode,
          textAlign: TextAlign.center,
          autofocus: widget.autofocus,
          inputFormatters: formatters,
          restorationId: 'pinput',
          clipBehavior: Clip.hardEdge,
          cursorColor: PinputConstants._transparent,
          controller: _effectiveController,
          autofillHints: widget.autofillHints,
          scrollPadding: widget.scrollPadding,
          selectionWidthStyle: BoxWidthStyle.tight,
          backgroundCursorColor: PinputConstants._transparent,
          selectionHeightStyle: BoxHeightStyle.tight,
          enableSuggestions: widget.enableSuggestions,
          contextMenuBuilder: widget.contextMenuBuilder,
          obscuringCharacter: widget.obscuringCharacter,
          onAppPrivateCommand: widget.onAppPrivateCommand,
          onSelectionChanged: _handleSelectionChanged,
          onSelectionHandleTapped: _handleSelectionHandleTapped,
          readOnly: widget.readOnly || !isEnabled || !widget.useNativeKeyboard,
          selectionControls: widget.toolbarEnabled
              ? textSelectionControls
              : null,
          keyboardAppearance:
              widget.keyboardAppearance ??
              MediaQuery.maybePlatformBrightnessOf(context) ??
              Brightness.light,
        ),
      ),
    );
  }

  MouseCursor get _effectiveMouseCursor {
    return WidgetStateProperty.resolveAs<MouseCursor>(
      widget.mouseCursor ?? SystemMouseCursors.text,
      <WidgetState>{
        if (!isEnabled) WidgetState.disabled,
        if (_isHovering) WidgetState.hovered,
        if (_effectiveFocusNode.hasFocus) WidgetState.focused,
        if (hasError) WidgetState.error,
      },
    );
  }

  void _semanticsOnTap() {
    if (!_effectiveController.selection.isValid) {
      _effectiveController.selection = TextSelection.collapsed(
        offset: _effectiveController.text.length,
      );
    }
    _requestKeyboard();
  }

  PinItemStateType _getState(int index) {
    if (!isEnabled) {
      return PinItemStateType.disabled;
    }

    if (showErrorState) {
      return PinItemStateType.error;
    }

    if (hasFocus && index == selectedIndex.clamp(0, widget.length - 1)) {
      return PinItemStateType.focused;
    }

    if (widget.pinEditMode != PinEditMode.none) {
      if (index < _currentLength) {
        return PinItemStateType.submitted;
      }
      return PinItemStateType.following;
    }

    if (index < selectedIndex) {
      return PinItemStateType.submitted;
    }

    return PinItemStateType.following;
  }

  void _onPinTap(int index) {
    if (!isEnabled) return;

    // Mirrors the legacy tap behavior (hide toolbar, request keyboard, onTap)
    // and additionally moves the cursor when pin editing is available.
    if (widget.pinEditMode != PinEditMode.none && !widget.readOnly) {
      _effectiveController.selection = TextSelection.collapsed(
        offset: _offsetOfIndex(min(index, _currentLength)),
      );
    }
    _editableText?.hideToolbar();
    _requestKeyboard();
    widget.onTap?.call();
  }

  /// Adds tap handling to a pin item without breaking [Flex] parent data when
  /// a custom builder returns [Flexible] / [Expanded].
  Widget _wrapWithPinTap(int index, Widget child) {
    Widget detector(Widget c) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: () => _onPinTap(index),
      child: c,
    );

    if (child is Flexible) {
      return Flexible(
        key: child.key,
        flex: child.flex,
        fit: child.fit,
        child: detector(child.child),
      );
    }
    return detector(child);
  }

  Widget _buildFields() {
    Widget onlyFields() {
      return _SeparatedRaw(
        separatorBuilder: widget.separatorBuilder,
        mainAxisAlignment: widget.mainAxisAlignment,
        children: Iterable<int>.generate(widget.length).map<Widget>((index) {
          if (widget._builder != null) {
            final child = widget._builder!.itemBuilder.call(
              context,
              PinItemState(
                value: pin.length > index ? pin[index] : '',
                index: index,
                type: _getState(index),
              ),
            );
            return _wrapWithPinTap(index, child);
          }

          return _PinItem(state: this, index: index);
        }).toList(),
      );
    }

    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          _effectiveFocusNode,
          _effectiveController,
        ]),
        builder: (BuildContext context, Widget? child) {
          final shouldHideErrorContent =
              widget.validator == null && widget.errorText == null;

          if (shouldHideErrorContent) return onlyFields();

          return AnimatedSize(
            duration: widget.animationDuration,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: widget.crossAxisAlignment,
              children: [onlyFields(), _buildError()],
            ),
          );
        },
      ),
    );
  }

  @protected
  bool get hasFocus {
    final isLastPin = selectedIndex == widget.length;
    return _effectiveFocusNode.hasFocus ||
        (!widget.useNativeKeyboard && !isLastPin);
  }

  @protected
  bool get showErrorState {
    return hasError &&
        (!hasFocus || widget.showErrorWhenFocused || widget.forceErrorState);
  }

  Widget _buildError() {
    if (showErrorState) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!.call(_errorText, pin);
      }

      if (_errorText != null) {
        final isDark =
            MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
        final defaultErrorStyle = TextStyle(
          color: isDark
              ? PinputConstants._defaultDarkErrorColor
              : PinputConstants._defaultLightErrorColor,
          fontSize: 12,
          decoration: TextDecoration.none,
        );
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, top: 8),
          child: Text(
            _errorText!,
            style: widget.errorTextStyle ?? defaultErrorStyle,
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  // AutofillClient implementation start.
  @override
  void autofill(TextEditingValue newEditingValue) =>
      _editableText!.autofill(newEditingValue);

  @override
  TextInputConfiguration get textInputConfiguration {
    final List<String>? autofillHints = widget.autofillHints?.toList(
      growable: false,
    );
    final AutofillConfiguration autofillConfiguration = autofillHints != null
        ? AutofillConfiguration(
            uniqueIdentifier: autofillId,
            autofillHints: autofillHints,
            currentEditingValue: _effectiveController.value,
          )
        : AutofillConfiguration.disabled;

    return _editableText!.textInputConfiguration.copyWith(
      autofillConfiguration: autofillConfiguration,
    );
  }
}
