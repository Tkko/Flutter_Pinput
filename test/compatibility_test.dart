import 'package:cupertino_ui/cupertino_ui.dart' as cupertino_ui;
import 'package:flutter/cupertino.dart' as flutter_cupertino;
import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as material_ui;
import 'package:pinput/pinput.dart';

void main() {
  group('1. Headless / Pure WidgetsApp (Without Material or Cupertino)', () {
    testWidgets('Renders, receives input, and handles submission', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      String? submitted;

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
            return PageRouteBuilder<T>(
              settings: settings,
              pageBuilder: (context, _, _) => builder(context),
            );
          },
          home: Center(
            child: Pinput(
              controller: controller,
              length: 4,
              onSubmitted: (val) => submitted = val,
            ),
          ),
        ),
      );

      expect(find.byType(Pinput), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsNWidgets(4));

      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(controller.text, '123');
      expect(submitted, '123');
    });

    testWidgets(
      'Displays validator error text without crashing on Theme lookup',
      (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          WidgetsApp(
            color: const Color(0xFFFFFFFF),
            pageRouteBuilder:
                <T>(RouteSettings settings, WidgetBuilder builder) {
                  return PageRouteBuilder<T>(
                    settings: settings,
                    pageBuilder: (context, _, _) => builder(context),
                  );
                },
            home: Center(
              child: Form(
                key: formKey,
                child: Pinput(
                  validator: (val) =>
                      (val?.length ?? 0) < 4 ? 'PIN too short' : null,
                ),
              ),
            ),
          ),
        );

        // Validate form to trigger error
        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('PIN too short'), findsOneWidget);
        final errorText = tester.widget<Text>(find.text('PIN too short'));
        expect(errorText.style?.color, const Color(0xFFDC2626));
        expect(errorText.style?.fontSize, 12);
        expect(errorText.style?.decoration, TextDecoration.none);
      },
    );

    testWidgets(
      'Displays dark-mode-safe validator error text with adequate contrast',
      (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(platformBrightness: Brightness.dark),
            child: WidgetsApp(
              color: const Color(0xFF000000),
              pageRouteBuilder:
                  <T>(RouteSettings settings, WidgetBuilder builder) {
                    return PageRouteBuilder<T>(
                      settings: settings,
                      pageBuilder: (context, _, _) => builder(context),
                    );
                  },
              home: Center(
                child: Form(
                  key: formKey,
                  child: Pinput(
                    validator: (val) =>
                        (val?.length ?? 0) < 4 ? 'PIN too short' : null,
                  ),
                ),
              ),
            ),
          ),
        );

        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('PIN too short'), findsOneWidget);
        final errorText = tester.widget<Text>(find.text('PIN too short'));
        expect(errorText.style?.color, const Color(0xFFF87171));
        expect(errorText.style?.fontSize, 12);
        expect(errorText.style?.decoration, TextDecoration.none);
      },
    );

    testWidgets('Renders decoupled context menu toolbar in pure WidgetsApp', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
            return PageRouteBuilder<T>(
              settings: settings,
              pageBuilder: (context, _, _) => builder(context),
            );
          },
          home: Center(
            child: Pinput(
              controller: controller,
              length: 4,
              toolbarEnabled: true,
              enableInteractiveSelection: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pump();

      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 4,
      );
      await tester.pump();

      final editableTextState = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      editableTextState.toggleToolbar();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Copy'), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(FocusableActionDetector), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.button == true &&
              w.properties.label == 'Copy',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Respects WidgetsLocalizations labels for context menu', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          locale: const Locale('custom'),
          localizationsDelegates: const [_CustomWidgetsLocalizationsDelegate()],
          pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
            return PageRouteBuilder<T>(
              settings: settings,
              pageBuilder: (context, _, _) => builder(context),
            );
          },
          home: Center(
            child: Pinput(
              controller: controller,
              length: 4,
              toolbarEnabled: true,
              enableInteractiveSelection: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pump();

      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 4,
      );
      await tester.pump();

      final editableTextState = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      editableTextState.toggleToolbar();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Copier'), findsOneWidget);
    });
  });

  group('2. Standard flutter/material.dart Compatibility (Fixes #240)', () {
    testWidgets(
      'Renders inside MaterialApp + Scaffold + Material without assertion failure',
      (WidgetTester tester) async {
        final controller = TextEditingController();
        String? submitted;

        await tester.pumpWidget(
          flutter_material.MaterialApp(
            theme: flutter_material.ThemeData.light(),
            home: flutter_material.Scaffold(
              body: flutter_material.Material(
                type: flutter_material.MaterialType.transparency,
                color: flutter_material.Colors.transparent,
                child: Center(
                  child: Pinput(
                    controller: controller,
                    length: 4,
                    onSubmitted: (val) => submitted = val,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Pinput), findsOneWidget);
        expect(find.byType(AnimatedContainer), findsNWidgets(4));

        await tester.tap(find.byType(EditableText), warnIfMissed: false);
        await tester.pump();
        await tester.enterText(find.byType(EditableText), '432');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(controller.text, '432');
        expect(submitted, '432');
      },
    );

    testWidgets(
      'Displays validator error text inside flutter/material.dart tree',
      (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          flutter_material.MaterialApp(
            home: flutter_material.Scaffold(
              body: Form(
                key: formKey,
                child: Pinput(validator: (val) => 'Invalid code'),
              ),
            ),
          ),
        );

        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('Invalid code'), findsOneWidget);
      },
    );

    testWidgets(
      'Accepts custom Material contextMenuBuilder if passed explicitly',
      (WidgetTester tester) async {
        final controller = TextEditingController(text: '7890');

        await tester.pumpWidget(
          flutter_material.MaterialApp(
            home: flutter_material.Scaffold(
              body: Pinput(
                controller: controller,
                length: 4,
                toolbarEnabled: true,
                enableInteractiveSelection: true,
                contextMenuBuilder: (context, editableTextState) {
                  return flutter_material
                      .AdaptiveTextSelectionToolbar.editableText(
                    editableTextState: editableTextState,
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(EditableText), warnIfMissed: false);
        await tester.pump();
        controller.selection = const TextSelection(
          baseOffset: 0,
          extentOffset: 4,
        );
        await tester.pump();

        final editableTextState = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        editableTextState.toggleToolbar();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.byType(flutter_material.AdaptiveTextSelectionToolbar),
          findsOneWidget,
        );
      },
    );
  });

  group('3. Decoupled material_ui Compatibility (Fixes #237)', () {
    testWidgets(
      'Renders inside material_ui MaterialApp + Scaffold without assertion failure',
      (WidgetTester tester) async {
        final controller = TextEditingController();
        String? submitted;

        await tester.pumpWidget(
          material_ui.MaterialApp(
            theme: material_ui.ThemeData.light(),
            home: material_ui.Scaffold(
              body: material_ui.Material(
                type: material_ui.MaterialType.transparency,
                child: Center(
                  child: Pinput(
                    controller: controller,
                    length: 6,
                    onSubmitted: (val) => submitted = val,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Pinput), findsOneWidget);
        expect(find.byType(AnimatedContainer), findsNWidgets(6));

        await tester.tap(find.byType(EditableText), warnIfMissed: false);
        await tester.pump();
        await tester.enterText(find.byType(EditableText), '12345');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(controller.text, '12345');
        expect(submitted, '12345');
      },
    );

    testWidgets('Displays validator error text inside material_ui tree', (
      WidgetTester tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        material_ui.MaterialApp(
          home: material_ui.Scaffold(
            body: Form(
              key: formKey,
              child: Pinput(validator: (val) => 'Wrong OTP'),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Wrong OTP'), findsOneWidget);
    });

    testWidgets(
      'Accepts custom material_ui contextMenuBuilder if passed explicitly',
      (WidgetTester tester) async {
        final controller = TextEditingController(text: '1122');

        await tester.pumpWidget(
          material_ui.MaterialApp(
            home: material_ui.Scaffold(
              body: Pinput(
                controller: controller,
                length: 4,
                toolbarEnabled: true,
                enableInteractiveSelection: true,
                contextMenuBuilder: (context, editableTextState) {
                  return material_ui.AdaptiveTextSelectionToolbar.editableText(
                    editableTextState: editableTextState,
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(EditableText), warnIfMissed: false);
        await tester.pump();
        controller.selection = const TextSelection(
          baseOffset: 0,
          extentOffset: 4,
        );
        await tester.pump();

        final editableTextState = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        editableTextState.toggleToolbar();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.byType(material_ui.AdaptiveTextSelectionToolbar),
          findsOneWidget,
        );
      },
    );
  });

  group('4. Standard flutter/cupertino.dart Compatibility', () {
    testWidgets(
      'Renders inside CupertinoApp + CupertinoPageScaffold without failure',
      (WidgetTester tester) async {
        final controller = TextEditingController();
        String? submitted;

        await tester.pumpWidget(
          flutter_cupertino.CupertinoApp(
            home: flutter_cupertino.CupertinoPageScaffold(
              child: Center(
                child: Pinput(
                  controller: controller,
                  length: 4,
                  onSubmitted: (val) => submitted = val,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Pinput), findsOneWidget);
        expect(find.byType(AnimatedContainer), findsNWidgets(4));

        await tester.tap(find.byType(EditableText), warnIfMissed: false);
        await tester.pump();
        await tester.enterText(find.byType(EditableText), '987');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(controller.text, '987');
        expect(submitted, '987');
      },
    );

    testWidgets(
      'Displays validator error text inside flutter/cupertino.dart tree',
      (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          flutter_cupertino.CupertinoApp(
            home: flutter_cupertino.CupertinoPageScaffold(
              child: Form(
                key: formKey,
                child: Pinput(validator: (val) => 'Cupertino error'),
              ),
            ),
          ),
        );

        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('Cupertino error'), findsOneWidget);
      },
    );

    testWidgets(
      'Accepts custom Cupertino contextMenuBuilder if passed explicitly',
      (WidgetTester tester) async {
        final controller = TextEditingController(text: '5566');

        await tester.pumpWidget(
          flutter_cupertino.CupertinoApp(
            home: flutter_cupertino.CupertinoPageScaffold(
              child: Pinput(
                controller: controller,
                length: 4,
                toolbarEnabled: true,
                enableInteractiveSelection: true,
                contextMenuBuilder: (context, editableTextState) {
                  return flutter_cupertino
                      .CupertinoAdaptiveTextSelectionToolbar.editableText(
                    editableTextState: editableTextState,
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(EditableText), warnIfMissed: false);
        await tester.pump();
        controller.selection = const TextSelection(
          baseOffset: 0,
          extentOffset: 4,
        );
        await tester.pump();

        final editableTextState = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        editableTextState.toggleToolbar();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.byType(flutter_cupertino.CupertinoAdaptiveTextSelectionToolbar),
          findsOneWidget,
        );
      },
    );
  });

  group('5. Decoupled cupertino_ui Compatibility', () {
    testWidgets(
      'Renders inside cupertino_ui CupertinoApp + CupertinoPageScaffold without failure',
      (WidgetTester tester) async {
        final controller = TextEditingController();
        String? submitted;

        await tester.pumpWidget(
          cupertino_ui.CupertinoApp(
            home: cupertino_ui.CupertinoPageScaffold(
              child: Center(
                child: Pinput(
                  controller: controller,
                  length: 5,
                  onSubmitted: (val) => submitted = val,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Pinput), findsOneWidget);
        expect(find.byType(AnimatedContainer), findsNWidgets(5));

        await tester.tap(find.byType(EditableText), warnIfMissed: false);
        await tester.pump();
        await tester.enterText(find.byType(EditableText), '5432');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(controller.text, '5432');
        expect(submitted, '5432');
      },
    );

    testWidgets('Displays validator error text inside cupertino_ui tree', (
      WidgetTester tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        cupertino_ui.CupertinoApp(
          home: cupertino_ui.CupertinoPageScaffold(
            child: Form(
              key: formKey,
              child: Pinput(validator: (val) => 'Cupertino UI error'),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Cupertino UI error'), findsOneWidget);
    });

    testWidgets(
      'Accepts custom cupertino_ui contextMenuBuilder if passed explicitly',
      (WidgetTester tester) async {
        final controller = TextEditingController(text: '7788');

        await tester.pumpWidget(
          cupertino_ui.CupertinoApp(
            home: cupertino_ui.CupertinoPageScaffold(
              child: Pinput(
                controller: controller,
                length: 4,
                toolbarEnabled: true,
                enableInteractiveSelection: true,
                contextMenuBuilder: (context, editableTextState) {
                  return cupertino_ui
                      .CupertinoAdaptiveTextSelectionToolbar.editableText(
                    editableTextState: editableTextState,
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(EditableText), warnIfMissed: false);
        await tester.pump();
        controller.selection = const TextSelection(
          baseOffset: 0,
          extentOffset: 4,
        );
        await tester.pump();

        final editableTextState = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        editableTextState.toggleToolbar();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.byType(cupertino_ui.CupertinoAdaptiveTextSelectionToolbar),
          findsOneWidget,
        );
      },
    );
  });
}

class _CustomWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _CustomWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      DefaultWidgetsLocalizations.load(
        locale,
      ).then((defaultLoc) => _CustomWidgetsLocalizations(defaultLoc));

  @override
  bool shouldReload(_CustomWidgetsLocalizationsDelegate old) => false;
}

class _CustomWidgetsLocalizations implements WidgetsLocalizations {
  const _CustomWidgetsLocalizations(this._delegate);

  final WidgetsLocalizations _delegate;

  @override
  String get copyButtonLabel => 'Copier';

  @override
  String get cutButtonLabel => 'Couper';

  @override
  String get pasteButtonLabel => 'Coller';

  @override
  String get selectAllButtonLabel => 'Tout sélectionner';

  @override
  String get lookUpButtonLabel => _delegate.lookUpButtonLabel;

  @override
  String get noResultsFound => _delegate.noResultsFound;

  @override
  String get radioButtonUnselectedLabel => _delegate.radioButtonUnselectedLabel;

  @override
  String get reorderItemDown => _delegate.reorderItemDown;

  @override
  String get reorderItemLeft => _delegate.reorderItemLeft;

  @override
  String get reorderItemRight => _delegate.reorderItemRight;

  @override
  String get reorderItemToEnd => _delegate.reorderItemToEnd;

  @override
  String get reorderItemToStart => _delegate.reorderItemToStart;

  @override
  String get reorderItemUp => _delegate.reorderItemUp;

  @override
  String get searchResultsFound => _delegate.searchResultsFound;

  @override
  String get searchWebButtonLabel => _delegate.searchWebButtonLabel;

  @override
  String get shareButtonLabel => _delegate.shareButtonLabel;

  @override
  TextDirection get textDirection => _delegate.textDirection;
}
