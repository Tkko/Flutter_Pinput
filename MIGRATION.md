### Migration to consolidated presentation options

| Previous options | Replacement |
| --- | --- |
| `showCursor: false` | `cursorBehavior: CursorBehavior.hidden` |
| `showCursor: true`, `isCursorAnimationEnabled: false` | `cursorBehavior: CursorBehavior.static` |
| Default visible animated cursor | `cursorBehavior: CursorBehavior.blinking` (default) |
| `obscureText: false` | `obscuring: null` (default) |
| `obscureText: true`, `obscuringCharacter: '*'` | `obscuring: const PinObscuring.character('*')` |
| `obscureText: true`, `obscuringWidget: widget` | `obscuring: PinObscuring.widget(widget)` |
| `pinAnimationType: PinAnimationType.slide`, `slideTransitionBeginOffset: offset` | `pinAnimation: PinAnimation.slide(beginOffset: offset)` |
| Other `PinAnimationType` values | Corresponding `PinAnimation.none/scale/fade/rotation()` constructor |
| `toolbarEnabled: false` | `enableInteractiveSelection: false` for no selection, or `contextMenuBuilder: null` for no modern menu |

`cursor` still customizes cursor content. `animationDuration` and `animationCurve`
remain shared animation settings. `Pinput.builder` accepts `obscuring` for native
text masking; its item builder is responsible for masking visible content.

There is now one selection enablement policy: `enableInteractiveSelection`.
When omitted, each constructor retains its existing default and the default
constructor uses Flutter's effective selection policy. The removed toolbar flag
no longer independently gates selection gestures.
Legacy custom `selectionControls` that build toolbars can ignore
`contextMenuBuilder`, as in Flutter; use `TextSelectionHandleControls` for modern
handle customization.

### Migration to app-owned validation

Pinput no longer runs validators or registers an internal Flutter `FormField`.
This is a breaking API change:

- Replace `validator` and `pinputAutovalidateMode` with checks in `onChanged`,
  `onCompleted`, `onSubmitted`, or a submit handler.
- Replace `errorText` and `forceErrorState` with
  `PinputValidationState.invalid(message)`. Use `invalid()` for error styling
  without default text, or provide text directly through `errorBuilder`.
- Use `idle()`, `validating()`, and `valid()` to represent other results.
  These states do not display feedback or affect input availability.
- `showErrorWhenFocused` is removed. Invalid feedback is always visible,
  including during focus and editing, until the app changes `validationState`.
- Clear stale validation results on edits and ignore outdated async responses.
  Completion callbacks still report input completion, not successful validation.
- Keep `errorTextStyle`, `errorBuilder`, and `errorPinTheme` for presentation.
  `errorBuilder` receives the optional message and the PIN, and runs for invalid
  states even when the message is null.
  Both constructors expose the error builder and text style.
- For native Form validation, wrap Pinput in `FormField<String>` and map its
  error to `validationState`. Synchronize controller changes and reset explicitly.
  See the README's Flutter Form integration examples.

```dart
Pinput(
  validationState: pinValidation,
  onChanged: (pin) {
    setState(() => pinValidation = const PinputValidationState.idle());
  },
  onCompleted: (pin) {
    setState(() {
      pinValidation = pin == '2222'
          ? const PinputValidationState.valid()
          : const PinputValidationState.invalid('Pin is incorrect');
    });
  },
)
```

### Migration to 5.0.0+

- If you need SMS autofill on Android, you need to add the smart_auth (or similar) package directly
  to your project.

Before 5.0.0:

```dart
class Example extends StatelessWidget {
  const Example({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Pinput(
      androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
      listenForMultipleSmsOnAndroid: true,
    );
  }
}
```

After 5.0.0:

```agsl
dependencies:
  smart_auth: 2.0.0
```

```dart
class SmsRetrieverImpl implements SmsRetriever {
  const SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  Future<void> dispose() {
    return smartAuth.removeSmsListener();
  }

  @override
  Future<String?> getSmsCode() async {
    final res = await smartAuth.getSmsCode();
    if (res.succeed && res.codeFound) {
      return res.code!;
    }
    return null;
  }

  @override
  bool get listenForMultipleSms => false;
}

class SmartAuthExample extends StatefulWidget {
  const SmartAuthExample({Key? key}) : super(key: key);

  @override
  State<SmartAuthExample> createState() => _SmartAuthExampleState();
}

class _SmartAuthExampleState extends State<SmartAuthExample> {
  late final SmsRetrieverImpl smsRetrieverImpl;

  @override
  void initState() {
    smsRetrieverImpl = SmsRetrieverImpl(SmartAuth());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Pinput(
      smsRetriever: smsRetrieverImpl,
    );
  }
}
```