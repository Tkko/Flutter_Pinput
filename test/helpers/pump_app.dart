import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(home: Material(child: widget)),
    );
  }
}
