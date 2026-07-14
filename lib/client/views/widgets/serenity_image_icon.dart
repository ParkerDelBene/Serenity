import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../globals.dart';

class SerenityImageIcon extends StatefulWidget {
  SerenityImageIcon(this.iconName, Uint8List iconImageData, {super.key})
      : iconImage = ValueNotifier<Uint8List>(iconImageData);

  final String iconName;
  final ValueNotifier<Uint8List> iconImage;

  void setIconImage(Uint8List iconImage) {
    this.iconImage.value = iconImage;
  }

  @override
  State<SerenityImageIcon> createState() => _SerenityImageIconState();
}

class _SerenityImageIconState extends State<SerenityImageIcon> {
  @override
  void initState() {
    super.initState();

    /// Listen to the change in the icon image and update the state accordingly.
    widget.iconImage.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Build the container based on whether the icon image is empty.
    if (widget.iconImage.value.isEmpty) {
      List<String> tempList = widget.iconName.split(" ");
      String temp = "";
      for (String initial in tempList) {
        temp += initial[0].toUpperCase();
      }

      return Container(
        height: smallImageIconSize,
        width: smallImageIconSize,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: secondaryColor),
        child: Center(
            child: Text(
          temp,
          style: channelTextStyle,
        )),
      );
    } else {
      return Container(
        height: smallImageIconSize,
        width: smallImageIconSize,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: secondaryColor,
        ),
        child: Image.memory(
          widget.iconImage.value,
          fit: BoxFit.cover,
        ),
      );
    }
  }
}
