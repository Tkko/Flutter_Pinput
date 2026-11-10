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
    this._transitionBuilder,
  ]);

  /// Disables content, decoration and error-layout animations.
  /// Cursor blinking is configured separately with [PinCursor].
  const PinAnimation.none()
    : this._(_PinAnimationType.none, Duration.zero, Curves.linear);

  /// Scales content into place.
  const PinAnimation.scale({
    Duration duration = _PinputConstants._animationDuration,
    Curve curve = Curves.easeIn,
  }) : this._(_PinAnimationType.scale, duration, curve);

  /// Fades content into place.
  const PinAnimation.fade({
    Duration duration = _PinputConstants._animationDuration,
    Curve curve = Curves.easeIn,
  }) : this._(_PinAnimationType.fade, duration, curve);

  /// Slides content from [beginOffset], expressed relative to the content size.
  const PinAnimation.slide({
    Offset beginOffset = const Offset(0.8, 0),
    Duration duration = _PinputConstants._animationDuration,
    Curve curve = Curves.easeIn,
  }) : this._(_PinAnimationType.slide, duration, curve, beginOffset);

  /// Rotates content into place.
  const PinAnimation.rotation({
    Duration duration = _PinputConstants._animationDuration,
    Curve curve = Curves.easeIn,
  }) : this._(_PinAnimationType.rotation, duration, curve);

  /// Builds the content transition with [transitionBuilder], see
  /// [AnimatedSwitcher.transitionBuilder].
  const PinAnimation.custom({
    required AnimatedSwitcherTransitionBuilder transitionBuilder,
    Duration duration = _PinputConstants._animationDuration,
    Curve curve = Curves.easeIn,
  }) : this._(
         _PinAnimationType.custom,
         duration,
         curve,
         null,
         transitionBuilder,
       );

  /// Duration of the content transition, decoration changes and error layout.
  final Duration duration;

  /// Curve of the content transition, decoration changes and error layout.
  final Curve curve;

  final _PinAnimationType _type;
  final Offset? _beginOffset;
  final AnimatedSwitcherTransitionBuilder? _transitionBuilder;

  /// Creates a copy of this animation with the given fields replaced.
  /// [PinAnimation.none] remains disabled regardless of the supplied timing.
  PinAnimation copyWith({Duration? duration, Curve? curve}) {
    if (_type == _PinAnimationType.none) return this;
    return PinAnimation._(
      _type,
      duration ?? this.duration,
      curve ?? this.curve,
      _beginOffset,
      _transitionBuilder,
    );
  }

  @override
  String toString() {
    final typeName = switch (_type) {
      _PinAnimationType.none => 'none',
      _PinAnimationType.scale => 'scale',
      _PinAnimationType.fade => 'fade',
      _PinAnimationType.slide => 'slide(beginOffset: $_beginOffset)',
      _PinAnimationType.rotation => 'rotation',
      _PinAnimationType.custom => 'custom',
    };
    return 'PinAnimation.$typeName(duration: $duration, curve: $curve)';
  }

  @override
  bool operator ==(Object other) =>
      other is PinAnimation &&
      runtimeType == other.runtimeType &&
      _type == other._type &&
      _beginOffset == other._beginOffset &&
      _transitionBuilder == other._transitionBuilder &&
      duration == other.duration &&
      curve == other.curve;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    _type,
    _beginOffset,
    _transitionBuilder,
    duration,
    curve,
  );
}
