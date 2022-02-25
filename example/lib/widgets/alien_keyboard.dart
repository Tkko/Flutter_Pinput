import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class AlienKeyboard extends StatelessWidget {
  final TextEditingController controller;

  AlienKeyboard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final padding = 20.0;
        final width = constraints.maxWidth - 2 * padding;
        final maxCount = 5;
        final spacing = 5.0;
        final buttonSize = (width - spacing * (maxCount - 1)) / maxCount;
        return Container(
          padding: EdgeInsets.all(padding),
          height: buttonSize * 4.5,
          width: constraints.maxWidth,
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ...[1, 2, 3, 4, 5].map(
                  (index) {
                    final k = index < 4 ? index - 1 : 5 - index;
                    final top = 40.0 - (k * 20);

                    return Positioned(
                      top: top,
                      left: (index - 1) * (buttonSize + spacing),
                      child: CircularButton(
                        text: '$index',
                        size: buttonSize,
                        onTap: () => controller.append('$index', 4),
                      ),
                    );
                  },
                ),
                ...[6, 7, 8, 9].map(
                  (index) {
                    final k = [7, 8].contains(index) ? 1 : 0;
                    final top = 110.0 - (k * 25);
                    final left = (index - 5.5) * (buttonSize + spacing);

                    return Positioned(
                      top: top,
                      left: left,
                      child: CircularButton(
                        text: '$index',
                        size: buttonSize,
                        onTap: () => controller.append('$index', 4),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 160,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularButton(
                        text: '0',
                        size: buttonSize,
                        onTap: () => controller.append('0', 4),
                      ),
                      SizedBox(width: 4),
                      CircularButton(
                        text: '-',
                        size: buttonSize,
                        onTap: () => controller.delete(),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CircularButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? text;
  final double? size;

  CircularButton({this.onTap, this.text, this.size});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromRGBO(37, 61, 84, 1),
        ),
        child: Center(
          child: Text(
            text!,
            style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
