import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class RoundedWithCustomCursor extends StatefulWidget {
  const RoundedWithCustomCursor({super.key});

  @override
  _RoundedWithCustomCursorState createState() =>
      _RoundedWithCustomCursorState();

  @override
  String toStringShort() => 'Rounded With Cursor';
}

class _RoundedWithCustomCursorState extends State<RoundedWithCustomCursor> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
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
      textStyle: GoogleFonts.poppins(
        fontSize: 22,
        color: const Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: defaultDecoration,
    );

    return Form(
      key: formKey,
      child: Column(
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
                hapticFeedback: HapticFeedbackType.lightImpact,
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
            onPressed: () => formKey.currentState!.validate(),
            child: const Text('Validate'),
          ),
        ],
      ),
    );
  }
}
