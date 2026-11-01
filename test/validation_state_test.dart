import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';

import 'helpers/helpers.dart';

void main() {
  test('Validation states have value equality', () {
    expect(const PinputValidationState.idle(), PinputValidationIdle());
    expect(const PinputValidationState.validating(), PinputValidationPending());
    expect(const PinputValidationState.valid(), PinputValidationValid());
    const invalid = PinputValidationState.invalid('Incorrect code');
    final same = PinputValidationInvalid('Incorrect code');
    expect(invalid, same);
    expect(invalid.hashCode, same.hashCode);
    expect(
      const PinputValidationState.invalid(),
      PinputValidationInvalid(null),
    );
    expect(
      const PinputValidationState.invalid(),
      isNot(const PinputValidationState.invalid('')),
    );
    expect(invalid, isNot(const PinputValidationState.invalid('Expired code')));
    expect(
      const PinputValidationState.idle(),
      isNot(const PinputValidationState.valid()),
    );
  });

  testWidgets('Defaults to idle and does not register with Form', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpApp(
      Form(
        key: formKey,
        child: const Pinput(
          validationState: PinputValidationState.invalid('Incorrect code'),
        ),
      ),
    );
    expect(const Pinput().validationState, const PinputValidationState.idle());
    expect(find.byType(FormField<String>), findsNothing);
    expect(formKey.currentState!.validate(), isTrue);
    expect(find.text('Incorrect code'), findsOneWidget);
  });

  testWidgets(
    'Invalid feedback survives focus, edits and keyboard submission',
    (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      String? changed;
      String? completed;
      String? submitted;
      await tester.pumpApp(
        Pinput(
          controller: controller,
          focusNode: focusNode,
          showCursor: false,
          closeKeyboardWhenCompleted: false,
          validationState: const PinputValidationState.invalid(
            'Incorrect code',
          ),
          defaultPinTheme: const PinTheme(
            decoration: BoxDecoration(color: Color(0xFF000000)),
          ),
          errorPinTheme: const PinTheme(
            decoration: BoxDecoration(color: Color(0xFFFF0000)),
          ),
          onChanged: (value) => changed = value,
          onCompleted: (value) => completed = value,
          onSubmitted: (value) => submitted = value,
        ),
      );
      focusNode.requestFocus();
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '1234');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(changed, '1234');
      expect(completed, '1234');
      expect(submitted, '1234');
      expect(find.text('Incorrect code'), findsOneWidget);
      for (final container in tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      )) {
        expect(
          (container.decoration! as BoxDecoration).color,
          const Color(0xFFFF0000),
        );
      }
    },
  );

  testWidgets('App transitions preserve text, focus and editing availability', (
    tester,
  ) async {
    final state = ValueNotifier<PinputValidationState>(
      const PinputValidationState.invalid('Incorrect code'),
    );
    final controller = TextEditingController(text: '12');
    final focusNode = FocusNode();
    addTearDown(state.dispose);
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    await tester.pumpApp(
      ValueListenableBuilder<PinputValidationState>(
        valueListenable: state,
        builder: (_, value, _) => Pinput(
          controller: controller,
          focusNode: focusNode,
          showCursor: false,
          validationState: value,
        ),
      ),
    );
    focusNode.requestFocus();
    await tester.pump();
    for (final value in [
      const PinputValidationState.idle(),
      const PinputValidationState.validating(),
      const PinputValidationState.valid(),
    ]) {
      state.value = value;
      await tester.pumpAndSettle();
      expect(find.text('Incorrect code'), findsNothing);
      expect(controller.text, '12');
      expect(focusNode.hasFocus, isTrue);
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.readOnly, isFalse);
      expect(focusNode.canRequestFocus, isTrue);
    }
    await tester.enterText(find.byType(EditableText), '123');
    await tester.pump();
    expect(controller.text, '123');
    expect(state.value, const PinputValidationState.valid());
  });

  testWidgets(
    'Custom builder receives invalid state and custom error content',
    (tester) async {
      final controller = TextEditingController(text: '1234');
      addTearDown(controller.dispose);
      final items = <PinItemStateType>[];
      await tester.pumpApp(
        Pinput.builder(
          controller: controller,
          validationState: const PinputValidationState.invalid('Expired'),
          errorTextStyle: const TextStyle(fontSize: 40),
          builder: (_, item) {
            items.add(item.type);
            return Text(item.value);
          },
          errorBuilder: (message, pin) =>
              Text('$message: $pin', style: const TextStyle(fontSize: 14)),
        ),
      );
      expect(items, everyElement(PinItemStateType.error));
      final error = tester.widget<Text>(find.text('Expired: 1234'));
      expect(error.style!.fontSize, 14);
      expect(find.text('Expired'), findsNothing);
    },
  );

  testWidgets('Default error text honors style in both constructors', (
    tester,
  ) async {
    const style = TextStyle(fontSize: 18, color: Color(0xFF123456));
    for (final widget in [
      const Pinput(
        validationState: PinputValidationState.invalid('Incorrect code'),
        errorTextStyle: style,
      ),
      Pinput.builder(
        builder: (_, item) => Text(item.value),
        validationState: const PinputValidationState.invalid('Incorrect code'),
        errorTextStyle: style,
      ),
    ]) {
      await tester.pumpApp(widget);
      expect(tester.widget<Text>(find.text('Incorrect code')).style, style);
    }
  });

  testWidgets('Message-free errors style pins without default error content', (
    tester,
  ) async {
    for (final widget in [
      const Pinput(
        showCursor: false,
        validationState: PinputValidationState.invalid(),
        errorPinTheme: PinTheme(
          decoration: BoxDecoration(color: Color(0xFFFF0000)),
        ),
      ),
      Pinput.builder(
        validationState: const PinputValidationState.invalid(null),
        builder: (_, item) {
          expect(item.type, PinItemStateType.error);
          return Text(item.value);
        },
      ),
    ]) {
      await tester.pumpApp(widget);
      expect(find.byType(Text), findsNWidgets(4));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding ==
                  const EdgeInsetsDirectional.only(start: 4, top: 8),
        ),
        findsNothing,
      );
      for (final container in tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      )) {
        expect(
          (container.decoration! as BoxDecoration).color,
          const Color(0xFFFF0000),
        );
      }
    }
  });

  testWidgets(
    'Error builder receives null only for message-free invalid state',
    (tester) async {
      for (final useItemBuilder in [false, true]) {
        final state = ValueNotifier<PinputValidationState>(
          const PinputValidationState.invalid(),
        );
        final messages = <String?>[];
        addTearDown(state.dispose);
        Widget errorBuilder(String? message, String pin) {
          messages.add(message);
          return Text(message ?? 'Localized error');
        }

        await tester.pumpApp(
          ValueListenableBuilder<PinputValidationState>(
            valueListenable: state,
            builder: (_, value, _) => useItemBuilder
                ? Pinput.builder(
                    validationState: value,
                    builder: (_, item) => Text(item.value),
                    errorBuilder: errorBuilder,
                  )
                : Pinput(
                    showCursor: false,
                    validationState: value,
                    errorBuilder: errorBuilder,
                  ),
          ),
        );
        expect(messages, isNotEmpty);
        expect(messages, everyElement(isNull));
        expect(find.text('Localized error'), findsOneWidget);
        state.value = const PinputValidationState.invalid('Expired');
        await tester.pumpAndSettle();
        expect(messages.last, 'Expired');
        expect(find.text('Expired'), findsOneWidget);
        for (final value in [
          const PinputValidationState.idle(),
          const PinputValidationState.validating(),
          const PinputValidationState.valid(),
        ]) {
          messages.clear();
          state.value = value;
          await tester.pumpAndSettle();
          expect(messages, isEmpty);
          expect(find.text('Expired'), findsNothing);
          expect(find.text('Localized error'), findsNothing);
        }
      }
    },
  );

  testWidgets('Form adapter synchronizes controller updates and reset', (
    tester,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final fieldKey = GlobalKey<FormFieldState<String>>();
    addTearDown(controller.dispose);
    controller.addListener(() {
      final field = fieldKey.currentState;
      if (field != null && field.value != controller.text) {
        field.didChange(controller.text);
      }
    });
    await tester.pumpApp(
      Form(
        key: formKey,
        child: FormField<String>(
          key: fieldKey,
          initialValue: '',
          onReset: controller.clear,
          validator: (value) => value == '1234' ? null : 'Incorrect code',
          builder: (field) => Pinput(
            controller: controller,
            showCursor: false,
            validationState: field.errorText == null
                ? const PinputValidationState.idle()
                : PinputValidationState.invalid(field.errorText!),
          ),
        ),
      ),
    );
    controller.text = '1111';
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Incorrect code'), findsOneWidget);
    controller.text = '1234';
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Incorrect code'), findsNothing);
    formKey.currentState!.reset();
    await tester.pumpAndSettle();
    expect(controller.text, isEmpty);
    expect(fieldKey.currentState!.value, isEmpty);
    expect(
      tester.widget<Pinput>(find.byType(Pinput)).validationState,
      const PinputValidationState.idle(),
    );
  });
}
