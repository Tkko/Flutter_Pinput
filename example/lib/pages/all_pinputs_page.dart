import 'package:flutter/material.dart';

class AllPinputs extends StatefulWidget {
  final List<Widget> pinPuts;
  final List<List<Color>> colors;

  AllPinputs(this.pinPuts, this.colors);

  @override
  _AllPinputsState createState() => _AllPinputsState();

  @override
  String toStringShort() => 'All';
}

class _AllPinputsState extends State<AllPinputs>
    with AutomaticKeepAliveClientMixin {
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
