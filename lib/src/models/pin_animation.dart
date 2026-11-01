part of '../pinput.dart';

/// Content transition for individual pins.
@immutable
class PinAnimation {
  const PinAnimation._(this._type, [this._beginOffset]);

  /// No content transition.
  const PinAnimation.none()
    : _type = _PinAnimationType.none,
      _beginOffset = null;

  /// Scales content into place.
  const PinAnimation.scale()
    : _type = _PinAnimationType.scale,
      _beginOffset = null;

  /// Fades content into place.
  const PinAnimation.fade()
    : _type = _PinAnimationType.fade,
      _beginOffset = null;

  /// Slides content from [beginOffset], expressed relative to the content size.
  const PinAnimation.slide({Offset beginOffset = const Offset(0.8, 0)})
    : this._(_PinAnimationType.slide, beginOffset);

  /// Rotates content into place.
  const PinAnimation.rotation()
    : _type = _PinAnimationType.rotation,
      _beginOffset = null;

  final _PinAnimationType _type;
  final Offset? _beginOffset;

  @override
  bool operator ==(Object other) =>
      other is PinAnimation &&
      runtimeType == other.runtimeType &&
      _type == other._type &&
      _beginOffset == other._beginOffset;

  @override
  int get hashCode => Object.hash(runtimeType, _type, _beginOffset);
}
