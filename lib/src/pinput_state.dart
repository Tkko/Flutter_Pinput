part of 'pinput.dart';

class _PinputState extends State<Pinput>
    with RestorationMixin, _PinputUtilsMixin
    implements TextSelectionGestureDetectorBuilderDelegate, AutofillClient {
  @override
  late bool forcePressEnabled;

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get selectionEnabled =>
      _editableText?.widget.selectionEnabled ??
      (widget.enableInteractiveSelection ??
          (!(_isReadOnly || !isEnabled || !_useNativeKeyboard) ||
              widget.obscuring == null));

  @override
  String get autofillId => _editableText!.autofillId;

  @override
  String? get restorationId => widget.restorationId;

  late TextEditingValue _recentControllerValue;
  late final _PinputSelectionGestureDetectorBuilder _gestureDetectorBuilder;
  RestorableTextEditingController? _controller;
  FocusNode? _focusNode;
  bool _isHovering = false;
  SmsRetriever? _smsRetriever;

  String? get _errorText => switch (widget.validationState) {
    PinputValidationInvalid(:final message) => message,
    _ => null,
  };

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!.value;

  @protected
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  @protected
  bool get hasError => widget.validationState is PinputValidationInvalid;

  @protected
  bool get isEnabled => widget.inputMode != PinInputMode.disabled;

  bool get _isReadOnly => widget.inputMode == PinInputMode.readOnly;

  bool get _useNativeKeyboard =>
      widget.inputMode != PinInputMode.customKeyboard;

  late List<String?> _slots;
  int _focusedSlotIndex = 0;
  TextSelection? _pinTapSelection;

  bool get _hasPinTapSelection =>
      _pinTapSelection != null &&
      _effectiveController.selection == _pinTapSelection;

  void _syncSlotsFromExternalText(String text) {
    final chars = text.characters.toList();
    _slots = List<String?>.generate(
      widget.length,
      (index) => index < chars.length ? chars[index] : null,
    );
    _focusedSlotIndex = chars.length.clamp(0, widget.length);
  }

  TextEditingValue _editingValueForSlot(int index) {
    _focusedSlotIndex = index.clamp(0, widget.length);
    return TextEditingValue(
      text: pin,
      selection: TextSelection.collapsed(
        offset: _offsetForSlot(_focusedSlotIndex),
      ),
    );
  }

  TextEditingValue _replacePinText(String text) {
    _syncSlotsFromExternalText(text);
    return _editingValueForSlot(_focusedSlotIndex);
  }

  TextEditingValue _insertPinText(String text, int index) {
    if (index == widget.length && _firstEmptySlotIndex == widget.length) {
      return _editingValueForSlot(index);
    }
    var currentSlot = index.clamp(0, widget.length - 1);
    if (_slots[currentSlot] == null) {
      currentSlot = min(currentSlot, _firstEmptySlotIndex);
    }
    for (final char in text.characters) {
      if (currentSlot >= widget.length) break;
      _slots[currentSlot++] = char;
    }
    if (widget.pinEditMode == PinEditMode.clearFollowing) {
      _slots.fillRange(currentSlot, widget.length, null);
    }
    return _editingValueForSlot(currentSlot);
  }

  TextEditingValue _deletePinAt(int index) {
    var currentSlot = index.clamp(0, widget.length - 1);
    final clearFollowing =
        _slots[currentSlot] != null &&
        widget.pinEditMode == PinEditMode.clearFollowing;
    if (_slots[currentSlot] == null && currentSlot > 0) {
      currentSlot--;
    }
    _slots[currentSlot] = null;
    if (clearFollowing) {
      _slots.fillRange(currentSlot + 1, widget.length, null);
    }
    return _editingValueForSlot(currentSlot);
  }

  int get _firstEmptySlotIndex {
    for (int i = 0; i < widget.length && i < _slots.length; i++) {
      if (_slots[i] == null || _slots[i]!.isEmpty) return i;
    }
    return widget.length;
  }

  String _slotValue(int index) {
    if (index >= 0 && index < widget.length && index < _slots.length) {
      return _slots[index] ?? '';
    }
    return '';
  }

  int _offsetForSlot(int slotIndex) {
    int count = 0;
    for (
      int i = 0;
      i < slotIndex && i < widget.length && i < _slots.length;
      i++
    ) {
      if (_slots[i] != null && _slots[i]!.isNotEmpty) {
        count += _slots[i]!.length;
      }
    }
    return count;
  }

  int _slotForOffset(int offset) {
    int currentOffset = 0;
    for (int i = 0; i < widget.length && i < _slots.length; i++) {
      if (currentOffset >= offset) return i;
      if (_slots[i] != null && _slots[i]!.isNotEmpty) {
        currentOffset += _slots[i]!.length;
      }
    }
    return widget.length;
  }

  int get _currentFilledCount =>
      _slots.where((s) => s != null && s.isNotEmpty).length;

  int get _currentLength => _effectiveController.value.text.characters.length;

  EditableTextState? get _editableText => editableTextKey.currentState;

  /// Index of the active pin.
  int get selectedIndex {
    if (widget.pinEditMode == PinEditMode.none) return _firstEmptySlotIndex;
    final selection = _effectiveController.selection;
    if (selection.isValid && selection.baseOffset >= 0) {
      final leadingOffset = min(
        selection.start,
        _effectiveController.text.length,
      );
      // Gaps can give multiple slots the same text offset. Keep an explicitly
      // focused slot when the controller still points at its boundary.
      if (selection.isCollapsed &&
          _offsetForSlot(_focusedSlotIndex) == leadingOffset) {
        return _focusedSlotIndex.clamp(0, widget.length);
      }
      return _slotForOffset(leadingOffset).clamp(0, widget.length);
    }
    return _focusedSlotIndex.clamp(0, widget.length);
  }

  String get pin => _slots.map((s) => s ?? '').join('');

  bool get _completed =>
      _effectiveController.text.characters.length == widget.length &&
      _slots.length == widget.length &&
      _slots.every((s) => s != null && s.isNotEmpty);

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

    _syncSlotsFromExternalText(widget.controller?.text ?? '');
    _effectiveFocusNode.canRequestFocus = isEnabled;
    _maybeInitSmartAuth();
  }

  /// Android Autofill
  void _maybeInitSmartAuth() async {
    if (_smsRetriever == null && widget.smsRetriever != null) {
      _smsRetriever = widget.smsRetriever!;
      _listenForSmsCode();
    }
  }

  void _listenForSmsCode() async {
    final retriever = _smsRetriever!;
    final res = await retriever.getSmsCode();
    if (!mounted || _smsRetriever != retriever) return;
    if (res != null && res.characters.length == widget.length) {
      _effectiveController.setText(res);
    }
    // Listen for multiple sms codes
    if (mounted &&
        _smsRetriever == retriever &&
        retriever.listenForMultipleSms) {
      _listenForSmsCode();
    }
  }

  void _handleTextEditingControllerChanges() {
    final currentText = _effectiveController.value.text;
    final textChanged = _recentControllerValue.text != currentText;
    _recentControllerValue = _effectiveController.value;
    if (!_hasPinTapSelection) _pinTapSelection = null;

    final currentFilled = _slots.map((s) => s ?? '').join('');
    if (currentText != currentFilled) {
      _syncSlotsFromExternalText(currentText);
    }

    if (textChanged) {
      _onChanged(pin);
    }
  }

  void _onChanged(String pin) {
    widget.onChanged?.call(pin);
    if (_completed) {
      // While the user edits a pin in the middle, the PIN is only "completed"
      // once the cursor reaches the end, so auto-submitting apps never receive
      // a half-edited code.
      final cursorAtEnd = selectedIndex == widget.length;
      if (cursorAtEnd) widget.onCompleted?.call(pin);
      if (cursorAtEnd) _maybeCloseKeyboard();
    }
  }

  void _maybeCloseKeyboard() {
    if (widget.closeKeyboardWhenCompleted && selectedIndex == widget.length) {
      _effectiveFocusNode.unfocus();
    }
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
      _syncSlotsFromExternalText(_effectiveController.text);
      _recentControllerValue = _effectiveController.value;
      _pinTapSelection = null;
    } else if (widget.length != oldWidget.length) {
      _syncSlotsFromExternalText(_effectiveController.text);
    }

    _effectiveFocusNode.canRequestFocus = isEnabled;
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
      _syncSlotsFromExternalText(_controller!.value.text);
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
    final retriever = _smsRetriever;
    _smsRetriever = null;
    widget.controller?.removeListener(_handleTextEditingControllerChanges);
    _controller?.removeListener(_handleTextEditingControllerChanges);
    _controller?.dispose();
    _focusNode?.dispose();
    retriever?.dispose();
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
    final textLength = _effectiveController.text.length;
    if (widget.pinEditMode != PinEditMode.none) {
      if (selection.isCollapsed && selection.baseOffset > textLength) {
        _effectiveController.selection = TextSelection.collapsed(
          offset: textLength,
        );
      }
    } else {
      // Selecting part of the text is not allowed.
      final allSelected = selection.start == 0 && selection.end == textLength;
      final lastCharOffset = _effectiveController.text.characters
          .take(max(0, _currentLength - 1))
          .string
          .length;
      final lastCharSelected =
          selection.start == lastCharOffset && selection.end == textLength;
      if (!allSelected && !lastCharSelected) {
        _effectiveController.selection = TextSelection.collapsed(
          offset: textLength,
        );
      }
    }

    if (cause == SelectionChangedCause.longPress ||
        cause == SelectionChangedCause.drag) {
      _editableText?.bringIntoView(selection.extent);
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
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final isDense = widget.layout.mainAxisAlignment == MainAxisAlignment.center;

    return isDense ? IntrinsicWidth(child: _buildPinput()) : _buildPinput();
  }

  Widget _buildPinput() {
    VoidCallback? handleDidGainAccessibilityFocus;
    forcePressEnabled = defaultTargetPlatform == TargetPlatform.iOS;
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      handleDidGainAccessibilityFocus = () {
        if (!_effectiveFocusNode.hasFocus &&
            _effectiveFocusNode.canRequestFocus) {
          _effectiveFocusNode.requestFocus();
        }
      };
    }

    return MouseRegion(
      cursor: _effectiveMouseCursor,
      onEnter: (PointerEnterEvent event) => _handleHover(true),
      onExit: (PointerExitEvent event) => _handleHover(false),
      child: TextFieldTapRegion(
        child: IgnorePointer(
          ignoring: !isEnabled || !_useNativeKeyboard,
          child: AnimatedBuilder(
            animation: _effectiveController,
            builder: (_, Widget? child) => Semantics(
              label: widget.semanticsLabel,
              maxValueLength: widget.length,
              currentValueLength: _currentFilledCount,
              enabled: isEnabled,
              onTap: _isReadOnly ? null : _semanticsOnTap,
              onDidGainAccessibilityFocus: handleDidGainAccessibilityFocus,
              onFocus: isEnabled
                  ? () {
                      if (_effectiveFocusNode.canRequestFocus &&
                          !_effectiveFocusNode.hasFocus) {
                        _effectiveFocusNode.requestFocus();
                      } else if (!_isReadOnly) {
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
                  Positioned.fill(child: _buildEditable()),
                  _buildFields(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditable() {
    final formatters = <TextInputFormatter>[
      ...widget.inputFormatters,
      if (widget.pinEditMode != PinEditMode.none)
        _PinOverwriteTextInputFormatter(this),
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
            _maybeUseHaptic(widget.hapticFeedbackType);
          },
          expands: false,
          showCursor: false,
          autocorrect: false,
          autofillClient: this,
          showSelectionHandles: false,
          rendererIgnoresPointer: true,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          enableIMEPersonalizedLearning: false,
          textInputAction: widget.keyboard.textInputAction,
          textCapitalization: widget.keyboard.textCapitalization,
          selectionColor: PinputConstants._transparent,
          keyboardType: widget.keyboard.keyboardType,
          obscureText: widget.obscuring != null,
          onSubmitted: widget.onSubmitted,
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
          autofillHints: widget.keyboard.autofillHints,
          scrollPadding: widget.scrollPadding,
          selectionWidthStyle: BoxWidthStyle.tight,
          backgroundCursorColor: PinputConstants._transparent,
          selectionHeightStyle: BoxHeightStyle.tight,
          enableSuggestions: widget.keyboard.enableSuggestions,
          contextMenuBuilder: widget.contextMenuBuilder,
          obscuringCharacter: widget.obscuring?._character ?? '•',
          onSelectionChanged: _handleSelectionChanged,
          onSelectionHandleTapped: _handleSelectionHandleTapped,
          readOnly: _isReadOnly || !isEnabled || !_useNativeKeyboard,
          selectionControls:
              widget.selectionControls ?? _pinputSelectionControls,
          keyboardAppearance:
              widget.keyboard.keyboardAppearance ??
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
    _focusedSlotIndex = _firstEmptySlotIndex;
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
      if (_slotValue(index).isNotEmpty) {
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
    if (widget.pinEditMode != PinEditMode.none && !_isReadOnly) {
      _focusedSlotIndex = index.clamp(0, widget.length - 1);
      if (_slots[_focusedSlotIndex] == null) {
        _focusedSlotIndex = min(_focusedSlotIndex, _firstEmptySlotIndex);
      }
      final offset = _offsetForSlot(_focusedSlotIndex);
      // At offset zero a mobile keyboard may send no backspace edit. Selecting
      // the first digit gives it a native deletion target.
      _pinTapSelection = _focusedSlotIndex == 0 && _slotValue(0).isNotEmpty
          ? TextSelection(
              baseOffset: offset,
              extentOffset: offset + _slotValue(0).length,
            )
          : null;
      _effectiveController.selection =
          _pinTapSelection ?? TextSelection.collapsed(offset: offset);
      setState(() {});
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
        separatorBuilder: widget.layout.separatorBuilder,
        mainAxisAlignment: widget.layout.mainAxisAlignment,
        children: Iterable<int>.generate(widget.length).map<Widget>((index) {
          final itemBuilder = widget.itemBuilder;
          if (itemBuilder != null) {
            final child = itemBuilder(
              context,
              PinItemState(
                value: _slotValue(index),
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
          return AnimatedSize(
            duration: widget.pinAnimation.duration,
            curve: widget.pinAnimation.curve,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: widget.layout.crossAxisAlignment,
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
    return _effectiveFocusNode.hasFocus || (!_useNativeKeyboard && !isLastPin);
  }

  @protected
  bool get showErrorState {
    return hasError;
  }

  Widget _buildError() {
    if (!hasError) return const SizedBox.shrink();
    final errorText = _errorText;
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!.call(errorText, pin);
    }

    if (errorText != null) {
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
        child: Semantics(
          liveRegion: true,
          child: Text(
            errorText,
            style: widget.errorTextStyle ?? defaultErrorStyle,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // AutofillClient implementation start.
  @override
  void autofill(TextEditingValue newEditingValue) =>
      _editableText!.autofill(newEditingValue);

  @override
  TextInputConfiguration get textInputConfiguration {
    final List<String>? autofillHints = widget.keyboard.autofillHints?.toList(
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
