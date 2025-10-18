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