import 'package:flutter/material.dart';
import 'package:serenity/client/globals.dart';

class ViewDivider extends StatelessWidget {
  const ViewDivider(this.vertical, {super.key});

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    double thickness = maxScreenWidth * .00005;
    double size = thickness + 5;

    if (vertical) {
      return VerticalDivider(
        color: highlightColor,
        thickness: thickness,
        width: size,
      );
    } else {
      return Divider(
        color: highlightColor,
        thickness: thickness,
        height: size,
        indent: 10,
        endIndent: 10,
      );
    }
  }
}
