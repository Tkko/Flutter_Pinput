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
  int _cursorPosition = 0;
  bool _isReplacing = false; // Track if we're in replacement mode
  bool _hasCalledOnCompleted =
      false; // Track if onCompleted has been called for current completion

  // For enableEditingInMiddle: track characters at their visual positions
  List<String?> _pinValues = [];

  String? get _errorText => widget.errorText ?? _validatorErrorText;

  bool get _canRequestFocus {
    final NavigationMode mode = MediaQuery.maybeOf(context)?.navigationMode ??
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
  FocusNode get effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  @protected
  bool get hasError => widget.forceErrorState || _validatorErrorText != null;

  @protected
  bool get isEnabled => widget.enabled;

  int get _currentLength => _effectiveController.value.text.characters.length;

  EditableTextState? get _editableText => editableTextKey.currentState;

  int get selectedIndex =>
      widget.enableEditingInMiddle ? _cursorPosition : pin.length;

  int get currentCursorPosition => _cursorPosition;

  String get pin => widget.enableEditingInMiddle
      ? _pinValues.where((char) => char != null).join('')
      : _effectiveController.text;

  bool get _completed => pin.length == widget.length;

  /// Sync the pin values array with the current text (for backwards compatibility)
  void _syncPinValuesFromText() {
    if (!widget.enableEditingInMiddle) return;

    final text = _effectiveController.text;

    // Clear all positions first
    for (int i = 0; i < _pinValues.length; i++) {
      _pinValues[i] = null;
    }

    // Fill positions with characters from text sequentially
    for (int i = 0; i < text.length && i < widget.length; i++) {
      _pinValues[i] = text[i];
    }

    // Update cursor position to the next empty position or end
    _cursorPosition = _findNextAvailablePosition();

    // Reset completion flag when syncing from text
    if (widget.callOnCompletedOnlyOnUnfocus) {
      _hasCalledOnCompleted = false;
    }
  }

  /// Find the next available (empty) position for cursor placement
  int _findNextAvailablePosition() {
    for (int i = 0; i < _pinValues.length; i++) {
      if (_pinValues[i] == null) {
        return i;
      }
    }
    // If all positions are filled, place cursor beyond the last position
    return widget.length;
  }

  /// Get the character at a specific visual position
  String? _getCharAtPosition(int index) {
    if (!widget.enableEditingInMiddle) {
      // Use the old behavior for backwards compatibility
      return index < pin.length ? pin[index] : null;
    }

    if (index >= 0 && index < _pinValues.length) {
      return _pinValues[index];
    }
    return null;
  }

  /// Get the cursor position in the text controller for a given visual index
  int _getCursorPositionInText(int visualIndex) {
    if (!widget.enableEditingInMiddle) {
      return _effectiveController.text.length;
    }

    // For editing in middle, cursor position in text should correspond to
    // the number of filled positions up to and including the visual index
    int textPosition = 0;
    for (int i = 0; i <= visualIndex && i < _pinValues.length; i++) {
      if (_pinValues[i] != null) {
        textPosition++;
      }
    }
    return textPosition;
  }

  /// Get the visual position for a given text controller position
  int _getVisualPositionFromText(int textPosition) {
    if (!widget.enableEditingInMiddle) {
      return textPosition;
    }

    // Count filled positions to find the corresponding visual position
    int currentTextPos = 0;
    for (int i = 0; i < _pinValues.length; i++) {
      if (_pinValues[i] != null) {
        if (currentTextPos == textPosition) {
          return i;
        }
        currentTextPos++;
      }
    }

    // If text position is beyond filled characters, return current cursor position
    return _cursorPosition.clamp(0, _pinValues.length - 1);
  }

  @override
  void initState() {
    super.initState();
    _gestureDetectorBuilder =
        _PinputSelectionGestureDetectorBuilder(state: this);
    if (widget.controller == null) {
      _createLocalController();
      _recentControllerValue = TextEditingValue.empty;
    } else {
      _recentControllerValue = _effectiveController.value;
      widget.controller!.addListener(_handleTextEditingControllerChanges);
    }

    // Initialize pin values array for enableEditingInMiddle
    _pinValues = List.filled(widget.length, null);
    if (widget.enableEditingInMiddle) {
      _syncPinValuesFromText();
    } else {
      // If a controller was provided use its text, otherwise rely on the
      // recentControllerValue to avoid accessing a Restorable controller
      // before it's registered (which would assert).
      _cursorPosition = widget.controller != null
          ? _effectiveController.text.length
          : _recentControllerValue.text.length;
    }

    effectiveFocusNode.canRequestFocus = isEnabled && widget.useNativeKeyboard;
    effectiveFocusNode.addListener(_onFocusChange);
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
    final selectionChanged = _recentControllerValue.selection !=
        _effectiveController.value.selection;

    // Track if we should check for completion even without text changes
    bool shouldCheckCompletion = false;

    // Update cursor position when text changes
    if (textChanged) {
      final newText = _effectiveController.value.text;
      final oldText = _recentControllerValue.text;
      final selection = _effectiveController.value.selection;

      if (widget.enableEditingInMiddle) {
        _handleEditingInMiddleTextChange(newText, oldText, selection);
      } else {
        // Original behavior for non-editing-in-middle mode
        if (selection.isValid) {
          _cursorPosition = selection.baseOffset.clamp(0, newText.length);
        } else {
          if (newText.length > oldText.length &&
              _cursorPosition == oldText.length) {
            _cursorPosition = newText.length;
          } else if (_cursorPosition > newText.length) {
            _cursorPosition = newText.length;
          }
        }
      }
    } else if (selectionChanged && widget.enableEditingInMiddle) {
      // Handle selection changes that might indicate typing the same character
      final selection = _effectiveController.value.selection;
      final oldSelection = _recentControllerValue.selection;

      // Check if we had a selection and now we don't (indicating typing occurred)
      if (oldSelection.isValid &&
          !oldSelection.isCollapsed &&
          selection.isValid &&
          selection.isCollapsed &&
          _isReplacing) {
        // User was in replacement mode and typed something, move cursor forward
        _advanceCursorAfterReplacement();
        // Even if text didn't change, we should check for completion
        shouldCheckCompletion = true;
      }
    }

    _recentControllerValue = _effectiveController.value;
    if (textChanged || shouldCheckCompletion) {
      _onChanged(pin);
    }
  }

  /// Helper method to advance cursor after replacement
  void _advanceCursorAfterReplacement() {
    if (widget.enableEditingInMiddle) {
      if (_cursorPosition < widget.length - 1) {
        _cursorPosition++;
        _isReplacing = _pinValues[_cursorPosition] != null;

        // Update controller text first
        _updateControllerText();

        // If the new position has a character, automatically select it for replacement
        if (_pinValues[_cursorPosition] != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _selectCharacterForReplacement(_cursorPosition);
            }
          });
        }
      } else {
        // Move cursor beyond the last position to indicate completion
        _cursorPosition = widget.length;
        _isReplacing = false;
        _updateControllerText();

        // Explicitly check for completion when cursor moves beyond last position
        if (_completed) {
          _maybeValidateForm();
          _maybeCloseKeyboard();
          _maybeCallOnCompletedImmediate();
        }
      }
    } else {
      _cursorPosition = (_cursorPosition + 1).clamp(0, widget.length - 1);
      _isReplacing = false;
    }
  }

  void _handleEditingInMiddleTextChange(
    String newText,
    String oldText,
    TextSelection selection,
  ) {
    // selection.baseOffset is available if needed; text diffing below doesn't use it directly.

    if (newText.length > oldText.length) {
      // One or more characters added (typing or paste). Compute the inserted substring
      final int oldLen = oldText.length;
      final int newLen = newText.length;
      // Find first differing index
      int firstDiff = 0;
      while (firstDiff < oldLen && oldText[firstDiff] == newText[firstDiff]) {
        firstDiff++;
      }
      final int insertedLen = newLen - oldLen;
      final String inserted =
          newText.substring(firstDiff, firstDiff + insertedLen);

      // Map text index to visual start position
      // If the insertion matches the current cursor position, use it (handles gaps)
      int visualStart;
      if (_getCursorPositionInText(_cursorPosition) == firstDiff) {
        visualStart = _cursorPosition;
      } else {
        visualStart = _getVisualPositionFromText(firstDiff);
      }

      if (visualStart < 0) visualStart = 0;
      if (visualStart > _pinValues.length) visualStart = _pinValues.length;

      // Fill sequentially from visualStart with inserted chars
      for (int i = 0; i < inserted.length; i++) {
        final int pos = visualStart + i;
        if (pos >= 0 && pos < _pinValues.length) {
          _pinValues[pos] = inserted[i];
        }
      }

      // Update replacement/cursor state
      _isReplacing = false;
      final int afterPos = visualStart + inserted.length;
      if (afterPos <= 0) {
        _cursorPosition = 0;
      } else if (afterPos >= widget.length) {
        // Move cursor beyond last position to indicate completion
        _cursorPosition = widget.length;
      } else {
        _cursorPosition = afterPos.clamp(0, widget.length - 1);
        _isReplacing = _pinValues[_cursorPosition] != null;
      }

      // Update controller text and selection
      _updateControllerText();

      // If the new position has a character and we are replacing, select it
      if (widget.enableEditingInMiddle &&
          _cursorPosition >= 0 &&
          _cursorPosition < _pinValues.length &&
          _pinValues[_cursorPosition] != null &&
          _isReplacing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _selectCharacterForReplacement(_cursorPosition);
        });
      }

      // Explicitly check for completion when cursor moves beyond last position
      if (_completed) {
        _maybeValidateForm();
        _maybeCloseKeyboard();
        _maybeCallOnCompletedImmediate();
      }
    } else if (newText.length < oldText.length) {
      // Character deleted
      // Calculate the range of characters deleted from oldText
      int start = 0;
      while (start < newText.length && oldText[start] == newText[start]) {
        start++;
      }

      int diffLength = oldText.length - newText.length;
      int end = start + diffLength;

      // Map text indices to _pinValues indices and clear deleted characters
      int currentTextIndex = 0;
      int? firstDeletedVisualIndex;

      for (int i = 0; i < _pinValues.length; i++) {
        if (_pinValues[i] != null) {
          if (currentTextIndex >= start && currentTextIndex < end) {
            _pinValues[i] = null;
            firstDeletedVisualIndex ??= i;
          }
          currentTextIndex++;
        }
      }

      if (firstDeletedVisualIndex != null) {
        _cursorPosition = firstDeletedVisualIndex;
      } else {
        _cursorPosition = _getVisualPositionFromText(start);
      }

      // Reset completion flag when characters are deleted
      if (widget.callOnCompletedOnlyOnUnfocus) {
        _hasCalledOnCompleted = false;
      }
      _updateControllerText();
      _isReplacing = false;
    } else if (newText.length == oldText.length) {
      // Direct character replacement (same length but different content)
      // This happens when a character is selected and replaced

      // Check for character differences and handle replacement
      for (int i = 0; i < newText.length; i++) {
        if (i >= oldText.length) break;
        if (newText[i] != oldText[i]) {
          final visualIndex = _getVisualPositionFromText(i);
          if (visualIndex >= 0 && visualIndex < _pinValues.length) {
            _pinValues[visualIndex] = newText[i];

            // Move cursor forward after replacement
            if (widget.enableEditingInMiddle) {
              if (visualIndex < widget.length - 1) {
                _cursorPosition = visualIndex + 1;
                _isReplacing = _pinValues[_cursorPosition] != null;

                // Update controller text first
                _updateControllerText();

                // If the new position has a character, automatically select it for replacement
                if (_pinValues[_cursorPosition] != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _selectCharacterForReplacement(_cursorPosition);
                    }
                  });
                  return; // Early return to avoid double _updateControllerText call
                }
              } else {
                // Move cursor beyond the last position to indicate completion
                _cursorPosition = widget.length;
                _isReplacing = false;

                // Explicitly check for completion when cursor moves beyond last position
                if (_completed) {
                  _maybeValidateForm();
                  _maybeCloseKeyboard();
                  _maybeCallOnCompletedImmediate();
                }
              }
            } else {
              _cursorPosition = (visualIndex + 1).clamp(0, widget.length - 1);
              _isReplacing = false;
            }
          }
          break;
        }
      }

      _updateControllerText();
    }
  }

  void _updateControllerText() {
    final updatedText = _pinValues.where((char) => char != null).join('');
    if (_effectiveController.text != updatedText) {
      _effectiveController.removeListener(_handleTextEditingControllerChanges);
      _effectiveController.text = updatedText;

      // Set cursor position in the text controller to match our visual cursor position
      final textOffset = _getCursorPositionInText(_cursorPosition);

      // Only set selection here if we're not in continuous editing mode or not in replacement mode
      // In continuous editing mode with replacement, selection will be handled by _selectCharacterForReplacement
      if (!(widget.enableEditingInMiddle &&
          _isReplacing &&
          _cursorPosition < _pinValues.length &&
          _pinValues[_cursorPosition] != null)) {
        _effectiveController.selection = TextSelection.collapsed(
          offset: textOffset.clamp(0, updatedText.length),
        );
      }

      _effectiveController.addListener(_handleTextEditingControllerChanges);
    }
  }

  /// Handle focus changes to call onCompleted when focus is lost and all cells are filled
  void _onFocusChange() {
    if (!effectiveFocusNode.hasFocus) {
      // Field lost focus - check if we should call onCompleted
      if (widget.callOnCompletedOnlyOnUnfocus) {
        _maybeCallOnCompletedOnUnfocus();
      }
    } else {
      // Field gained focus - reset the completion flag if pin is not complete
      if (!_completed && widget.callOnCompletedOnlyOnUnfocus) {
        _hasCalledOnCompleted = false;
      }
    }
  }

  /// Check if onCompleted should be called when the field loses focus
  void _maybeCallOnCompletedOnUnfocus() {
    if (_completed && !_hasCalledOnCompleted) {
      _hasCalledOnCompleted = true;
      widget.onCompleted?.call(pin);
    }
  }

  /// Check if onCompleted should be called immediately for specific completion scenarios
  void _maybeCallOnCompletedImmediate() {
    // Call onCompleted immediately if:
    // 1. Pin is completed
    // 2. We haven't called it yet
    // 3. Keyboard won't be closed (so focus won't be lost automatically)
    // 4. The new behavior is enabled
    if (_completed &&
        !_hasCalledOnCompleted &&
        !widget.closeKeyboardWhenCompleted &&
        widget.callOnCompletedOnlyOnUnfocus) {
      _hasCalledOnCompleted = true;
      widget.onCompleted?.call(pin);
    }
  }

  void _onChanged(String pin) {
    widget.onChanged?.call(pin);
    if (_completed) {
      if (widget.callOnCompletedOnlyOnUnfocus) {
        // Reset the completion flag when pin becomes complete during editing
        // onCompleted will be called on unfocus instead
        _hasCalledOnCompleted = false;
      } else {
        // Use the original behavior - call onCompleted immediately
        widget.onCompleted?.call(pin);
      }
      _maybeValidateForm();
      _maybeCloseKeyboard();
    }
  }

  void _maybeValidateForm() {
    if (widget.pinputAutovalidateMode == PinputAutovalidateMode.onSubmit) {
      _validator();
    }
  }

  void _maybeCloseKeyboard() {
    if (widget.closeKeyboardWhenCompleted) {
      if (widget.enableEditingInMiddle) {
        // For enableEditingInMiddle mode, close keyboard when:
        // 1. The pin is completed (all cells filled), AND
        // 2. The cursor has moved beyond the last position (indicating user is done editing)
        final allPositionsFilled = _pinValues.every((char) => char != null);
        final cursorBeyondLastPosition = _cursorPosition >= widget.length;

        if (allPositionsFilled && cursorBeyondLastPosition) {
          effectiveFocusNode.unfocus();
        }
      } else {
        // For normal mode, unfocus when completed
        effectiveFocusNode.unfocus();
      }
    }
    // When closeKeyboardWhenCompleted is false, do nothing - keyboard stays open
  }

  /// Helper method to select a character at a specific position for replacement
  void _selectCharacterForReplacement(int position) {
    if (position >= 0 &&
        position < _pinValues.length &&
        _pinValues[position] != null) {
      // Use addPostFrameCallback to ensure the selection happens after all other updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final textIndex = _getTextIndexForVisualPosition(position);
          final currentText = _effectiveController.text;
          if (textIndex < currentText.length) {
            _effectiveController.selection = TextSelection(
              baseOffset: textIndex,
              extentOffset: textIndex + 1,
            );
          }
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    effectiveFocusNode.canRequestFocus = _canRequestFocus;
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
      // Reset completion flag when controller changes
      if (widget.callOnCompletedOnlyOnUnfocus) {
        _hasCalledOnCompleted = false;
      }
      // Update cursor position when controller changes
      if (widget.enableEditingInMiddle) {
        _syncPinValuesFromText();
      } else {
        _cursorPosition = _effectiveController.text.length;
      }
    }

    // Handle length changes
    if (widget.length != oldWidget.length) {
      _pinValues = List.filled(widget.length, null);
      // Reset completion flag when length changes
      if (widget.callOnCompletedOnlyOnUnfocus) {
        _hasCalledOnCompleted = false;
      }
      if (widget.enableEditingInMiddle) {
        _syncPinValuesFromText();
      }
    }

    // Handle enableEditingInMiddle changes
    if (widget.enableEditingInMiddle != oldWidget.enableEditingInMiddle) {
      if (widget.enableEditingInMiddle) {
        _pinValues = List.filled(widget.length, null);
        _syncPinValuesFromText();
      }
    }

    effectiveFocusNode.canRequestFocus = _canRequestFocus;
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
    effectiveFocusNode.removeListener(_onFocusChange);
    _focusNode?.dispose();
    _controller?.dispose();
    _smsRetriever?.dispose();
    // https://github.com/Tkko/Flutter_Pinput/issues/89
    _ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    super.dispose();
  }

  void _requestKeyboard() {
    if (effectiveFocusNode.canRequestFocus) {
      _editableText?.requestKeyboard();
    }
  }

  void _onPinTapped(int index) {
    // Only allow tapping on individual positions if the feature is enabled
    if (!widget.enableEditingInMiddle) {
      // Fallback to the default behavior - move cursor to the end
      setState(() {
        _cursorPosition = pin.length;
      });
      _requestKeyboard();
      return;
    }

    // Allow tapping on any position within the pin length
    if (index >= 0 && index < widget.length) {
      setState(() {
        _cursorPosition = index;
        // Set replacement mode if the position has a character
        _isReplacing = _pinValues[index] != null;
      });
      _requestKeyboard();

      // If the position has a character, we need to handle selection carefully
      if (_pinValues[index] != null) {
        // For positions with existing values, we want to replace the character
        // when the user starts typing. We need to ensure the text controller
        // reflects the current state properly.
        _updateControllerText();

        // After updating, select the character at the current position for replacement
        final textIndex = _getTextIndexForVisualPosition(index);
        if (textIndex < _effectiveController.text.length) {
          // Select the character so it gets replaced when user types
          _effectiveController.selection = TextSelection(
            baseOffset: textIndex,
            extentOffset: textIndex + 1,
          );
        }
      } else {
        // For empty positions, just update cursor position
        _updateControllerText();
      }
    }
  }

  /// Get the text index for a specific visual position
  int _getTextIndexForVisualPosition(int visualIndex) {
    if (!widget.enableEditingInMiddle) {
      return _effectiveController.text.length;
    }

    int textIndex = 0;
    for (int i = 0; i < visualIndex && i < _pinValues.length; i++) {
      if (_pinValues[i] != null) {
        textIndex++;
      }
    }
    return textIndex;
  }

  void _handleSelectionChanged(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    // For enableEditingInMiddle, we manage cursor position manually
    if (widget.enableEditingInMiddle) {
      // Only update visual cursor position for user-initiated selection changes
      if (cause != null && cause == SelectionChangedCause.tap) {
        if (selection.isValid && selection.isCollapsed) {
          int visualPosition = _getVisualPositionFromText(selection.baseOffset);
          if (visualPosition != _cursorPosition) {
            setState(() {
              _cursorPosition = visualPosition.clamp(0, widget.length - 1);
              _isReplacing =
                  false; // Reset replacement mode on manual cursor movement
            });
          }
        }
      }
    } else {
      // Use the default behavior for non-editing-in-middle mode
      final targetOffset = pin.length;
      if (selection.baseOffset != targetOffset) {
        _effectiveController.selection =
            TextSelection.collapsed(offset: targetOffset);
      }
    }

    // Handle platform-specific selection behaviors
    switch (Theme.of(context).platform) {
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
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
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
        break;
      case TargetPlatform.macOS:
        forcePressEnabled = false;
        textSelectionControls ??= cupertinoDesktopTextSelectionHandleControls;
        handleDidGainAccessibilityFocus = () {
          if (!effectiveFocusNode.hasFocus &&
              effectiveFocusNode.canRequestFocus) {
            effectiveFocusNode.requestFocus();
          }
        };
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        forcePressEnabled = false;
        textSelectionControls ??= materialTextSelectionHandleControls;
        break;
      case TargetPlatform.linux:
        forcePressEnabled = false;
        textSelectionControls ??= desktopTextSelectionHandleControls;
        break;
      case TargetPlatform.windows:
        forcePressEnabled = false;
        textSelectionControls ??= desktopTextSelectionHandleControls;
        handleDidGainAccessibilityFocus = () {
          if (!effectiveFocusNode.hasFocus &&
              effectiveFocusNode.canRequestFocus) {
            effectiveFocusNode.requestFocus();
          }
        };
        break;
    }

    return _PinputFormField(
      enabled: isEnabled,
      validator: _validator,
      initialValue: _effectiveController.text,
      builder: (FormFieldState<String> field) {
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
                  child: child,
                ),
                child: _gestureDetectorBuilder.buildGestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      _buildEditable(textSelectionControls, field),
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
          enableInteractiveSelection: false,
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
          focusNode: effectiveFocusNode,
          // Align hidden editable text to the start so the system paste menu
          // anchors near the first character position (which maps to the
          // first visual pin cell) instead of the center of the widget.
          textAlign: TextAlign.start,
          autofocus: widget.autofocus,
          inputFormatters: formatters,
          restorationId: 'pinput',
          clipBehavior: Clip.hardEdge,
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
          selectionControls:
              widget.toolbarEnabled ? textSelectionControls : null,
          keyboardAppearance:
              widget.keyboardAppearance ?? Theme.of(context).brightness,
        ),
      ),
    );
  }

  // TODO: Use WidgetStateProperty instead.
  MouseCursor get _effectiveMouseCursor {
    // ignore: deprecated_member_use
    return MaterialStateProperty.resolveAs<MouseCursor>(
      // ignore: deprecated_member_use
      widget.mouseCursor ?? MaterialStateMouseCursor.textable,
      // ignore: deprecated_member_use
      <MaterialState>{
        // ignore: deprecated_member_use
        if (!isEnabled) MaterialState.disabled,
        // ignore: deprecated_member_use
        if (_isHovering) MaterialState.hovered,
        // ignore: deprecated_member_use
        if (effectiveFocusNode.hasFocus) MaterialState.focused,
        // ignore: deprecated_member_use
        if (hasError) MaterialState.error,
      },
    );
  }

  void _semanticsOnTap() {
    if (!_effectiveController.selection.isValid) {
      final targetOffset = widget.enableEditingInMiddle
          ? _cursorPosition
          : _effectiveController.text.length;
      _effectiveController.selection =
          TextSelection.collapsed(offset: targetOffset);
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

    final focusedIndex = widget.enableEditingInMiddle
        ? _cursorPosition.clamp(0, widget.length - 1)
        : pin.length.clamp(0, widget.length - 1);

    if (hasFocus && index == focusedIndex) {
      return PinItemStateType.focused;
    }

    // Check if this position has a character
    final hasCharacter = widget.enableEditingInMiddle
        ? _getCharAtPosition(index) != null
        : index < pin.length;

    if (hasCharacter) {
      return PinItemStateType.submitted;
    }

    return PinItemStateType.following;
  }

  Widget _buildFields() {
    Widget onlyFields() {
      return _SeparatedRaw(
        separatorBuilder: widget.separatorBuilder,
        mainAxisAlignment: widget.mainAxisAlignment,
        children: Iterable<int>.generate(widget.length).map<Widget>((index) {
          if (widget._builder != null) {
            // Get the correct character for this visual position
            final char = widget.enableEditingInMiddle
                ? _getCharAtPosition(index) ?? ''
                : (pin.length > index ? pin[index] : '');

            return widget._builder!.itemBuilder.call(
              context,
              PinItemState(
                value: char,
                index: index,
                type: _getState(index),
              ),
            );
          }

          return _PinItem(state: this, index: index);
        }).toList(),
      );
    }

    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge(
          <Listenable>[effectiveFocusNode, _effectiveController],
        ),
        builder: (BuildContext context, Widget? child) {
          final shouldHideErrorContent =
              widget.validator == null && widget.errorText == null;

          if (shouldHideErrorContent) return onlyFields();

          return AnimatedSize(
            duration: widget.animationDuration,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: widget.crossAxisAlignment,
              children: [
                onlyFields(),
                _buildError(),
              ],
            ),
          );
        },
      ),
    );
  }

  @protected
  bool get hasFocus {
    final isLastPin = widget.enableEditingInMiddle
        ? _cursorPosition == widget.length
        : pin.length == widget.length;
    return effectiveFocusNode.hasFocus ||
        (!widget.useNativeKeyboard && !isLastPin);
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
            style: widget.errorTextStyle ??
                theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.error),
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
    final List<String>? autofillHints =
        widget.autofillHints?.toList(growable: false);
    final AutofillConfiguration autofillConfiguration = autofillHints != null
        ? AutofillConfiguration(
            uniqueIdentifier: autofillId,
            autofillHints: autofillHints,
            currentEditingValue: _effectiveController.value,
          )
        : AutofillConfiguration.disabled;

    return _editableText!.textInputConfiguration
        .copyWith(autofillConfiguration: autofillConfiguration);
  }
}
