import 'package:flutter/material.dart';
import 'package:flutter_pinput/flutter_pinput.dart';
import 'package:google_fonts/google_fonts.dart';

class Filled extends StatefulWidget {
  const Filled({super.key});

  @override
  State<Filled> createState() => _FilledState();

  @override
  String toStringShort() => 'Filled';
}

class _FilledState extends State<Filled> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
      decoration: const BoxDecoration(color: Color.fromRGBO(159, 132, 193, 0.8)),
    );

    return Container(
      width: 243,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Pinput(
        length: 4,
        controller: controller,
        focusNode: focusNode,
        separatorBuilder: (index) => Container(height: 64, width: 1, color: Colors.white),
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: const BoxDecoration(color: Color.fromRGBO(124, 102, 152, 1)),
        ),
      ),
    );
  }
}
