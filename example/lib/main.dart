import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput_example/pages/gallery_page.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

void main() => runApp(AppView());

class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final app = MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            tabBarTheme: TabBarTheme(
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Color.fromRGBO(30, 60, 87, 1), width: 2.0),
                ),
              ),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 16),
              labelStyle: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600),
              labelColor: Color.fromRGBO(30, 60, 87, 1),
              unselectedLabelColor: Color.fromRGBO(107, 137, 165, 1),
            ),
          ),
          home: GalleryPage(),
        );

        final shortestSide =
            min(constraints.maxWidth.abs(), constraints.maxHeight.abs());

        if (shortestSide > 600) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Container(
              width: 375,
              height: 812,
              margin: EdgeInsets.all(20),
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
          );
        }
        return app;
      },
    );
  }
}
