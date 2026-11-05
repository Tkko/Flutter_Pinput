<div align="center">

# Pinput

**A customizable PIN / OTP code input for Flutter, with SMS autofill.**

[![Pub](https://img.shields.io/pub/v/pinput.svg)](https://pub.dev/packages/pinput)
[![CI](https://github.com/Tkko/Flutter_Pinput/actions/workflows/ci.yml/badge.svg)](https://github.com/Tkko/Flutter_Pinput/actions/workflows/ci.yml)
[![Stars](https://img.shields.io/github/stars/Tkko/Flutter_Pinput.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/Tkko/Flutter_Pinput)
[![Style](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](LICENSE)

[Live demo](https://tkko.github.io/Flutter_Pinput/) · [Install](#install) · [Usage](#usage) · [SMS autofill](#sms-autofill) · [Examples](example/lib) · [pub.dev](https://pub.dev/packages/pinput) · [Changelog](CHANGELOG.md)

<b>🚀 Have a project in mind? <a href="https://www.linkedin.com/in/thornike/">Let's work together on LinkedIn</a>.</b>

<b>Enjoying this package? Help keep it maintained.</b>

<a href="https://ko-fi.com/flutterman"><img height="40" src="https://user-images.githubusercontent.com/26390946/161375565-e7d64410-bbcf-4a28-896b-7514e106478e.png" alt="Support on Ko-fi"></a>
<a href="https://www.buymeacoffee.com/fman"><img height="40" src="https://user-images.githubusercontent.com/26390946/161375563-69c634fd-89d2-45ac-addd-931b03996b34.png" alt="Buy Me a Coffee"></a>

</div>

<br>

| [Live demo](https://tkko.github.io/Flutter_Pinput/) | Rounded with shadows | Rounded with cursor |
| :---: | :---: | :---: |
| <a href="https://tkko.github.io/Flutter_Pinput/"><img width="180" height="400" src="https://user-images.githubusercontent.com/26390946/155666045-aa93bf48-f8e7-407c-bb19-bc247d9e12bd.png" alt="Live demo"/></a> | <img width="180" height="400" src="https://user-images.githubusercontent.com/26390946/155599527-fe934f2c-5124-4754-bbf6-bb97d55a77c0.gif" alt="Rounded with shadows"/> | <img width="180" height="400" src="https://user-images.githubusercontent.com/26390946/155599870-03387689-7be2-4a30-8e6f-90136a0515be.gif" alt="Rounded with cursor"/> |

<details>
<summary><b>More styles</b></summary>

| Rounded filled | Bottom cursor | Filled |
| :---: | :---: | :---: |
| <img width="180" height="400" src="https://user-images.githubusercontent.com/26390946/155600099-d0a02f55-09e6-4142-92de-066cd71cf211.gif" alt="Rounded filled"/> | <img width="180" height="400" src="https://user-images.githubusercontent.com/26390946/155600276-0380b3b4-3d9c-4ea8-87d0-4f7ebd86e460.gif" alt="Bottom cursor"/> | <img width="180" height="400" src="https://user-images.githubusercontent.com/26390946/155600427-901c1eae-e565-4cf8-a338-8ac40eb1149c.gif" alt="Filled"/> |

</details>

## Features

- Animated decoration switching between pin states
- App-controlled validation feedback, with [`Form` integration](#form-integration) through `FormField`
- SMS autofill on [iOS and Android](#sms-autofill)
- Standard, custom and animated cursor
- Obscuring by character or widget
- Custom keyboard support, paste, haptic feedback
- Closes the keyboard after completion
- Ready-made [templates](example/lib) to pick from

**Platforms:** Android, iOS, web, macOS, Windows and Linux. SMS autofill works out of the box on iOS; on Android the app sets the code on the controller, see [SMS autofill](#sms-autofill).

## Install

```bash
flutter pub add pinput
```

```dart
import 'package:pinput/pinput.dart';
```

## Usage

```dart
Pinput(
  onCompleted: (pin) => print(pin),
)
```

### Theming

A pin has six states: `default`, `focused`, `filled`, `empty`, `disabled` and `error`. Each can have its own theme, and the pin animates between them automatically. Create a base `PinTheme`, then derive the others from it:

```dart
final defaultPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
  decoration: BoxDecoration(
    border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
    borderRadius: BorderRadius.circular(20),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
  borderRadius: BorderRadius.circular(8),
);

final filledPinTheme = defaultPinTheme.copyDecorationWith(
  color: Color.fromRGBO(234, 239, 243, 1),
);

return Pinput(
  theme: PinThemes(
    fallback: defaultPinTheme,
    focused: focusedPinTheme,
    filled: filledPinTheme,
  ),
  validationState: const PinValidationState.idle(),
  cursor: const PinCursor.blinking(),
  onCompleted: (pin) => print(pin),
);
```

To make every state look the same, pass `PinThemes.all(defaultPinTheme)`. Without a theme, the built-in look marks the focused, disabled and error states.

| `PinTheme` property | Type / default |
| :--- | :---: |
| `width` | `56.0` |
| `height` | `60.0` |
| `textStyle` | `TextStyle` |
| `margin`, `padding` | `EdgeInsetsGeometry` |
| `constraints` | `BoxConstraints` |
| `decoration` | any `Decoration` |
| `placeholder` | `Widget` (replaces `preFilledWidget`) |

<details>
<summary><b>PinThemes in depth</b></summary>

`PinThemes` mirrors `WidgetStateProperty`: use `PinThemes(fallback:, focused:, …)`, `PinThemes.all`, or `PinThemes.resolveWith((item, validation) => ...)` to pick a theme per pin. `item` has the pin's `index`, `value`, `type` (`PinItemStateType`: `focused`, `filled`, `empty`, `disabled`, `error`), `isFilled`, `isFocused` and `showCursor`. `isFocused` stays accurate while `type` is `error`, and `showCursor` tells a full PIN's focused last pin from the cursor.

- In the named form, a state you don't set uses `fallback`.
- Set `valid` or `validating` to style the pins while the app supplies `PinValidationState.valid()` or `.validating()`. Otherwise those states don't change the look.
- Implement `PinThemes` to share a theme as your own type, or wrap part of your app in `DefaultPinThemes(themes: ..., child: ...)` to style every `Pinput` below it that has no `theme`.
- A state theme is used exactly as written and is not merged with `fallback`, so derive it with `copyWith`.
- `PinTheme.decoration` accepts any `Decoration` (`BoxDecoration`, `ShapeDecoration`, …), but `copyDecorationWith` and `copyBorderWith` require a `BoxDecoration`.
- `PinTheme.defaults` is the built-in theme to derive from.

</details>

### Controller and focus

```dart
final pinController = TextEditingController();

pinController.setText('1222');       // set text programmatically
pinController.appendPin('1', 4);     // append a typed character, useful for a custom keyboard
pinController.deleteLastPin();       // delete the last character
// Text longer than Pinput.length is cut to that length, like typed text.

final pinputFocusNode = FocusNode();
pinputFocusNode.requestFocus();
pinputFocusNode.unfocus();

Pinput(
  controller: pinController,
  focusNode: pinputFocusNode,
);
```

Don't call `setText`, `appendPin`, `deleteLastPin`, `requestFocus` or `unfocus` in `build`. The snippet is only an illustration.

### Cursor, masking and animation

```dart
Pinput(
  cursor: PinCursor.blinking(child: MyCursor()), // static() or hidden() are also available
  obscuring: const PinObscuring.character('*'),  // null shows the original text
  animation: const PinAnimation.slide(
    beginOffset: Offset(0, 0.5),
    duration: Duration(milliseconds: 250),
  ),
)
```

`PinAnimation` supports `none()`, `scale()` (default), `fade()`, `slide()`, `rotation()` and `custom(transitionBuilder: …)`. Every constructor accepts `duration` and `curve`. Cursor blinking is independent of pin-content transitions, and `PinCursor.blinking(blinkDuration: …)` sets its speed. Animations and blinking stop when the platform asks to reduce motion.

<details>
<summary><b>Obscuring, layout and selection details</b></summary>

- `PinObscuring.character()` uses a bullet by default. A character must be one UTF-16 code unit, matching Flutter's native requirement.
- To keep a typed pin visible for a moment before masking, pass a duration: `PinObscuring.character('*', Duration(seconds: 1))` or `PinObscuring.widget(MyDot(), revealDuration: …)`.
- `PinObscuring.widget(MyDot())` supplies custom visible masking and uses a bullet for native obscuring. Masking widgets may be stateful: each slot creates its own `State`. Don't reuse a masking widget containing a shared `GlobalKey` across slots.
- The original text remains available in the controller and callbacks.
- With `itemBuilder`, `obscuring` only enables native masking. The builder must mask visible content itself.
- `PinLayout(textDirection: TextDirection.ltr)` keeps a numeric code left to right in an RTL app.
- Set `enableInteractiveSelection: false` to disable interactive selection. Set `contextMenuBuilder: null` to hide the modern context menu while keeping selection enabled. Legacy custom `selectionControls` follow Flutter's legacy toolbar behavior. Use controls with `TextSelectionHandleControls` to customize handles with the modern menu API.

</details>

### Validation

Pinput renders app-owned validation feedback through `validationState`:

| State | Behavior |
| :--- | :--- |
| `PinValidationState.idle()` | Default; no current result or feedback |
| `PinValidationState.validating()` | Pending; normal appearance, no error |
| `PinValidationState.valid()` | Passed; normal appearance, no error |
| `PinValidationState.invalid([message])` | Error pin theme and optional error message, even while focused |

```dart
Pinput(
  validationState: state.pinValidation,
  onChanged: cubit.pinChanged,
  onCompleted: cubit.verifyPin,
)
```

Run synchronous or asynchronous validation in your app, using `onChanged`, `onCompleted`, `onSubmitted` or a submit button. `onCompleted` reports a full PIN with the cursor at the end, not successful validation. Clear old results when the PIN changes and ignore async responses for outdated inputs or disposed views.

<details>
<summary><b>Validation details and error widgets</b></summary>

- Pinput does not clear supplied feedback, run checks, or modify text or focus.
- Pending and valid states add no loading or success visuals and don't disable editing. Use `inputMode: PinInputMode.readOnly` or `PinInputMode.disabled` explicitly when needed.
- `errorTextStyle` styles the default error text. `errorBuilder(context, message, pin)` replaces the default error widget and ignores `errorTextStyle`. Both work in `Pinput`, including with `itemBuilder`.
- The message of `invalid()` is optional: without it, error styling applies with no default text or error padding. An `errorBuilder` still runs with a null message, so it can supply its own localized text.
- The `validating()` factory uses the `PinValidationValidating` subtype for pattern matching. `PinAnimation` and `PinObscuring` support value equality, and custom masking widgets use normal widget equality.
- For a runnable async example, open **Async example** in the default example app, or the **Async validation** tab in the demo gallery. Enter `2222` for success. See [`AsyncValidationExample`](example/lib/demo/async_validation_example.dart).

</details>

### Form integration

Pinput does not register itself with `Form`. Wrap it in a `FormField<String>`:

```dart
FormField<String>(
  initialValue: '',
  validator: (pin) => pin == '2224' ? null : 'Pin is incorrect',
  builder: (field) => Pinput(
    onChanged: field.didChange,
    validationState: field.errorText == null
        ? const PinValidationState.idle()
        : PinValidationState.invalid(field.errorText!),
  ),
)
```

Set `autovalidateMode` on the wrapper for automatic validation. `FormState.validate()` is synchronous, so it can't await server verification. An external async result must already be available if the wrapper uses it.

<details>
<summary><b>Using a text controller with FormField</b></summary>

Synchronize the controller with the wrapper using a listener, including programmatic changes. In the owning `State`:

```dart
final pinController = TextEditingController();
final pinFieldKey = GlobalKey<FormFieldState<String>>();

@override
void initState() {
  super.initState();
  pinController.addListener(() {
    final field = pinFieldKey.currentState;
    if (field != null && field.value != pinController.text) {
      field.didChange(pinController.text);
    }
  });
}

// Inside the Form:
FormField<String>(
  key: pinFieldKey,
  initialValue: '',
  onReset: pinController.clear,
  validator: (pin) => pin == '2224' ? null : 'Pin is incorrect',
  builder: (field) => Pinput(
    controller: pinController,
    validationState: field.errorText == null
        ? const PinValidationState.idle()
        : PinValidationState.invalid(field.errorText!),
  ),
)
```

Dispose `pinController` in the owning `State`. For non-empty initial values, restore that same text in `onReset` rather than clearing it.

</details>

## SMS autofill

### iOS

Works out of the box: the user taps the code above the keyboard.

### Android

Pinput doesn't read SMS itself. Your app listens for the code and sets it on the controller, so it also owns starting and stopping the listener.

**With `firebase_auth`**, set the controller in the [`verificationCompleted`](https://firebase.flutter.dev/docs/auth/phone#verificationcompleted) callback:

```dart
Pinput(controller: pinController);

await FirebaseAuth.instance.verifyPhoneNumber(
  verificationCompleted: (PhoneAuthCredential credential) {
    pinController.setText(credential.smsCode);
  },
  verificationFailed: (FirebaseAuthException e) {},
  codeSent: (String verificationId, int? resendToken) {},
  codeAutoRetrievalTimeout: (String verificationId) {},
);
```

**Without `firebase_auth`**, use the [SMS Retriever API](https://developers.google.com/identity/sms-retriever/overview) or the [SMS User Consent API](https://developers.google.com/identity/sms-retriever/user-consent/overview). [`smart_auth`](https://pub.dev/packages/smart_auth) wraps both:

```dart
class _OtpPageState extends State<OtpPage> {
  final pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listenForSmsCode();
  }

  Future<void> _listenForSmsCode() async {
    final res = await SmartAuth.instance.getSmsWithRetrieverApi();
    final code = res.data?.code;
    if (mounted && code != null) pinController.setText(code);
  }

  @override
  void dispose() {
    SmartAuth.instance.removeSmsRetrieverApiListener();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Pinput(controller: pinController);
}
```

To keep listening for more messages, call `_listenForSmsCode` again after each result.

| API | App signature | User interaction | Example |
| :--- | :---: | :---: | :--- |
| SMS Retriever | Required | None, the code is applied automatically | [example](example/lib/demo/sms_retriever_api_example.dart) |
| SMS User Consent | Not needed | The user confirms reading the message | [example](example/lib/demo/user_consent_api_example.dart) |

<details>
<summary><b>SMS Retriever: app signature and message format</b></summary>

You need the app signature, see this [guide](https://stackoverflow.com/questions/53849023/android-sms-retriever-api-computing-apps-hash-string-problem). The signature can differ between debug and release builds.

Include it in the SMS your backend sends:

```
Your ExampleApp code is: 123456
kg+TZ3A5qzS
```

</details>

## FAQ

<details>
<summary><b>Autofill isn't working on iOS</b></summary>

- Use a real device, not the simulator.
- Temporarily replace `Pinput` with a `TextField` and check if autofill works. If not, it's probably a problem with the SMS you receive, since autofill doesn't work with most languages.
- On a non-stable Flutter version, something may be broken inside the framework.

</details>

<details>
<summary><b>I'm using firebase_auth</b></summary>

Set the controller's value in the `verificationCompleted` callback, see [SMS autofill](#android).

</details>

## Contributing

PRs are welcome. The [example app](example/lib) has multiple templates to choose from.

---

<div align="center">

Made by [Tornike](https://www.linkedin.com/in/thornike/) · [MIT License](LICENSE)

If this package helps you, a ⭐ on GitHub means a lot.

</div>
