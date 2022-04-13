import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';

void main() {
  testWidgets('Pins are displayed', (WidgetTester tester) async {
    final length = 4;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Pinput(length: length),
        ),
      ),
    );

    expect(find.byType(Flexible), findsNWidgets(length));
    expect(find.byType(AnimatedContainer), findsNWidgets(length));
    expect(find.byType(Text), findsNWidgets(length));
  });

  testWidgets('Should properly handle states', (WidgetTester tester) async {
    final length = 4;
    final focusNode = FocusNode();
    final defaultTheme = PinTheme(decoration: BoxDecoration(color: Colors.red));
    final focusedTheme = defaultTheme.copyDecorationWith(color: Colors.greenAccent.withOpacity(.9));
    final submittedTheme = defaultTheme.copyDecorationWith(color: Colors.greenAccent.withOpacity(.8));
    final followingTheme = defaultTheme.copyDecorationWith(color: Colors.greenAccent.withOpacity(.7));
    final disabledTheme = defaultTheme.copyDecorationWith(color: Colors.greenAccent.withOpacity(.6));
    final errorTheme = defaultTheme.copyDecorationWith(color: Colors.greenAccent.withOpacity(.5));

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Pinput(
            length: length,
            focusNode: focusNode,
            defaultPinTheme: defaultTheme,
            focusedPinTheme: focusedTheme,
            submittedPinTheme: submittedTheme,
            followingPinTheme: followingTheme,
            disabledPinTheme: disabledTheme,
            errorPinTheme: errorTheme,
          ),
        ),
      ),
    );

    void _testState(int count, PinTheme theme) {
      expect(
        find.byWidgetPredicate((w) => w is AnimatedContainer && w.decoration == theme.decoration),
        findsNWidgets(count),
      );
    }

    // Unfocused
    _testState(length, followingTheme);
    _testState(0, focusedTheme);
    _testState(0, submittedTheme);
    _testState(0, errorTheme);
    _testState(0, disabledTheme);

    //Focused
    focusNode.requestFocus();
    await tester.pump();

    _testState(length - 1, followingTheme);
    _testState(1, focusedTheme);
    _testState(0, submittedTheme);
    _testState(0, errorTheme);
    _testState(0, disabledTheme);

    // Focused submitted
    await tester.enterText(find.byType(EditableText), '1');
    await tester.pump();

    _testState(length - 2, followingTheme);
    _testState(1, focusedTheme);
    _testState(1, submittedTheme);
    _testState(0, errorTheme);
    _testState(0, disabledTheme);

    // UnFocused submitted
    focusNode.unfocus();
    await tester.pump();

    _testState(length - 1, followingTheme);
    _testState(0, focusedTheme);
    _testState(1, submittedTheme);
    _testState(0, errorTheme);
    _testState(0, disabledTheme);
  });

  testWidgets('Should properly handle focused state', (WidgetTester tester) async {
    final focusNode = FocusNode();
    final defaultTheme = PinTheme(decoration: BoxDecoration());
    final focusedTheme = defaultTheme.copyDecorationWith(color: Colors.red);
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Pinput(
            focusNode: focusNode,
            autofocus: true,
            defaultPinTheme: defaultTheme,
            focusedPinTheme: focusedTheme,
          ),
        ),
      ),
    );

    expect(focusNode.hasFocus, isTrue);

    await tester.pump();
    // Cursor
    expect(find.text('|'), findsOneWidget);

    expect(
      find.byWidgetPredicate((w) => w is AnimatedContainer && w.decoration == focusedTheme.decoration),
      findsOneWidget,
    );
  });

  testWidgets('Should display custom cursor', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Pinput(
            autofocus: true,
            cursor: const FlutterLogo(),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(FlutterLogo), findsOneWidget);
  });

  testWidgets('onChanged callback is called', (WidgetTester tester) async {
    String? fieldValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Pinput(
            onChanged: (value) => fieldValue = value,
          ),
        ),
      ),
    );

    expect(fieldValue, isNull);

    Future<void> checkText(String testValue) async {
      await tester.enterText(find.byType(EditableText), testValue);
      expect(fieldValue, equals(testValue));
    }

    await checkText('123');
    await checkText('');
  });

  testWidgets('onCompleted callback is called', (WidgetTester tester) async {
    String? fieldValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Pinput(
            length: 4,
            onCompleted: (value) => fieldValue = value,
          ),
        ),
      ),
    );

    expect(fieldValue, isNull);

    await tester.enterText(find.byType(EditableText), '1234');
    expect(fieldValue, equals('1234'));

    fieldValue = null;
    await tester.enterText(find.byType(EditableText), '123');
    expect(fieldValue, isNull);
  });

  testWidgets('onCompleted callback is called', (WidgetTester tester) async {
    String? fieldValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Pinput(
            length: 4,
            onCompleted: (value) => fieldValue = value,
          ),
        ),
      ),
    );

    expect(fieldValue, isNull);

    await tester.enterText(find.byType(EditableText), '1234');
    expect(fieldValue, equals('1234'));

    fieldValue = null;
    await tester.enterText(find.byType(EditableText), '123');
    expect(fieldValue, isNull);
  });

  testWidgets('onTap is called upon tap', (WidgetTester tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Pinput(
            onTap: () => ++tapCount,
          ),
        ),
      ),
    );

    expect(tapCount, 0);
    await tester.tap(find.byType(EditableText));
    // Wait a bit so they're all single taps and not double taps.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byType(EditableText));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byType(EditableText));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tapCount, 3);
  });

  testWidgets('onTap is not called, field is disabled', (WidgetTester tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Pinput(
            enabled: false,
            onTap: () => ++tapCount,
          ),
        ),
      ),
    );

    expect(tapCount, 0);
    await tester.tap(find.byType(EditableText), warnIfMissed: false);
    await tester.tap(find.byType(EditableText), warnIfMissed: false);
    expect(tapCount, 0);
  });

  testWidgets('onLongPress is called', (WidgetTester tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Pinput(
            onLongPress: () => ++tapCount,
          ),
        ),
      ),
    );

    expect(tapCount, 0);
    await tester.longPress(find.byType(EditableText));
    // Wait a bit so they're all single taps and not double taps.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.longPress(find.byType(EditableText));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.longPress(find.byType(EditableText));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tapCount, 3);
  });

  testWidgets('onSubmitted callback is called', (WidgetTester tester) async {
    String? fieldValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Pinput(
            onSubmitted: (value) => fieldValue = value,
          ),
        ),
      ),
    );

    expect(fieldValue, isNull);

    await tester.enterText(find.byType(EditableText), '123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(fieldValue, equals('123'));
  });
}
