import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';

void main() {
  testWidgets('Can enter value', (WidgetTester tester) async {
    String? fieldValue;
    int called = 0;
    final controller = TextEditingController();
    final focusNode = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Pinput(
            controller: controller,
            onChanged: (value) {
              fieldValue = value;
              called++;
            },
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();

    expect(fieldValue, isNull);
    expect(called, 0);

    await tester.enterText(find.byType(Pinput), '1111');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(fieldValue, equals('1111'));
    expect(called, 1);
  });
}
