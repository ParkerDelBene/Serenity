import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity/client/data/communication/serenityclient_user.dart';
import 'package:serenity/client/globals.dart';

class TextChannelMessage extends StatelessWidget {
  const TextChannelMessage(this.user, this.message, {super.key});

  factory TextChannelMessage.fromJson(
      Map<String, dynamic> json, Map<String, dynamic> userList) {
    SerenityClientUser user;

    if (userList.containsKey(json["user"])) {
      user = userList[json["user"]];
    } else {
      user = SerenityClientUser("", "Deleted", Uint8List(0), Uint8List(0));
    }

    return TextChannelMessage(user, json["message"]);
  }

  final String message;
  final SerenityClientUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        user.userIcon,
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
