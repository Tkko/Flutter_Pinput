import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:pinput_example/demo/async_validation_example.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Pinput Example'),
          actions: [
            Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Async validation')),
                      body: const AsyncValidationExample(),
                    ),
                  ),
                ),
                child: const Text('Async example'),
              ),
            ),
          ],
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(30, 60, 87, 1),
          ),
        ),
        body: const FractionallySizedBox(
          widthFactor: 1,
          // You can also checkout the [PinputBuilderExample]
          child: PinputExample(),
        ),
      ),
    ),
  );
}

/// This is the basic usage of Pinput
/// For more examples check out the demo directory
class PinputExample extends StatefulWidget {
  const PinputExample({super.key});

  @override
  State<PinputExample> createState() => _PinputExampleState();
}

class _PinputExampleState extends State<PinputExample> {
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    // On web, disable the browser's context menu since this example uses a custom
    // Flutter-rendered context menu.
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
    focusNode = FocusNode();

    /// In case you need an SMS autofill feature
    _listenForSmsCode();
  }

  /// You can use any package to retrieve the SMS code, in this example we are
  /// using SmartAuth. Set the code on the controller when it arrives.
  Future<void> _listenForSmsCode() async {
    final signature = await SmartAuth.instance.getAppSignature();
    debugPrint('App Signature: $signature');
    final res = await SmartAuth.instance.getSmsWithUserConsentApi();
    final code = res.data?.code;
    if (mounted && code != null) pinController.setText(code);
  }

  @override
  void dispose() {
    if (kIsWeb) {
      BrowserContextMenu.enableContextMenu();
    }
    SmartAuth.instance.removeUserConsentApiListener();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: borderColor),
    );

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: defaultDecoration,
    );

    /// Optionally you can use form to validate the Pinput
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            // Specify direction if desired
            textDirection: TextDirection.ltr,
            child: FormField<String>(
              initialValue: pinController.text,
              validator: (value) => value == '2222' ? null : 'Pin is incorrect',
              builder: (field) => Pinput(
                length: 4,
                validationState: field.errorText == null
                    ? const PinValidationState.idle()
                    : PinValidationState.invalid(field.errorText!),
                controller: pinController,
                focusNode: focusNode,
                theme: PinThemes(
                  fallback: defaultPinTheme,
                  focused: defaultPinTheme.copyWith(
                    decoration: defaultDecoration.copyWith(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  filled: defaultPinTheme.copyWith(
                    decoration: defaultDecoration.copyWith(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  error: defaultPinTheme.copyWith(
                    decoration: defaultDecoration.copyWith(
                      border: Border.all(color: Colors.redAccent),
                    ),
                  ),
                ),
                layout: PinLayout(
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                ),
                hapticFeedbackType: HapticFeedbackType.lightImpact,
                onCompleted: (pin) {
                  debugPrint('onCompleted: $pin');
                },
                onChanged: (value) {
                  field.didChange(value);
                  debugPrint('onChanged: $value');
                },
                cursor: PinCursor.blinking(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 1,
                        color: focusedBorderColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              focusNode.unfocus();
              formKey.currentState!.validate();
            },
            child: const Text('Validate'),
          ),
        ],
      ),
    );
  }
}
