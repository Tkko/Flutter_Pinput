import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinputBuilderExample extends StatefulWidget {
  const PinputBuilderExample({super.key});

  @override
  State<PinputBuilderExample> createState() => _PinputBuilderExampleState();
}

class _PinputBuilderExampleState extends State<PinputBuilderExample> {
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
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            // Specify direction if desired
            textDirection: TextDirection.ltr,
            child: Pinput.builder(
              builder: (context, pinState) {
                final dec = () {
                  switch (pinState.type) {
                    case PinItemStateType.disabled:
                      return BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: Colors.black),
                      );
                    case PinItemStateType.focused:
                      return BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: Colors.greenAccent),
                      );
                    case PinItemStateType.error:
                      return BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: Colors.redAccent),
                      );
                    default:
                      return BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: Colors.black),
                      );
                  }
                }();
                return Container(
                  decoration: dec,
                  padding: const EdgeInsets.all(16),
                  child: Text(pinState.value),
                );
              },
              controller: pinController,
              focusNode: focusNode,
              separatorBuilder: (index) => const SizedBox(width: 8),
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              validator: (value) {
                return value == '2222' ? null : 'Pin is incorrect';
              },
              onCompleted: (pin) {
                debugPrint('onCompleted: $pin');
              },
              onChanged: (value) {
                debugPrint('onChanged: $value');
              },
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
