import 'dart:io';
import 'package:serenity/server/class_serenity_user.dart';

class TextChannel {
  TextChannel(this.uuid, this.name, this.saveCallback);

  String uuid;
  String name;
  Function(String)? saveCallback;

  Map<SerenityUser, WebSocket> users = {};

  void addUser(SerenityUser user, WebSocket socket) {
    users[user] = socket;
  }

  void removeUser(SerenityUser user) {
    users.remove(user);
  }

  /// [json] is the original data received by the server
  ///
  /// [message] is the actual message contained in the [SerenityPacket]
  ///
  /// This lets the function send out the original json without needing to serialize
  /// it and also pushed the message to the callback function if it has been set.
  /// 
  /// The [saveCallback] function should link to a function that uses the database to
  /// save chat messages.
  void sendMessage(String json, String message) {
    users.forEach((user, websocket) => websocket.add(json));

    saveCallback?.call(message);
  }
}
