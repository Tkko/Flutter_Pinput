part of '../pinput.dart';

/// Cursor shown by the default pin renderer.
@immutable
class PinCursor {
  const PinCursor._(
    this._type,
    this._child, [
    this._blinkDuration = _PinputConstants._cursorBlinkDuration,
  ]);

  /// Displays an animated cursor. Pass [child] to customize its appearance and
  /// [blinkDuration] to set how long one fade takes. The cursor does not blink
  /// when the platform asks to reduce motion.
  const PinCursor.blinking({
    Widget? child,
    Duration blinkDuration = _PinputConstants._cursorBlinkDuration,
  }) : this._(_PinCursorType.blinking, child, blinkDuration);

  /// Displays a cursor without animation. Pass [child] to customize its
  /// appearance.
  const PinCursor.static({Widget? child})
    : this._(_PinCursorType.static, child);

  /// Does not display a cursor.
  const PinCursor.hidden() : this._(_PinCursorType.hidden, null);

  final _PinCursorType _type;
  final Widget? _child;
  final Duration _blinkDuration;

  /// Creates a copy of this cursor with the given fields replaced.
  PinCursor copyWith({Widget? child, Duration? blinkDuration}) {
    return PinCursor._(_type, child ?? _child, blinkDuration ?? _blinkDuration);
  }

  @override
  String toString() {
    return switch (_type) {
      _PinCursorType.blinking =>
        'PinCursor.blinking(child: $_child, blinkDuration: $_blinkDuration)',
      _PinCursorType.static => 'PinCursor.static(child: $_child)',
      _PinCursorType.hidden => 'PinCursor.hidden()',
    };
  }

  @override
  bool operator ==(Object other) =>
      other is PinCursor &&
      runtimeType == other.runtimeType &&
      _type == other._type &&
      _child == other._child &&
      _blinkDuration == other._blinkDuration;

  @override
  int get hashCode => Object.hash(runtimeType, _type, _child, _blinkDuration);
}
