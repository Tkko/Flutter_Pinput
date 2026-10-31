part of '../pinput.dart';

class _PinputSelectionGestureDetectorBuilder
    extends TextSelectionGestureDetectorBuilder {
  _PinputSelectionGestureDetectorBuilder({required _PinputState state})
    : _state = state,
      super(delegate: state);

  final _PinputState _state;

  @override
  void onForcePressStart(details) {
    super.onForcePressStart(details);
    if (delegate.selectionEnabled && shouldShowSelectionToolbar) {
      editableText.showToolbar();
    }
  }

  @override
  void onSingleTapUp(details) {
    // Taps outside pin boxes (separators, padding) must not move the cursor
    // to a position derived from the hidden text layout.
    final controller = _state._effectiveController;
    final before = controller.selection;
    super.onSingleTapUp(details);
    if (_state.widget.pinEditMode != PinEditMode.none) {
      controller.selection = before.isValid
          ? before
          : TextSelection.collapsed(offset: controller.text.length);
    }
    editableText.hideToolbar();
    _state._requestKeyboard();
    _state.widget.onTap?.call();
  }

  @override
  void onSingleLongTapEnd(LongPressEndDetails details) {
    super.onSingleLongTapEnd(details);
    _state.widget.onLongPress?.call();
  }

  @override
  void onSingleLongTapStart(details) {
    super.onSingleLongTapStart(details);
    if (delegate.selectionEnabled) {
      Feedback.forLongPress(_state.context);
    }
  }
}
