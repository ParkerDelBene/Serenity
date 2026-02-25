import 'package:flutter/material.dart';
import 'package:serenity/client/globals.dart';

class ViewDivider extends StatelessWidget {
  const ViewDivider(this.vertical, {super.key});

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    double thickness = maxScreenWidth * .005;

    if (vertical) {
      return VerticalDivider(
        color: highlightColor,
        width: thickness,
      );
    } else {
      return Divider(
        color: highlightColor,
        height: thickness,
      );
    }
  }
}
