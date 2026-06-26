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
    // pinput's _handleSelectionChanged forcibly rewrites the selection on every
    // tap, so the framework's toggleToolbar logic (which compares previousSelection
    // == currentSelection) always falls into hideToolbar instead of toggling.
    // We bypass super and manually implement the iOS toggle behavior.
    if (delegate.selectionEnabled &&
        _state.widget.showToolbarOnTap &&
        defaultTargetPlatform == TargetPlatform.iOS &&
        _state._effectiveFocusNode.hasFocus) {
      if (_state._isToolbarVisible) {
        _state._isToolbarVisible = false;
        editableText.hideToolbar(false);
      } else {
        // toggleToolbar creates _selectionOverlay if null, which showToolbar() alone cannot.
        editableText.toggleToolbar(false);
      }
    } else {
      super.onSingleTapUp(details);
      editableText.hideToolbar();
    }
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
