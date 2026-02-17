import 'package:flutter/material.dart';

import 'globals.dart';

class ServerIcon extends StatelessWidget {
  const ServerIcon(this.serverName, this.serverImage, this.maxWidth,
      {super.key});

  final String serverName;
  final Image? serverImage;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (serverImage == null) {
      List<String> tempList = serverName.split(" ");
      String temp = "";
      for (String initial in tempList) {
        temp += initial[0].toUpperCase();
      }

      return Container(
        height: maxWidth * serverIconRatio,
        width: maxWidth * serverIconRatio,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
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
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber,
        ),
      );
    }
  }
}
