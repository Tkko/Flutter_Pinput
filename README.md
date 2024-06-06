<div align="center">  
 <h1 align="center" style="font-size: 70px;">Flutter pin code input</h1>

<!--  Donations -->
 <a href="https://ko-fi.com/flutterman">
  <img width="300" src="https://user-images.githubusercontent.com/26390946/161375567-9e14cd0e-1675-4896-a576-a449b0bcd293.png">
 </a>
 <div align="center">
   <a href="https://www.buymeacoffee.com/fman">
    <img width="150" alt="buymeacoffee" src="https://user-images.githubusercontent.com/26390946/161375563-69c634fd-89d2-45ac-addd-931b03996b34.png">
  </a>
   <a href="https://ko-fi.com/flutterman">
    <img width="150" alt="Ko-fi" src="https://user-images.githubusercontent.com/26390946/161375565-e7d64410-bbcf-4a28-896b-7514e106478e.png">
  </a>
 </div>
<!--  Donations -->

<h3 align="center" style="font-size: 35px;">Need anything Flutter related? Reach out on <a href="https://www.linkedin.com/in/thornike/">LinkedIn</a>
</h3>


[![Pub package](https://img.shields.io/pub/v/pinput.svg)](https://pub.dev/packages/pinput)
[![Github starts](https://img.shields.io/github/stars/tkko/flutter_pinput.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/tkko/flutter_pinput)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![pub package](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

</div>

Flutter Pinput is a package that provides an easy-to-use and customizable Pin code input field. It offers several features such as animated decoration switching, form validation, SMS autofill, custom cursor, copying from clipboard, and more. It also provides beautiful examples that you can choose from.

## Features:
- Animated Decoration Switching
- Form validation
- SMS Autofill on iOS
- SMS Autofill on Android
- Standard Cursor
- Custom Cursor
- Cursor Animation
- Copy From Clipboard
- Ready For Custom Keyboard
- Standard Paste option
- Obscuring Character
- Obscuring Widget
- Haptic Feedback
- Close Keyboard After Completion
- Beautiful [Examples](https://github.com/Tkko/Flutter_PinPut/tree/master/example/lib)

## Support

PRs Welcome

Discord [Channel](https://rebrand.ly/qwc3s0d)

[Examples](https://github.com/Tkko/Flutter_PinPut/tree/master/example/lib) app on Github has multiple templates to choose from

Don't forget to give it a star ⭐

## Demo

| [Live Demo](https://rebrand.ly/6390b8) | Rounded With Shadows | Rounded With Cursor |
| - | - | - |
| <a href="https://rebrand.ly/6390b8"><img width="300" src="https://user-images.githubusercontent.com/26390946/155666045-aa93bf48-f8e7-407c-bb19-bc247d9e12bd.png"/></a> | <img width="300" src="https://user-images.githubusercontent.com/26390946/155599527-fe934f2c-5124-4754-bbf6-bb97d55a77c0.gif"/> | <img width="300" src="https://user-images.githubusercontent.com/26390946/155599870-03387689-7be2-4a30-8e6f-90136a0515be.gif"/> |

| Rounded Filled | With Bottom Cursor | Filled |
| - | - | - |
| <img width="300" src="https://user-images.githubusercontent.com/26390946/155600099-d0a02f55-09e6-4142-92de-066cd71cf211.gif"/> | <img width="300" src="https://user-images.githubusercontent.com/26390946/155600276-0380b3b4-3d9c-4ea8-87d0-4f7ebd86e460.gif"/> | <img width="300" src="https://user-images.githubusercontent.com/26390946/155600427-901c1eae-e565-4cf8-a338-8ac40eb1149c.gif"/> |

## Getting Started

The pin has 6 states `default` `focused`, `submitted`, `following`, `disabled`, `error`, you can customize each state by specifying theme parameter.
Pin smoothly animates from one state to another automatically.
`PinTheme Class`


| Property    |    Default/Type    |
|-------------|:------------------:|
| width       |        56.0        |
| height      |        60.0        |
| textStyle   |    TextStyle()     |
| margin      | EdgeInsetsGeometry |
| padding     | EdgeInsetsGeometry |
| constraints |   BoxConstraints   |

You can use standard Pinput like so

```dart
Widget buildPinPut() {
  return Pinput(
    onCompleted: (pin) => print(pin),
  );
}
```

If you want to customize it, create `defaultPinTheme` first.

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
```

if you want all pins to be the same don't pass other theme parameters,
If not, create `focusedPinTheme`, `submittedPinTheme`, `followingPinTheme`, `errorPinTheme` from `defaultPinTheme`

```dart
final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
  borderRadius: BorderRadius.circular(8),
);

final submittedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration.copyWith(
    color: Color.fromRGBO(234, 239, 243, 1),
  ),
);
```

Put everything together

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

final submittedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration.copyWith(
    color: Color.fromRGBO(234, 239, 243, 1),
  ),
);

return Pinput(
defaultPinTheme: defaultPinTheme,
focusedPinTheme: focusedPinTheme,
submittedPinTheme: submittedPinTheme,
validator: (s) {
return s == '2222' ? null : 'Pin is incorrect';
},
pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
showCursor: true,
onCompleted: (pin) => print(pin),
);
```

## SMS Autofill

### iOS

Works out of the box, by tapping the code on top of the keyboard

### Android

If you are using [firebase_auth](https://firebase.flutter.dev/docs/auth/phone#verificationcompleted) you have to set `controller'`s value in `verificationCompleted` callback, here is an example code:
``` dart
    Pinput(
      controller: pinController,
    );
```
And set pinController's value in `verificationCompleted` callback:
``` dart
    await FirebaseAuth.instance.verifyPhoneNumber(
      verificationCompleted: (PhoneAuthCredential credential) {
        pinController.setText(credential.smsCode);
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
```
---
If you aren't using firebase_auth, you have two options, [SMS Retriever API](https://developers.google.com/identity/sms-retriever/overview?hl=en) and [SMS User Consent API](https://developers.google.com/identity/sms-retriever/user-consent/overview),

[SmartAuth](https://pub.dev/packages/smart_auth) is a wrapper package for Flutter for these APIs, so go ahead and add it as a dependency.

###### SMS Retriever API

To use Retriever API you need the App signature - [guide](https://stackoverflow.com/questions/53849023/android-sms-retriever-api-computing-apps-hash-string-problem)

`Note that The App Signature might be different for debug and release mode`

Once you get the app signature, you should include it in the SMS message in you backend like so:

SMS example:
```
Your ExampleApp code is: 123456
kg+TZ3A5qzS
```
[Example Code](/example/lib/demo/sms_retriever_api_example.dart)

Sms code will be automatically applied, without user interaction.

###### SMS User Consent API

You don't need the App signature, the user will be prompted to confirm reading the message
[Example Code](/example/lib/demo/user_consent_api_example.dart)


<img src="https://user-images.githubusercontent.com/26390946/158870589-a2d631fa-55d7-487f-8c30-d378bab4c21d.png" style="height: 700px; width: auto; image-rendering: pixelated;" alt="Request Hint" />

## See Example app for more [templates](https://github.com/Tkko/Flutter_PinPut/tree/master/example/lib)

## Tips

- #### Controller

```dart
/// Create Controller  
final pinController = TextEditingController();

/// Set text programmatically  
pinController.setText('1222');

/// Append typed character, useful if you are using custom keyboard  
pinController.append('1', 4);

/// Delete last character  
pinController.delete();

/// Don't call setText, append, delete in build method, this is just illustration.  

return Pinput(
  controller: pinController,  
);  
```

- #### Focus

```dart
/// Create FocusNode  
final pinputFocusNode = FocusNode();

/// Focus pinput  
pinputFocusNode.requestFocus();

/// UnFocus pinput  
pinputFocusNode.unfocus();

/// Don't call requestFocus, unfocus in build method, this is just illustration.  

return Pinput(
  focusNode: pinputFocusNode,
);  
```

- #### Validation

```dart
/// Create key
final formKey = GlobalKey<FormState>();

/// Validate manually
/// Don't call validate in build method, this is just illustration.
formKey.currentState!.validate();

return Form(
  key: formKey,
  child: Pinput(
  // Without Validator
  // If true error state will be applied no matter what validator returns
  forceErrorState: true,
  // Text will be displayed under the Pinput
  errorText: 'Error',

  /// ------------
  /// With Validator
  /// Auto validate after user tap on keyboard done button, or completes Pinput
  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
  validator: (pin) {
    if (pin == '2224') return null;

    /// Text will be displayed under the Pinput
    return 'Pin is incorrect';
    },
  ),
);
```

## FAQ

#### autofill isn't working on iOS?

- Make sure you are using real device, not simulator
- Temporary replace Pinput with TextField, and check if autofill works. If, not it's probably a
  problem with SMS you are getting, autofill doesn't work with most of the languages
- If you are using non stable version of Flutter that might be cause because something might be
  broken inside the Framework

#### are you using firebase_auth?

You should set `controller'`s value in `verificationCompleted` callback, here is an example code:
``` dart
    Pinput(
      controller: pinController,
    );
    
    await FirebaseAuth.instance.verifyPhoneNumber(
      verificationCompleted: (PhoneAuthCredential credential) {
        pinController.setText(credential.smsCode);
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
```