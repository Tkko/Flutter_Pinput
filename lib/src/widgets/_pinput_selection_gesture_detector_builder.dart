part of '../pinput.dart';

class _PinputSelectionGestureDetectorBuilder extends TextSelectionGestureDetectorBuilder {
  _PinputSelectionGestureDetectorBuilder({required _PinputState state})
      : _state = state,
        super(delegate: state);

  final _PinputState _state;

  @override
  void onForcePressStart(ForcePressDetails details) {
    super.onForcePressStart(details);
    if (shouldShowSelectionToolbar) {
      editableText.showToolbar();
    }
  }

  @override
  void onDoubleTapDown(TapDownDetails details) {
    if (_state.widget.toolbarEnabled) {
      if (shouldShowSelectionToolbar) editableText.showToolbar();
    }
  }

  @override
  void onSingleTapUp(TapUpDetails details) {
    editableText.hideToolbar();
    super.onSingleTapUp(details);
    _state._requestKeyboard();
    _state.widget.onTap?.call();
  }

  @override
  void onSingleLongTapStart(LongPressStartDetails details) {
    _state.widget.onLongPress?.call();
    if (shouldShowSelectionToolbar) editableText.showToolbar();
  }
}
