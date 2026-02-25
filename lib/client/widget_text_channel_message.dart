import 'package:flutter/material.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/server/class_serenity_user.dart';

class TextChannelMessage extends StatelessWidget {
  const TextChannelMessage(this.user, this.message, {super.key});

  final String message;
  final SerenityUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.memory(user.userIcon),
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
}
