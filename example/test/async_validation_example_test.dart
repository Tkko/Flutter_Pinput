import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';
import 'package:pinput_example/demo/async_validation_example.dart';

Future<void> pumpExample(WidgetTester tester) => tester.pumpWidget(
  const MaterialApp(home: Scaffold(body: AsyncValidationExample())),
);

void main() {
  testWidgets('Completion verifies a code and shows progress then success', (
    tester,
  ) async {
    await pumpExample(tester);
    await tester.enterText(find.byType(EditableText), '2222');
    await tester.pump();
    expect(find.text('Verifying code...'), findsOneWidget);
    expect(
      tester.widget<Pinput>(find.byType(Pinput)).validationState,
      const PinputValidationState.validating(),
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Code verified'), findsOneWidget);
    expect(
      tester.widget<Pinput>(find.byType(Pinput)).validationState,
      const PinputValidationState.valid(),
    );
  });

  testWidgets('Incomplete input fails locally and wrong code fails async', (
    tester,
  ) async {
    await pumpExample(tester);
    await tester.tap(find.text('Verify code'));
    await tester.pump();
    expect(find.text('Enter all 4 digits'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), '1111');
    await tester.pump();
    expect(find.text('Enter all 4 digits'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Incorrect code. Try 2222.'), findsOneWidget);
  });

  testWidgets('Edits invalidate a pending check and allow a newer check', (
    tester,
  ) async {
    await pumpExample(tester);
    await tester.enterText(find.byType(EditableText), '1111');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(EditableText), '222');
    await tester.pump();
    expect(
      tester.widget<Pinput>(find.byType(Pinput)).validationState,
      const PinputValidationState.idle(),
    );
    await tester.enterText(find.byType(EditableText), '2222');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Incorrect code. Try 2222.'), findsNothing);
    expect(find.text('Verifying code...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Code verified'), findsOneWidget);
  });

  testWidgets('Late verification does not update a disposed example', (
    tester,
  ) async {
    await pumpExample(tester);
    await tester.enterText(find.byType(EditableText), '2222');
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
