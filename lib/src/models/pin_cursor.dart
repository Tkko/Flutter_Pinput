part of '../pinput.dart';

/// Cursor shown by the default pin renderer.
@immutable
class PinCursor {
  const PinCursor._(this._type, this._child);

  /// Displays an animated cursor. Pass [child] to customize its appearance.
  const PinCursor.blinking({Widget? child})
    : this._(_PinCursorType.blinking, child);

  /// Displays a cursor without animation. Pass [child] to customize its
  /// appearance.
  const PinCursor.static({Widget? child})
    : this._(_PinCursorType.static, child);

  /// Does not display a cursor.
  const PinCursor.hidden() : this._(_PinCursorType.hidden, null);

  final _PinCursorType _type;
  final Widget? _child;

  @override
  bool operator ==(Object other) =>
      other is PinCursor &&
      runtimeType == other.runtimeType &&
      _type == other._type &&
      _child == other._child;

  @override
  int get hashCode => Object.hash(runtimeType, _type, _child);
}
