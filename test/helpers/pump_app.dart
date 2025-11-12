import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) => pumpWidget(MaterialApp(home: Material(child: widget)));
}
