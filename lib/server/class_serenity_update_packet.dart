import 'dart:typed_data';
import 'package:serenity/server/class_serenity_user.dart';

class SerenityUpdatePacket {
  const SerenityUpdatePacket(this.serverName,this.serverIcon,this.serverBanner,this.userList,this.textChannels,this.voiceChannels);

  final String serverName;
  final Uint8List serverIcon;
  final Uint8List serverBanner;
  final List<SerenityUser> userList;
  final List<String> textChannels;
  final List<String> voiceChannels;

  Map<String, dynamic> toMap() {
    return {
      "serverName": serverName,
      "serverIcon": serverIcon,
      "serverBanner": serverBanner,
      "userList": userList,
      "textChannels": textChannels,
      "voiceChannels": voiceChannels,
    };
  }

  SerenityUpdatePacket.fromMap(Map<String, dynamic> map)
      : serverName = map['serverName'],
        serverIcon = map['serverIcon'],
        serverBanner = map['serverBanner'],
        userList = map['userList'],
        textChannels = List<String>.from(map['textChannels']),
        voiceChannels = List<String>.from(map['voiceChannels']);
}
