part of '../pinput.dart';

/// Content transition for individual pins, plus the [duration] and [curve]
/// shared by the content transition, decoration changes and error layout.
@immutable
class PinAnimation {
  const PinAnimation._(
    this._type,
    this.duration,
    this.curve, [
    this._beginOffset,
  ]);

  /// No content transition. [duration] and [curve] still animate decoration
  /// and error layout changes.
  const PinAnimation.none({
    Duration duration = PinputConstants._animationDuration,
    Curve curve = Curves.easeIn,
  }) : this._(_PinAnimationType.none, duration, curve);

  /// Scales content into place.
  const PinAnimation.scale({
    Duration duration = PinputConstants._animationDuration,
    Curve curve = Curves.easeIn,
  }) : this._(_PinAnimationType.scale, duration, curve);

  /// Fades content into place.
  const PinAnimation.fade({
    Duration duration = PinputConstants._animationDuration,
    Curve curve = Curves.easeIn,
  }) : this._(_PinAnimationType.fade, duration, curve);

  /// Slides content from [beginOffset], expressed relative to the content size.
  const PinAnimation.slide({
    Offset beginOffset = const Offset(0.8, 0),
    Duration duration = PinputConstants._animationDuration,
    Curve curve = Curves.easeIn,
  }) : this._(_PinAnimationType.slide, duration, curve, beginOffset);

  /// Rotates content into place.
  const PinAnimation.rotation({
    Duration duration = PinputConstants._animationDuration,
    Curve curve = Curves.easeIn,
  }) : this._(_PinAnimationType.rotation, duration, curve);

  /// Duration of the content transition, decoration changes and error layout.
  final Duration duration;

  /// Curve of the content transition, decoration changes and error layout.
  final Curve curve;

  final _PinAnimationType _type;
  final Offset? _beginOffset;

  @override
  bool operator ==(Object other) =>
      other is PinAnimation &&
      runtimeType == other.runtimeType &&
      _type == other._type &&
      _beginOffset == other._beginOffset &&
      duration == other.duration &&
      curve == other.curve;

  @override
  int get hashCode =>
      Object.hash(runtimeType, _type, _beginOffset, duration, curve);
}
