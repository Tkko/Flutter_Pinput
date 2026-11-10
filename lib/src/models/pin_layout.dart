part of '../pinput.dart';

/// How the pins and the error content are laid out.
@immutable
class PinLayout {
  /// Creates a layout configuration.
  const PinLayout({
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.separatorBuilder,
    this.textDirection,
  });

  /// Defines how the pins are placed inside the [Row].
  final MainAxisAlignment mainAxisAlignment;

  /// Defines how the pins and the error content are placed inside the [Column].
  final CrossAxisAlignment crossAxisAlignment;

  /// Builds the separator between pins. If null, `SizedBox(width: 8)` is used.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Order of the pins. If null, uses the ambient [Directionality]. Set
  /// [TextDirection.ltr] to keep a numeric code left to right in an RTL app.
  final TextDirection? textDirection;

  @override
  String toString() =>
      'PinLayout(mainAxisAlignment: $mainAxisAlignment, crossAxisAlignment: $crossAxisAlignment, separatorBuilder: $separatorBuilder, textDirection: $textDirection)';

  @override
  bool operator ==(Object other) =>
      other is PinLayout &&
      runtimeType == other.runtimeType &&
      mainAxisAlignment == other.mainAxisAlignment &&
      crossAxisAlignment == other.crossAxisAlignment &&
      separatorBuilder == other.separatorBuilder &&
      textDirection == other.textDirection;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    mainAxisAlignment,
    crossAxisAlignment,
    separatorBuilder,
    textDirection,
  );
}
