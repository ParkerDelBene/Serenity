import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'globals.dart';

class SerenityServerIcon extends StatelessWidget {
  const SerenityServerIcon(this.iconName, this.iconImage, this.maxWidth,
      {super.key});

  final String iconName;
  final Uint8List? iconImage;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (iconImage == null) {
      List<String> tempList = iconName.split(" ");
      String temp = "";
      for (String initial in tempList) {
        temp += initial[0].toUpperCase();
      }

      return Container(
        height: maxWidth * serverIconRatio,
        width: maxWidth * serverIconRatio,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: secondaryColor),
        child: Center(
            child: Text(
          temp,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        )),
      );
    } else {
      return Container(
        height: maxWidth * serverIconRatio,
        width: maxWidth * serverIconRatio,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: secondaryColor,
        ),
        child: Image.memory(
          iconImage!,
          fit: BoxFit.cover,
        ),
      );
    }
  }
}
