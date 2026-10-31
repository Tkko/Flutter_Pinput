import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pinput/pinput.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pinput Integration Tests - Pure Behavioral Flows & Edge Cases', () {
    Widget buildTestHarness(Widget child) {
      return MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: Center(child: SingleChildScrollView(child: child)),
        ),
      );
    }

    Future<void> pumpFrames(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    final defaultTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
    );

    final errorTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration!.copyWith(
        border: Border.all(color: Colors.red),
      ),
    );

    // =========================================================================
    // 1. PIN Sequential Input & Deletion Flows
    // =========================================================================
    group('1. Sequential Input & Deletion Flows', () {
      testWidgets(
        'Sequential digit entry triggers onChanged and onCompleted at length',
        (tester) async {
          final controller = TextEditingController();
          final changedValues = <String>[];
          String? completedValue;

          await tester.pumpWidget(
            buildTestHarness(
              Pinput(
                key: const ValueKey('pinput_seq'),
                length: 4,
                controller: controller,
                defaultPinTheme: defaultTheme,
                isCursorAnimationEnabled: false,
                onChanged: (val) => changedValues.add(val),
                onCompleted: (val) => completedValue = val,
              ),
            ),
          );
          await pumpFrames(tester);

          final editableText = find.byType(EditableText);

          await tester.enterText(editableText, '1');
          await pumpFrames(tester);
          expect(controller.text, '1');
          expect(
            find.descendant(
              of: find.byType(AnimatedContainer),
              matching: find.text('1'),
            ),
            findsOneWidget,
          );
          expect(completedValue, isNull);

          await tester.enterText(editableText, '12');
          await pumpFrames(tester);
          expect(controller.text, '12');
          expect(
            find.descendant(
              of: find.byType(AnimatedContainer),
              matching: find.text('2'),
            ),
            findsOneWidget,
          );
          expect(completedValue, isNull);

          await tester.enterText(editableText, '123');
          await pumpFrames(tester);
          expect(controller.text, '123');
          expect(
            find.descendant(
              of: find.byType(AnimatedContainer),
              matching: find.text('3'),
            ),
            findsOneWidget,
          );
          expect(completedValue, isNull);

          await tester.enterText(editableText, '1234');
          await pumpFrames(tester);
          expect(controller.text, '1234');
          expect(
            find.descendant(
              of: find.byType(AnimatedContainer),
              matching: find.text('4'),
            ),
            findsOneWidget,
          );
          expect(completedValue, '1234');

          expect(changedValues, containsAllInOrder(['1', '12', '123', '1234']));
        },
      );

      testWidgets(
        'Backspace sequentially removes digits and handles empty field safely',
        (tester) async {
          final controller = TextEditingController(text: '1234');
          final changedValues = <String>[];

          await tester.pumpWidget(
            buildTestHarness(
              Pinput(
                key: const ValueKey('pinput_backspace'),
                length: 4,
                controller: controller,
                defaultPinTheme: defaultTheme,
                isCursorAnimationEnabled: false,
                onChanged: (val) => changedValues.add(val),
              ),
            ),
          );
          await pumpFrames(tester);

          final editableText = find.byType(EditableText);

          // Backspace to 3 digits
          await tester.enterText(editableText, '123');
          await pumpFrames(tester);
          expect(controller.text, '123');
          expect(find.text('4'), findsNothing);

          // Backspace to 2 digits
          await tester.enterText(editableText, '12');
          await pumpFrames(tester);
          expect(controller.text, '12');

          // Backspace to 0 digits
          await tester.enterText(editableText, '');
          await pumpFrames(tester);
          expect(controller.text, '');

          // Backspace on empty pin (no crash, stays empty)
          await tester.enterText(editableText, '');
          await pumpFrames(tester);
          expect(controller.text, '');
        },
      );
    });

    // =========================================================================
    // 2. Mid-Pin Tap & Editing Modes
    // =========================================================================
    group('2. Mid-Pin Tap & Editing Modes', () {
      testWidgets(
        'PinEditMode.overwrite: tap previous pin, edit in place and advance',
        (tester) async {
          final controller = TextEditingController(text: '1234');
          int completedCount = 0;
          String? lastCompleted;

          await tester.pumpWidget(
            buildTestHarness(
              Pinput(
                key: const ValueKey('pinput_overwrite'),
                length: 4,
                controller: controller,
                pinEditMode: PinEditMode.overwrite,
                defaultPinTheme: defaultTheme,
                isCursorAnimationEnabled: false,
                onCompleted: (val) {
                  completedCount++;
                  lastCompleted = val;
                },
              ),
            ),
          );
          await pumpFrames(tester);

          // Tap the 2nd pin (index 1, contains '2')
          final pinItems = find.byType(AnimatedContainer);
          expect(pinItems, findsNWidgets(4));
          await tester.tap(pinItems.at(1));
          await pumpFrames(tester);

          // In overwrite mode, typing '9' at index 1 replaces '2' and advances cursor to 2
          controller.value = const TextEditingValue(
            text: '1934',
            selection: TextSelection.collapsed(offset: 2),
          );
          await pumpFrames(tester);

          expect(controller.text, '1934');
          expect(completedCount, 0);

          // Now tap last pin (index 3) and replace with '8'
          await tester.tap(pinItems.at(3));
          await pumpFrames(tester);

          controller.value = const TextEditingValue(
            text: '1938',
            selection: TextSelection.collapsed(offset: 4),
          );
          await pumpFrames(tester);

          expect(controller.text, '1938');
          expect(completedCount, 1);
          expect(lastCompleted, '1938');
        },
      );

      testWidgets(
        'PinEditMode.clearFollowing: editing middle pin truncates following pins',
        (tester) async {
          final controller = TextEditingController(text: '1234');
          int completedCount = 0;

          await tester.pumpWidget(
            buildTestHarness(
              Pinput(
                key: const ValueKey('pinput_clear_following'),
                length: 4,
                controller: controller,
                pinEditMode: PinEditMode.clearFollowing,
                defaultPinTheme: defaultTheme,
                isCursorAnimationEnabled: false,
                onCompleted: (_) => completedCount++,
              ),
            ),
          );
          await pumpFrames(tester);

          final pinItems = find.byType(AnimatedContainer);
          await tester.tap(pinItems.at(1));
          await pumpFrames(tester);

          await tester.enterText(find.byType(EditableText), '17');
          await pumpFrames(tester);

          expect(controller.text, '17');
          expect(completedCount, 0);
          expect(find.text('1'), findsOneWidget);
          expect(find.text('7'), findsOneWidget);
          expect(find.text('3'), findsNothing);
          expect(find.text('4'), findsNothing);
        },
      );
    });

    // =========================================================================
    // 3. Clipboard & Paste Flows
    // =========================================================================
    group('3. Clipboard & Paste Flows', () {
      testWidgets(
        'Exact length paste fills all cells and triggers onCompleted',
        (tester) async {
          final controller = TextEditingController();
          String? completed;

          await tester.pumpWidget(
            buildTestHarness(
              Pinput(
                key: const ValueKey('pinput_paste_exact'),
                length: 4,
                controller: controller,
                defaultPinTheme: defaultTheme,
                isCursorAnimationEnabled: false,
                onCompleted: (val) => completed = val,
              ),
            ),
          );
          await pumpFrames(tester);

          await tester.enterText(find.byType(EditableText), '5678');
          await pumpFrames(tester);

          expect(controller.text, '5678');
          expect(completed, '5678');
          expect(find.text('5'), findsOneWidget);
          expect(find.text('6'), findsOneWidget);
          expect(find.text('7'), findsOneWidget);
          expect(find.text('8'), findsOneWidget);
        },
      );

      testWidgets(
        'Over-length paste (Specification 1-A) truncates to N chars and calls onCompleted',
        (tester) async {
          final controller = TextEditingController();
          String? completed;

          await tester.pumpWidget(
            buildTestHarness(
              Pinput(
                key: const ValueKey('pinput_paste_over'),
                length: 4,
                controller: controller,
                defaultPinTheme: defaultTheme,
                isCursorAnimationEnabled: false,
                onCompleted: (val) => completed = val,
              ),
            ),
          );
          await pumpFrames(tester);

          // Emulate paste of 6 digits into 4-digit pin
          await tester.enterText(find.byType(EditableText), '123456');
          await pumpFrames(tester);

          // Must be clamped to first 4 characters and fire onCompleted
          expect(controller.text, '1234');
          expect(completed, '1234');
          expect(find.text('1'), findsOneWidget);
          expect(find.text('4'), findsOneWidget);
          expect(find.text('5'), findsNothing);
          expect(find.text('6'), findsNothing);
        },
      );

      testWidgets(
        'Under-length paste fills partial cells without firing onCompleted',
        (tester) async {
          final controller = TextEditingController();
          String? completed;
          String? changed;

          await tester.pumpWidget(
            buildTestHarness(
              Pinput(
                key: const ValueKey('pinput_paste_under'),
                length: 4,
                controller: controller,
                defaultPinTheme: defaultTheme,
                isCursorAnimationEnabled: false,
                onChanged: (val) => changed = val,
                onCompleted: (val) => completed = val,
              ),
            ),
          );
          await pumpFrames(tester);

          await tester.enterText(find.byType(EditableText), '89');
          await pumpFrames(tester);

          expect(controller.text, '89');
          expect(changed, '89');
          expect(completed, isNull);
          expect(find.text('8'), findsOneWidget);
          expect(find.text('9'), findsOneWidget);
        },
      );

      testWidgets(
        'Pasting full code over an existing partial pin replaces entirely',
        (tester) async {
          final controller = TextEditingController(text: '12');
          String? completed;

          await tester.pumpWidget(
            buildTestHarness(
              Pinput(
                key: const ValueKey('pinput_paste_replace'),
                length: 4,
                controller: controller,
                defaultPinTheme: defaultTheme,
                isCursorAnimationEnabled: false,
                onCompleted: (val) => completed = val,
              ),
            ),
          );
          await pumpFrames(tester);

          await tester.enterText(find.byType(EditableText), '9876');
          await pumpFrames(tester);

          expect(controller.text, '9876');
          expect(completed, '9876');
        },
      );
    });

    // =========================================================================
    // 4. Form Validation & Error State Reset (Specification 2-A)
    // =========================================================================
    group('4. Form Validation & Error State Flows', () {
      testWidgets('Failed validation displays error text and errorPinTheme', (
        tester,
      ) async {
        final controller = TextEditingController();
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          buildTestHarness(
            Form(
              key: formKey,
              child: Column(
                children: [
                  Pinput(
                    key: const ValueKey('pinput_form'),
                    length: 4,
                    controller: controller,
                    defaultPinTheme: defaultTheme,
                    errorPinTheme: errorTheme,
                    isCursorAnimationEnabled: false,
                    validator: (val) => val == '7777' ? null : 'Wrong PIN code',
                  ),
                  ElevatedButton(
                    key: const ValueKey('btn_submit'),
                    onPressed: () => formKey.currentState!.validate(),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        );
        await pumpFrames(tester);

        // Enter wrong pin
        await tester.enterText(find.byType(EditableText), '1111');
        await pumpFrames(tester);

        // Submit form
        await tester.tap(find.byKey(const ValueKey('btn_submit')));
        await pumpFrames(tester);

        // Expect error text displayed
        expect(find.text('Wrong PIN code'), findsOneWidget);

        // Verify container border turned red (errorTheme)
        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect((decoration.border as Border).top.color, Colors.red);
      });

      testWidgets(
        'Typing/editing immediately clears error state (Specification 2-A)',
        (tester) async {
          final controller = TextEditingController();
          final formKey = GlobalKey<FormState>();

          await tester.pumpWidget(
            buildTestHarness(
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Pinput(
                      key: const ValueKey('pinput_clear_error'),
                      length: 4,
                      controller: controller,
                      defaultPinTheme: defaultTheme,
                      errorPinTheme: errorTheme,
                      isCursorAnimationEnabled: false,
                      validator: (val) =>
                          val == '7777' ? null : 'Wrong PIN code',
                    ),
                    ElevatedButton(
                      key: const ValueKey('btn_submit_2'),
                      onPressed: () => formKey.currentState!.validate(),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          );
          await pumpFrames(tester);

          // Enter wrong pin and trigger error
          await tester.enterText(find.byType(EditableText), '1111');
          await pumpFrames(tester);
          await tester.tap(find.byKey(const ValueKey('btn_submit_2')));
          await pumpFrames(tester);
          expect(find.text('Wrong PIN code'), findsOneWidget);

          // User taps pinput to refocus, then edits by backspacing to '111'
          await tester.tap(find.byKey(const ValueKey('pinput_clear_error')));
          await pumpFrames(tester);
          await tester.enterText(find.byType(EditableText), '111');
          await pumpFrames(tester);

          // Per Specification 2-A: error text MUST be cleared immediately on edit!
          expect(find.text('Wrong PIN code'), findsNothing);

          // Visual border must revert from red error state
          final container = tester.widget<AnimatedContainer>(
            find.byType(AnimatedContainer).first,
          );
          final decoration = container.decoration as BoxDecoration;
          expect((decoration.border as Border).top.color, isNot(Colors.red));
        },
      );
    });

    // =========================================================================
    // 5. Disabled & ReadOnly States
    // =========================================================================
    group('5. Disabled & ReadOnly States', () {
      testWidgets('Disabled state (enabled: false) ignores taps and input', (
        tester,
      ) async {
        final controller = TextEditingController(text: '12');

        final disabledTheme = defaultTheme.copyWith(
          decoration: defaultTheme.decoration!.copyWith(color: Colors.black12),
        );

        await tester.pumpWidget(
          buildTestHarness(
            Pinput(
              key: const ValueKey('pinput_disabled'),
              length: 4,
              enabled: false,
              controller: controller,
              defaultPinTheme: defaultTheme,
              disabledPinTheme: disabledTheme,
              isCursorAnimationEnabled: false,
            ),
          ),
        );
        await pumpFrames(tester);

        // Verify disabled theme applied
        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, Colors.black12);

        // Tap on disabled pin
        await tester.tap(find.byKey(const ValueKey('pinput_disabled')));
        await pumpFrames(tester);

        try {
          await tester.enterText(find.byType(EditableText), '1234');
        } catch (_) {}
        await pumpFrames(tester);
        expect(controller.text, '12');
      });

      testWidgets(
        'ReadOnly state allows focus but prevents text modification',
        (tester) async {
          final controller = TextEditingController(text: '12');
          final focusNode = FocusNode();

          await tester.pumpWidget(
            buildTestHarness(
              Pinput(
                key: const ValueKey('pinput_readonly'),
                length: 4,
                readOnly: true,
                focusNode: focusNode,
                controller: controller,
                defaultPinTheme: defaultTheme,
                isCursorAnimationEnabled: false,
              ),
            ),
          );
          await pumpFrames(tester);

          await tester.tap(find.byKey(const ValueKey('pinput_readonly')));
          await pumpFrames(tester);
          expect(focusNode.hasFocus, isTrue);

          try {
            await tester.enterText(find.byType(EditableText), '9999');
          } catch (_) {}
          await pumpFrames(tester);
          expect(controller.text, '12');
        },
      );
    });

    // =========================================================================
    // 6. Obscuring Characters & Custom Obscuring Widget
    // =========================================================================
    group('6. Obscuring Text', () {
      testWidgets(
        'Obscuring character masks characters while preserving controller value',
        (tester) async {
          final controller = TextEditingController();

          await tester.pumpWidget(
            buildTestHarness(
              Pinput(
                key: const ValueKey('pinput_obscure'),
                length: 4,
                obscureText: true,
                obscuringCharacter: '*',
                controller: controller,
                defaultPinTheme: defaultTheme,
                isCursorAnimationEnabled: false,
              ),
            ),
          );
          await pumpFrames(tester);

          await tester.enterText(find.byType(EditableText), '1234');
          await pumpFrames(tester);

          expect(controller.text, '1234');
          expect(find.text('1'), findsNothing);
          expect(find.text('*'), findsNWidgets(4));
        },
      );
    });

    // =========================================================================
    // 7. Custom Item Builder (Pinput.builder)
    // =========================================================================
    group('7. Custom Item Builder', () {
      testWidgets(
        'Pinput.builder renders custom widget per cell and supports editing',
        (tester) async {
          final controller = TextEditingController();
          String? completed;

          await tester.pumpWidget(
            buildTestHarness(
              Pinput.builder(
                key: const ValueKey('pinput_builder'),
                length: 4,
                controller: controller,
                onCompleted: (val) => completed = val,
                builder: (context, item) {
                  return Container(
                    key: ValueKey('custom_cell_${item.index}'),
                    width: 40,
                    height: 40,
                    color: item.type == PinItemStateType.focused
                        ? Colors.blue
                        : Colors.grey[300],
                    child: Center(
                      child: Text(
                        item.value.isEmpty ? '-' : item.value,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
          await pumpFrames(tester);

          // Check custom cells exist
          expect(find.byKey(const ValueKey('custom_cell_0')), findsOneWidget);
          expect(find.byKey(const ValueKey('custom_cell_3')), findsOneWidget);

          await tester.enterText(find.byType(EditableText), '4321');
          await pumpFrames(tester);

          expect(controller.text, '4321');
          expect(completed, '4321');
          expect(find.text('4'), findsOneWidget);
          expect(find.text('1'), findsOneWidget);
        },
      );
    });

    // =========================================================================
    // 8. SMS Retriever Mock Flow
    // =========================================================================
    group('8. SMS Retriever Integration', () {
      testWidgets(
        'SmsRetriever resolution automatically populates pin and calls onCompleted',
        (tester) async {
          final controller = TextEditingController();
          String? completed;

          final mockRetriever = _MockSmsRetriever('4567');

          await tester.pumpWidget(
            buildTestHarness(
              Pinput(
                key: const ValueKey('pinput_sms'),
                length: 4,
                controller: controller,
                smsRetriever: mockRetriever,
                defaultPinTheme: defaultTheme,
                isCursorAnimationEnabled: false,
                onCompleted: (val) => completed = val,
              ),
            ),
          );
          await pumpFrames(tester);

          expect(controller.text, '4567');
          expect(completed, '4567');
          expect(find.text('4'), findsOneWidget);
          expect(find.text('7'), findsOneWidget);
        },
      );
    });
  });
}

class _MockSmsRetriever implements SmsRetriever {
  final String code;
  _MockSmsRetriever(this.code);

  @override
  Future<String?> getSmsCode() async => code;

  @override
  bool get listenForMultipleSms => false;

  @override
  Future<void> dispose() async {}
}
