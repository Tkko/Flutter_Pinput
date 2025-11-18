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
  final GlobalKey<EditableTextState> editableTextKey = GlobalKey<EditableTextState>();

  @override
  bool get selectionEnabled => widget.toolbarEnabled;

  @override
  String get autofillId => _editableText?.autofillId ?? '';

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
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ?? NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return isEnabled && widget.useNativeKeyboard;
      case NavigationMode.directional:
        return widget.useNativeKeyboard;
    }
  }

  TextEditingController get _effectiveController => widget.controller ?? _controller!.value;

  @protected
  FocusNode get _effectiveFocusNode => widget.focusNode ?? (_focusNode ??= FocusNode());

  @protected
  bool get hasError => widget.forceErrorState || _validatorErrorText != null;

  @protected
  bool get isEnabled => widget.enabled;

  int get _currentLength => _effectiveController.value.text.characters.length;

  EditableTextState? get _editableText => editableTextKey.currentState;

  int get selectedIndex => pin.length;

  String get pin => _effectiveController.text;

  bool get _completed => pin.length == widget.length;

  @override
  void initState() {
    super.initState();
    _gestureDetectorBuilder = _PinputSelectionGestureDetectorBuilder(state: this);
    if (widget.controller == null) {
      _createLocalController();
      _recentControllerValue = TextEditingValue.empty;
    } else {
      _recentControllerValue = _effectiveController.value;
      widget.controller!.addListener(_handleTextEditingControllerChanges);
    }
    _effectiveFocusNode.canRequestFocus = isEnabled && widget.useNativeKeyboard;
    unawaited(_maybeInitSmartAuth());
    unawaited(_maybeCheckClipboard());
    _ambiguate(WidgetsBinding.instance)!.addObserver(this);
  }

  /// Android Autofill
  Future<void> _maybeInitSmartAuth() async {
    if (!mounted) {
      return;
    }
    if (_smsRetriever == null && widget.smsRetriever != null) {
      _smsRetriever = widget.smsRetriever;
      if (mounted) {
        await _listenForSmsCode();
      }
    }
  }

  Future<void> _listenForSmsCode() async {
    if (!mounted) {
      return;
    }

    try {
      final res = await _smsRetriever!.getSmsCode();

      if (!mounted) {
        return;
      }

      if (res != null && res.length == widget.length) {
        _effectiveController.setText(res);
        return;
      }
    } catch (e) {
      // Handle error - don't continue recursion on error
      debugPrint('SMS retriever error: $e');
    }
  }

  void _handleTextEditingControllerChanges() {
    final textChanged = _recentControllerValue.text != _effectiveController.value.text;
    _recentControllerValue = _effectiveController.value;
    if (textChanged) {
      _onChanged(pin);
    }
  }

  void _onChanged(String pin) {
    widget.onChanged?.call(pin);
    if (_completed) {
      widget.onCompleted?.call(pin);
      _maybeValidateForm();
      _maybeCloseKeyboard();
    }
  }

  void _maybeValidateForm() {
    if (widget.pinputAutovalidateMode == PinputAutoValidateMode.onSubmit) {
      _validator();
    }
  }

  void _maybeCloseKeyboard() {
    if (widget.closeKeyboardWhenCompleted) {
      _effectiveFocusNode.unfocus();
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
    assert(_controller != null, '_controller should not be null');
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null, '_controller should be null');
    _controller = value == null ? RestorableTextEditingController() : RestorableTextEditingController.fromValue(value);
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
    if (_smsRetriever != null) {
      unawaited(_smsRetriever!.dispose());
    }
    _ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    super.dispose();
  }

  void _requestKeyboard() {
    if (_effectiveFocusNode.canRequestFocus) {
      _editableText?.requestKeyboard();
    }
  }

  void _handleSelectionChanged(TextSelection selection, SelectionChangedCause? cause) {
    // Only adjust selection if it's beyond the text length
    // This allows proper backspace behavior
    final int textLength = pin.length;

    // Don't force selection during keyboard input or deletion
    if (cause == SelectionChangedCause.keyboard) {
      // Let EditableText handle cursor positioning during typing/deletion
      return;
    }

    // For other causes (tap, drag, etc.), ensure selection is valid
    if (selection.baseOffset > textLength || selection.extentOffset > textLength) {
      _effectiveController.selection = TextSelection.collapsed(offset: textLength);
    }

    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
      case TargetPlatform.android:
        if (cause == SelectionChangedCause.longPress || cause == SelectionChangedCause.drag) {
          _editableText?.bringIntoView(selection.extent);
        }
    }

    switch (Theme.of(context).platform) {
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
    }
  }

  /// Toggle the toolbar when a selection handle is tapped.
  void _handleSelectionHandleTapped() {
    if (_effectiveController.selection.isCollapsed) {
      _editableText?.toggleToolbar();
    }
  }

  void _handleHover(bool hovering) {
    if (hovering != _isHovering) {
      setState(() => _isHovering = hovering);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    if (appLifecycleState == AppLifecycleState.resumed) {
      unawaited(_maybeCheckClipboard());
    }
  }

  Future<void> _maybeCheckClipboard() async {
    if (!mounted) {
      return;
    }
    if (widget.onClipboardFound != null) {
      final clipboard = await _getClipboardOrEmpty();
      if (mounted && clipboard.length == widget.length) {
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
    assert(debugCheckHasMaterial(context), 'Pinput requires MaterialApp or Theme.');
    assert(debugCheckHasMaterialLocalizations(context), 'Pinput requires a Localizations widget to display text.');
    assert(debugCheckHasDirectionality(context), 'Pinput requires a Directionality widget to display text.');
    final isDense = widget.mainAxisAlignment == MainAxisAlignment.center;

    return isDense ? IntrinsicWidth(child: _buildPinput()) : _buildPinput();
  }

  Widget _buildPinput() {
    final theme = Theme.of(context);
    VoidCallback? handleDidGainAccessibilityFocus;
    TextSelectionControls? textSelectionControls = widget.selectionControls;

    switch (theme.platform) {
      case TargetPlatform.iOS:
        forcePressEnabled = true;
        textSelectionControls ??= cupertinoTextSelectionHandleControls;
      case TargetPlatform.macOS:
        forcePressEnabled = false;
        textSelectionControls ??= cupertinoDesktopTextSelectionHandleControls;
        handleDidGainAccessibilityFocus = () {
          if (!_effectiveFocusNode.hasFocus && _effectiveFocusNode.canRequestFocus) {
            _effectiveFocusNode.requestFocus();
          }
        };
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        forcePressEnabled = false;
        textSelectionControls ??= materialTextSelectionHandleControls;
      case TargetPlatform.linux:
        forcePressEnabled = false;
        textSelectionControls ??= desktopTextSelectionHandleControls;
      case TargetPlatform.windows:
        forcePressEnabled = false;
        textSelectionControls ??= desktopTextSelectionHandleControls;
        handleDidGainAccessibilityFocus = () {
          if (!_effectiveFocusNode.hasFocus && _effectiveFocusNode.canRequestFocus) {
            _effectiveFocusNode.requestFocus();
          }
        };
    }

    return _PinputFormField(
      enabled: isEnabled,
      validator: _validator,
      initialValue: _effectiveController.text,
      builder: (FormFieldState<String> field) => MouseRegion(
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
                child: child,
              ),
              child: _gestureDetectorBuilder.buildGestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [_buildEditable(textSelectionControls, field), _buildFields()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditable(TextSelectionControls? textSelectionControls, FormFieldState<String> field) {
    final formatters = <TextInputFormatter>[
      ...widget.inputFormatters,
      LengthLimitingTextInputFormatter(widget.length, maxLengthEnforcement: MaxLengthEnforcement.enforced),
    ];

    return RepaintBoundary(
      child: UnmanagedRestorationScope(
        bucket: bucket,
        child: EditableText(
          key: editableTextKey,
          style: PinputConstants._hiddenTextStyle,
          onChanged: (value) {
            field.didChange(value);
            _maybeUseHaptic(widget.hapticFeedbackType);
          },
          showCursor: false,
          autocorrect: false,
          autofillClient: this,
          rendererIgnoresPointer: true,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          selectionColor: Colors.transparent,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          onSubmitted: (s) {
            widget.onSubmitted?.call(s);
            _maybeValidateForm();
          },
          onTapOutside: widget.onTapOutside,
          mouseCursor: MouseCursor.defer,
          focusNode: _effectiveFocusNode,
          textAlign: TextAlign.center,
          autofocus: widget.autofocus,
          inputFormatters: formatters,
          restorationId: 'pinput',
          cursorColor: Colors.transparent,
          controller: _effectiveController,
          autofillHints: widget.autofillHints,
          scrollPadding: widget.scrollPadding,
          selectionWidthStyle: BoxWidthStyle.tight,
          backgroundCursorColor: Colors.transparent,
          selectionHeightStyle: BoxHeightStyle.tight,
          enableSuggestions: widget.enableSuggestions,
          contextMenuBuilder: widget.contextMenuBuilder,
          obscuringCharacter: widget.obscuringCharacter,
          onAppPrivateCommand: widget.onAppPrivateCommand,
          onSelectionChanged: _handleSelectionChanged,
          onSelectionHandleTapped: _handleSelectionHandleTapped,
          readOnly: widget.readOnly || !isEnabled || !widget.useNativeKeyboard,
          selectionControls: widget.toolbarEnabled ? textSelectionControls : null,
          keyboardAppearance: widget.keyboardAppearance ?? Theme.of(context).brightness,
        ),
      ),
    );
  }

  MouseCursor get _effectiveMouseCursor =>
      WidgetStateProperty.resolveAs<MouseCursor>(widget.mouseCursor ?? WidgetStateMouseCursor.textable, <WidgetState>{
        if (!isEnabled) WidgetState.disabled,
        if (_isHovering) WidgetState.hovered,
        if (_effectiveFocusNode.hasFocus) WidgetState.focused,
        if (hasError) WidgetState.error,
      });

  void _semanticsOnTap() {
    if (!_effectiveController.selection.isValid) {
      _effectiveController.selection = TextSelection.collapsed(offset: _effectiveController.text.length);
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

    if (index < selectedIndex) {
      return PinItemStateType.submitted;
    }

    return PinItemStateType.following;
  }

  Widget _buildFields() {
    Widget onlyFields() => _SeparatedRaw(
      separatorBuilder: widget.separatorBuilder,
      mainAxisAlignment: widget.mainAxisAlignment,
      children: Iterable<int>.generate(widget.length).map<Widget>((index) {
        if (widget._builder != null) {
          return widget._builder!.itemBuilder.call(
            context,
            PinItemState(value: pin.length > index ? pin[index] : '', index: index, type: _getState(index)),
          );
        }

        return _PinItem(state: this, index: index);
      }).toList(),
    );
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_effectiveFocusNode, _effectiveController]),
        builder: (BuildContext context, Widget? child) {
          final shouldHideErrorContent = widget.validator == null && widget.errorText == null;
          if (shouldHideErrorContent) {
            return onlyFields();
          }
          return AnimatedSize(
            duration: widget.animationDuration,
            alignment: Alignment.topCenter,
            child: Column(crossAxisAlignment: widget.crossAxisAlignment, children: [onlyFields(), _buildError()]),
          );
        },
      ),
    );
  }

  @protected
  bool get hasFocus {
    final isLastPin = selectedIndex == widget.length;
    return _effectiveFocusNode.hasFocus || (!widget.useNativeKeyboard && !isLastPin);
  }

  @protected
  bool get showErrorState => hasError && (!hasFocus || widget.forceErrorState);

  Widget _buildError() {
    if (showErrorState) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!.call(_errorText, pin);
      }

      final theme = Theme.of(context);
      if (_errorText != null) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, top: 8),
          child: Text(
            _errorText!,
            style: widget.errorTextStyle ?? theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  // AutofillClient implementation start.
  @override
  void autofill(TextEditingValue newEditingValue) => _editableText?.autofill(newEditingValue);

  @override
  TextInputConfiguration get textInputConfiguration {
    final List<String>? autofillHints = widget.autofillHints?.toList(growable: false);
    final AutofillConfiguration autofillConfiguration = autofillHints != null
        ? AutofillConfiguration(
            uniqueIdentifier: autofillId,
            autofillHints: autofillHints,
            currentEditingValue: _effectiveController.value,
          )
        : AutofillConfiguration.disabled;
    return _editableText?.textInputConfiguration.copyWith(autofillConfiguration: autofillConfiguration) ??
        TextInputConfiguration(autofillConfiguration: autofillConfiguration);
  }
}
