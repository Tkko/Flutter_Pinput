part of '../pinput.dart';

/// An interface for retrieving sms code. Used for SMS autofill.
/// You, as a developer should implement this interface.
abstract class SmsRetriever {
  /// Whether to listen for multiple sms codes.
  bool get listenForMultipleSms;

  /// This method should return the sms code.
  Future<String?> getSmsCode();

  /// Optional method to dispose the sms listener.
  Future<void> dispose();
}

/// SmartAuthExample:
// class SmsRetrieverImpl implements SmsRetriever {
//   const SmsRetrieverImpl(this.smartAuth);
//
//   final SmartAuth smartAuth;
//
//   @override
//   Future<void> dispose() {
//     return smartAuth.removeSmsListener();
//   }
//
//   @override
//   Future<String?> getSmsCode() async {
//     final res = await smartAuth.getSmsCode();
//     if (res.succeed && res.codeFound) {
//       return res.code!;
//     }
//     return null;
//   }
//
//   @override
//   bool get listenForMultipleSms => false;
// }
//
// class SmartAuthExample extends StatefulWidget {
//   const SmartAuthExample({Key? key}) : super(key: key);
//
//   @override
//   State<SmartAuthExample> createState() => _SmartAuthExampleState();
// }
//
// class _SmartAuthExampleState extends State<SmartAuthExample> {
//   late final SmsRetrieverImpl smsRetrieverImpl;
//
//   @override
//   void initState() {
//     smsRetrieverImpl = SmsRetrieverImpl(SmartAuth());
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Pinput(
//       smsRetriever: smsRetrieverImpl,
//     );
//   }
// }
