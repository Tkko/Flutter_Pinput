import 'package:flutter/material.dart';
import 'package:pinput/pin_put.dart';

void main() => runApp(PinPutApp());

class PinPutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        tabBarTheme: TabBarTheme(
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      home: PinPutGallery(),
    );
  }
}

class PinPutGallery extends StatefulWidget {
  @override
  PinPutGalleryState createState() => PinPutGalleryState();
}

class PinPutGalleryState extends State<PinPutGallery> with SingleTickerProviderStateMixin {
  TabController _tabController;

  final List<Color> _bgColors = [
    Colors.white,
    Colors.white,
    const Color.fromRGBO(43, 36, 198, 1),
    Colors.white,
    const Color.fromRGBO(75, 83, 214, 1),
    const Color.fromRGBO(43, 46, 66, 1),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _bgColors.length, vsync: this);
    _tabController.addListener(() {
      FocusScope.of(context).unfocus();
      setState(() {});
    });
  }

  final focusNode = FocusNode();

  final controller = TextEditingController();

  bool b = false;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromRGBO(114, 178, 238, 1);
    const fillColor = Color.fromRGBO(222, 231, 240, .57);
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: PinPut(
            // textDirection: TextDirection.rtl,
            separator: SizedBox(width: 8),
            mainAxisAlignment: MainAxisAlignment.center,
            pinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(
              height: 68,
              width: 64,
              decoration: defaultPinTheme.decoration.copyWith(
                border: Border.all(color: borderColor),
              ),
            ),
          ),
        ),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     titleSpacing: 0,
    //     title: TabBar(
    //       isScrollable: true,
    //       controller: _tabController,
    //       tabs: _pinPuts.map((e) {
    //         return Tab(
    //           text: e.runtimeType.toString(),
    //         );
    //       }).toList(),
    //     ),
    //   ),
    //   body: AnimatedBuilder(
    //     animation: _tabController.animation,
    //     builder: (BuildContext context, Widget child) {
    //       final anim = _tabController.animation.value;
    //       final Color color = Color.lerp(
    //         _bgColors[anim.floor()],
    //         _bgColors[anim.ceil()],
    //         anim - anim.floor(),
    //       );
    //       return Container(
    //         color: color,
    //         child: TabBarView(
    //           controller: _tabController,
    //           children: [
    //             Column(
    //               children: [
    //                 Padding(
    //                   padding: const EdgeInsets.all(30.0),
    //                   child: PinPut(),
    //                 ),
    //                 TextButton(
    //                   onPressed: () {
    //                     setState(() => b = !b);
    //                   },
    //                   child: Text('$b'),
    //                 ),
    //               ],
    //             ),
    //
    //             // PurePinPut(_showSnackBar),
    //             SelectedBorder(_showSnackBar),
    //             DarkRounded(_showSnackBar),
    //             AnimatedBorders(_showSnackBar),
    //             Boxed(_showSnackBar),
    //             RoundedCorners(_showSnackBar),
    //           ],
    //         ),
    //       );
    //     },
    //   ),
    // );
  }

  Widget get _bottomAppBar {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // TextButton(
          //   onPressed: () => _pinPutFocusNode.requestFocus(),
          //   child: const Text('Focus'),
          // ),
          // TextButton(
          //   onPressed: () => _pinPutFocusNode.unfocus(),
          //   child: const Text('Unfocus'),
          // ),
          // TextButton(
          //   onPressed: () => _pinPutController.text = '',
          //   child: const Text('Clear All'),
          // ),
          // TextButton(
          //   child: Text('Paste'),
          //   onPressed: () => _pinPutController.text = '234',
          // ),
        ],
      ),
    );
  }

  void _showSnackBar(String pin) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Container(
        height: 80.0,
        child: Center(
          child: Text(
            'Pin Submitted. Value: $pin',
            style: const TextStyle(fontSize: 25.0),
          ),
        ),
      ),
      backgroundColor: Colors.deepPurpleAccent,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
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
