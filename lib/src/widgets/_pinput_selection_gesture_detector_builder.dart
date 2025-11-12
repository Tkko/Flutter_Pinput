// ignore_for_file: discarded_futures

part of '../pinput.dart';

class _PinputSelectionGestureDetectorBuilder extends TextSelectionGestureDetectorBuilder {
  _PinputSelectionGestureDetectorBuilder({required _PinputState state}) : _state = state, super(delegate: state);

  final _PinputState _state;

  @override
  void onForcePressStart(ForcePressDetails details) {
    super.onForcePressStart(details);
    if (delegate.selectionEnabled && shouldShowSelectionToolbar) {
      editableText.showToolbar();
    }
  }

  @override
  void onSingleTapUp(TapDragUpDetails details) {
    super.onSingleTapUp(details);
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
  void onSingleLongTapStart(LongPressStartDetails details) {
    super.onSingleLongTapStart(details);
    if (delegate.selectionEnabled) {
      switch (Theme.of(_state.context).platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          Feedback.forLongPress(_state.context);
      }
    }
  }
}
