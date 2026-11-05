part of '../pinput.dart';

/// How the pins and the error content are laid out.
@immutable
class PinLayout {
  /// Creates a layout configuration.
  const PinLayout({
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.separatorBuilder,
  });

  /// Defines how the pins are placed inside the [Row].
  final MainAxisAlignment mainAxisAlignment;

  /// Defines how the pins and the error content are placed inside the [Column].
  final CrossAxisAlignment crossAxisAlignment;

  /// Builds the separator between pins. If null, `SizedBox(width: 8)` is used.
  final JustIndexedWidgetBuilder? separatorBuilder;

  @override
  bool operator ==(Object other) =>
      other is PinLayout &&
      runtimeType == other.runtimeType &&
      mainAxisAlignment == other.mainAxisAlignment &&
      crossAxisAlignment == other.crossAxisAlignment &&
      separatorBuilder == other.separatorBuilder;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    mainAxisAlignment,
    crossAxisAlignment,
    separatorBuilder,
  );
}
