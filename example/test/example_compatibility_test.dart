import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as cupertino_ui;
import 'package:pinput/pinput.dart';
import 'package:pinput_example/main.dart';

void main() {
  testWidgets(
    'Pinput works seamlessly inside material_ui MaterialApp and Scaffold',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PinputExample())),
      );

      expect(find.byType(Pinput), findsOneWidget);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '1234');
      await tester.pump();
    },
  );

  testWidgets(
    'Pinput works seamlessly inside cupertino_ui CupertinoApp and PageScaffold',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const cupertino_ui.CupertinoApp(
          home: cupertino_ui.CupertinoPageScaffold(child: Pinput(length: 4)),
        ),
      );

      expect(find.byType(Pinput), findsOneWidget);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '5678');
      await tester.pump();
    },
  );
}
