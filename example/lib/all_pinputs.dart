import 'package:flutter/material.dart';

class AllPinPuts extends StatefulWidget {
  final List<Widget> pinPuts;
  final List<List<Color>> colors;

  AllPinPuts(this.pinPuts, this.colors);

  @override
  _AllPinPutsState createState() => _AllPinPutsState();

  @override
  String toStringShort() => 'All';
}

class _AllPinPutsState extends State<AllPinPuts> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          ...widget.pinPuts.asMap().entries.map((item) {
            final fromColor = widget.colors[item.key + 1].first;
            return Container(
              width: double.maxFinite,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: fromColor.withOpacity(.4)),
              child: item.value,
            );
          })
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
