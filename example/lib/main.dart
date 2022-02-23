import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput_example/otp_page.dart';

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
            colorSchemeSeed: Color.fromRGBO(30, 60, 87, 1),
            tabBarTheme: TabBarTheme(
              indicatorSize: TabBarIndicatorSize.label,
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 16),
              labelStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              labelColor: Color.fromRGBO(30, 60, 87, 1),
              unselectedLabelColor: Color.fromRGBO(107, 137, 165, 1),
            ),
            chipTheme: ChipThemeData(
              selectedColor: Color.fromRGBO(30, 60, 87, 1),
            ),
          ),
          home: PinPutGallery(),
        );
        if (constraints.maxWidth > 600 && constraints.maxHeight > 600) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: .5,
              child: Container(
                margin: EdgeInsets.all(20),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 20,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: app,
              ),
            ),
          );
        }
        return app;
      },
    );
  }
}

class PinPutGallery extends StatefulWidget {
  @override
  PinPutGalleryState createState() => PinPutGalleryState();
}

class PinPutGalleryState extends State<PinPutGallery> with SingleTickerProviderStateMixin {
  TabController _tabController;

  final backgroundColors = [
    [Color.fromRGBO(228, 217, 236, 1), Color.fromRGBO(255, 255, 255, 1)],
    [Color.fromRGBO(200, 255, 221, 1), Color.fromRGBO(255, 255, 255, 1)],
    [Colors.white, Colors.white],
  ];

  final pinPuts = [
    OptPage(OnlyBottomCursor()),
    OptPage(RoundedWithCustomCursor()),
    OptPage(FilledRoundedPinPut()),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: pinPuts.length, vsync: this);
    _tabController.addListener(() {
      FocusScope.of(context).unfocus();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: AnimatedBuilder(
        animation: _tabController.animation,
        builder: (BuildContext context, Widget child) {
          final anim = _tabController.animation.value;
          final Color fromColor = Color.lerp(
            backgroundColors[anim.floor()].first,
            backgroundColors[anim.ceil()].first,
            anim - anim.floor(),
          );

          final Color toColor = Color.lerp(
            backgroundColors[anim.floor()].last,
            backgroundColors[anim.ceil()].last,
            anim - anim.floor(),
          );

          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [fromColor, toColor],
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).viewPadding.top),
                  TabBar(
                    controller: _tabController,
                    tabs: pinPuts.map((item) {
                      return Tab(text: '$item');
                    }).toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: pinPuts,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // void _showSnackBar(String pin) {
  //   final snackBar = SnackBar(
  //     duration: const Duration(seconds: 3),
  //     content: Container(
  //       height: 80.0,
  //       child: Center(
  //         child: Text(
  //           'Pin Submitted. Value: $pin',
  //           style: const TextStyle(fontSize: 25.0),
  //         ),
  //       ),
  //     ),
  //     backgroundColor: Colors.deepPurpleAccent,
  //   );
  //   ScaffoldMessenger.of(context)
  //     ..hideCurrentSnackBar()
  //     ..showSnackBar(snackBar);
  // }
}

class OnlyBottomCursor extends StatefulWidget {
  @override
  _OnlyBottomCursorState createState() => _OnlyBottomCursorState();
}

class _OnlyBottomCursorState extends State<OnlyBottomCursor> {
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
    const borderColor = Color.fromRGBO(30, 60, 87, 1);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.poppins(fontSize: 22, color: Color.fromRGBO(30, 60, 87, 1)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final cursor = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 56,
          height: 3,
          decoration: BoxDecoration(
            color: borderColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );

    return SizedBox(
      height: 68,
      child: PinPut(
        length: 5,
        pinAnimationType: PinAnimationType.none,
        controller: controller,
        focusNode: focusNode,
        defaultTheme: defaultPinTheme,
        showCursor: true,
        cursor: cursor,
      ),
    );
  }
}

class RoundedWithCustomCursor extends StatefulWidget {
  @override
  _RoundedWithCustomCursorState createState() => _RoundedWithCustomCursorState();
}

class _RoundedWithCustomCursorState extends State<RoundedWithCustomCursor> {
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
    const focusedBorderColor = Color.fromRGBO(137, 169, 162, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(208, 212, 204, 1);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.poppins(fontSize: 22, color: Color.fromRGBO(30, 60, 87, 1)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return SizedBox(
      height: 68,
      child: PinPut(
        controller: controller,
        focusNode: focusNode,
        defaultTheme: defaultPinTheme,
        showCursor: true,
        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 9),
              width: 22,
              height: 1,
              color: focusedBorderColor,
            ),
          ],
        ),
        focusedPinTheme: defaultPinTheme.copyWith(
          height: 56,
          width: 56,
          decoration: defaultPinTheme.decoration.copyWith(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: focusedBorderColor),
          ),
        ),
        submittedPinTheme: defaultPinTheme.copyWith(
          height: 56,
          width: 56,
          decoration: defaultPinTheme.decoration.copyWith(
            color: fillColor,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: focusedBorderColor),
          ),
        ),
      ),
    );
  }
}

class FilledRoundedPinPut extends StatefulWidget {
  @override
  _FilledRoundedPinPutState createState() => _FilledRoundedPinPutState();
}

class _FilledRoundedPinPutState extends State<FilledRoundedPinPut> {
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
    const borderColor = Color.fromRGBO(114, 178, 238, 1);
    const fillColor = Color.fromRGBO(222, 231, 240, .57);
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.poppins(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return SizedBox(
      height: 68,
      child: PinPut(
        controller: controller,
        focusNode: focusNode,
        defaultTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          height: 68,
          width: 64,
          decoration: defaultPinTheme.decoration.copyWith(
            border: Border.all(color: borderColor),
          ),
        ),
        submittedPinTheme: defaultPinTheme.copyWith(),
      ),
    );
  }
}

// class PurePinPut extends StatefulWidget {
//   final ValueChanged<String> onSubmit;
//
//   PurePinPut(this.onSubmit);
//
//   @override
//   _PurePinPutState createState() => _PurePinPutState();
// }
//
// class _PurePinPutState extends State<PurePinPut> {
//   final _pinPutController = TextEditingController();
//   final _pinPutFocusNode = FocusNode();
//
//   @override
//   void dispose() {
//     _pinPutController.dispose();
//     _pinPutFocusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(30.0),
//       child: PinPut(),
//     );
//   }
// }
//
// class RoundedCorners extends StatefulWidget {
//   final ValueChanged<String> onSubmit;
//
//   RoundedCorners(this.onSubmit);
//
//   @override
//   _RoundedCornersState createState() => _RoundedCornersState();
// }
//
// class _RoundedCornersState extends State<RoundedCorners> {
//   final _pinPutController = TextEditingController();
//   final _pinPutFocusNode = FocusNode();
//
//   @override
//   void dispose() {
//     _pinPutController.dispose();
//     _pinPutFocusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final BoxDecoration pinPutDecoration = BoxDecoration(
//       color: const Color.fromRGBO(43, 46, 66, 1),
//       borderRadius: BorderRadius.circular(10.0),
//       border: Border.all(
//         color: const Color.fromRGBO(126, 203, 224, 1),
//       ),
//     );
//
//     return Padding(
//       padding: const EdgeInsets.all(30.0),
//       child: PinPut(
//         length: 4,
//         showCursor: true,
//         textStyle: const TextStyle(fontSize: 25.0, color: Colors.white),
//         pinWidth: 55.0,
//         pinHeight: 55.0,
//         onSubmit: widget.onSubmit,
//         focusNode: _pinPutFocusNode,
//         controller: _pinPutController,
//         submittedFieldDecoration: pinPutDecoration,
//         selectedFieldDecoration: pinPutDecoration,
//         followingFieldDecoration: pinPutDecoration,
//         pinAnimationType: PinAnimationType.fade,
//       ),
//     );
//   }
// }
//
// class Boxed extends StatefulWidget {
//   final ValueChanged<String> onSubmit;
//
//   Boxed(this.onSubmit);
//
//   @override
//   _BoxedState createState() => _BoxedState();
// }
//
// class _BoxedState extends State<Boxed> {
//   final _pinPutController = TextEditingController();
//   final _pinPutFocusNode = FocusNode();
//
//   @override
//   void initState() {
//     print('HEHE');
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _pinPutController.dispose();
//     _pinPutFocusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final BoxDecoration pinPutDecoration = BoxDecoration(
//       color: const Color.fromRGBO(119, 125, 226, 1),
//       borderRadius: BorderRadius.circular(5.0),
//     );
//
//     return Center(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(3.0),
//           border: Border.all(color: Colors.white),
//         ),
//         margin: const EdgeInsets.all(20.0),
//         padding: const EdgeInsets.all(20.0),
//         child: PinPut(
//           showCursor: true,
//           length: 5,
//           preFilledWidget: FlutterLogo(),
//           textStyle: const TextStyle(fontSize: 25.0, color: Colors.white),
//           pinWidth: 50.0,
//           pinHeight: 50.0,
//           onSubmit: widget.onSubmit,
//           focusNode: _pinPutFocusNode,
//           controller: _pinPutController,
//           submittedFieldDecoration: pinPutDecoration,
//           selectedFieldDecoration: pinPutDecoration.copyWith(color: Colors.white),
//           followingFieldDecoration: pinPutDecoration,
//         ),
//       ),
//     );
//   }
// }
//
// class DarkRounded extends StatefulWidget {
//   final ValueChanged<String> onSubmit;
//
//   DarkRounded(this.onSubmit);
//
//   @override
//   _DarkRoundedState createState() => _DarkRoundedState();
// }
//
// class _DarkRoundedState extends State<DarkRounded> {
//   final _pinPutController = TextEditingController();
//   final _pinPutFocusNode = FocusNode();
//
//   @override
//   void dispose() {
//     _pinPutController.dispose();
//     _pinPutFocusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final BoxDecoration pinPutDecoration = BoxDecoration(
//       color: const Color.fromRGBO(25, 21, 99, 1),
//       borderRadius: BorderRadius.circular(20.0),
//     );
//     return Padding(
//       padding: const EdgeInsets.all(30.0),
//       child: PinPut(
//         pinWidth: 65.0,
//         pinHeight: 65.0,
//         showCursor: true,
//         length: 4,
//         focusNode: _pinPutFocusNode,
//         controller: _pinPutController,
//         onSubmit: widget.onSubmit,
//         submittedFieldDecoration: pinPutDecoration,
//         selectedFieldDecoration: pinPutDecoration,
//         followingFieldDecoration: pinPutDecoration,
//         pinAnimationType: PinAnimationType.scale,
//         textStyle: const TextStyle(color: Colors.white, fontSize: 20.0),
//       ),
//     );
//   }
// }
//
// class SelectedBorder extends StatefulWidget {
//   final ValueChanged<String> onSubmit;
//
//   SelectedBorder(this.onSubmit);
//
//   @override
//   _SelectedBorderState createState() => _SelectedBorderState();
// }
//
// class _SelectedBorderState extends State<SelectedBorder> {
//   final _pinPutController = TextEditingController();
//   final _pinPutFocusNode = FocusNode();
//
//   @override
//   void dispose() {
//     _pinPutController.dispose();
//     _pinPutFocusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final BoxDecoration pinPutDecoration = BoxDecoration(
//       color: const Color.fromRGBO(235, 236, 237, 1),
//       borderRadius: BorderRadius.circular(5.0),
//     );
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(30.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           PinPut(
//             useNativeKeyboard: false,
//             showCursor: true,
//             length: 5,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             textStyle: const TextStyle(fontSize: 25.0, color: Colors.black),
//             pinWidth: 45.0,
//             pinHeight: 55.0,
//             onSubmit: widget.onSubmit,
//             focusNode: _pinPutFocusNode,
//             controller: _pinPutController,
//             submittedFieldDecoration: pinPutDecoration,
//             selectedFieldDecoration: pinPutDecoration.copyWith(
//               color: Colors.white,
//               border: Border.all(
//                 width: 2,
//                 color: const Color.fromRGBO(160, 215, 220, 1),
//               ),
//             ),
//             followingFieldDecoration: pinPutDecoration,
//             pinAnimationType: PinAnimationType.scale,
//           ),
//           SizedBox(height: 30),
//           GridView.count(
//             crossAxisCount: 3,
//             shrinkWrap: true,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//             padding: const EdgeInsets.all(30),
//             physics: NeverScrollableScrollPhysics(),
//             children: [
//               ...[1, 2, 3, 4, 5, 6, 7, 8, 9, 0].map((e) {
//                 return RoundedButton(
//                   title: '$e',
//                   onTap: () {
//                     if (_pinPutController.text.length >= 5) return;
//
//                     _pinPutController.text = '${_pinPutController.text}$e';
//                   },
//                 );
//               }),
//               RoundedButton(
//                 title: '⌫',
//                 onTap: () {
//                   if (_pinPutController.text.isNotEmpty) {
//                     _pinPutController.text = _pinPutController.text.substring(0, _pinPutController.text.length - 1);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class AnimatedBorders extends StatefulWidget {
//   final ValueChanged<String> onSubmit;
//
//   AnimatedBorders(this.onSubmit);
//
//   @override
//   _AnimatedBordersState createState() => _AnimatedBordersState();
// }
//
// class _AnimatedBordersState extends State<AnimatedBorders> {
//   final _pinPutController = TextEditingController();
//   final _pinPutFocusNode = FocusNode();
//
//   @override
//   void dispose() {
//     _pinPutController.dispose();
//     _pinPutFocusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final BoxDecoration pinPutDecoration = BoxDecoration(
//       border: Border.all(color: Colors.deepPurpleAccent),
//       borderRadius: BorderRadius.circular(15.0),
//     );
//
//     return Padding(
//       padding: const EdgeInsets.all(30.0),
//       child: PinPut(
//         length: 5,
//         pinHeight: 40,
//         pinWidth: 40,
//         showCursor: true,
//         onSubmit: widget.onSubmit,
//         focusNode: _pinPutFocusNode,
//         controller: _pinPutController,
//         submittedFieldDecoration: pinPutDecoration.copyWith(
//           borderRadius: BorderRadius.circular(20.0),
//         ),
//         selectedFieldDecoration: pinPutDecoration,
//         followingFieldDecoration: pinPutDecoration.copyWith(
//           borderRadius: BorderRadius.circular(5.0),
//           border: Border.all(
//             color: Colors.deepPurpleAccent.withOpacity(.5),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class RoundedButton extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;
//
//   RoundedButton({this.title, this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: const Color.fromRGBO(25, 21, 99, 1),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           '$title',
//           style: TextStyle(fontSize: 20, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }
