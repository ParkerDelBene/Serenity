import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/widget_serenity_image_icon.dart';
import 'package:serenity/server/class_serenity_user.dart';

class TextChannelMessage extends StatelessWidget {
  const TextChannelMessage(this.user, this.message, {super.key});

  factory TextChannelMessage.fromJson(
      Map<String, dynamic> json, Map<String, dynamic> userList) {
    SerenityUser user;

    if (userList.containsKey(json["user"])) {
      user = userList[json["user"]];
    } else {
      user = SerenityUser("", "Deleted", Uint8List(0), Uint8List(0));
    }

    return TextChannelMessage(user, json["message"]);
  }

  final String message;
  final SerenityUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SerenityImageIcon(
            user.userName, user.userIcon.isEmpty ? null : user.userIcon, 50),
        SizedBox(
          width: 10,
        ),
        Text(
          message,
          style: TextStyle(color: textColor),
        )
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "user": user.userID,
    };
  }
}
