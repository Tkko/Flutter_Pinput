import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput_example/demo/pages/gallery_page.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

void main() => runApp(const AppView());

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final app = MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const GalleryPage(),
        );

        final shortestSide =
            min(constraints.maxWidth.abs(), constraints.maxHeight.abs());
        if (shortestSide > 600) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    'Pinput Examples',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    width: 500,
                    height: min(1100, constraints.maxHeight.abs()),
                    margin: const EdgeInsets.all(20),
                    clipBehavior: Clip.antiAlias,
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black, width: 15),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: app,
                  ),
                ),
              ],
            ),
          );
        }
        return app;
      },
    );
  }
}
