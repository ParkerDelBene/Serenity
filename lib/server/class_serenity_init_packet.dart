import 'dart:typed_data';

import 'package:serenity/server/class_serenity_user.dart';

class SerenityInitPacket {
  const SerenityInitPacket(
      this.serverName,
      this.serverIcon,
      this.serverBanner,
      this.userID,
      this.userPAT,
      this.userList,
      this.textChannels,
      this.voiceChannels);

  final String serverName;
  final Uint8List serverIcon;
  final Uint8List serverBanner;
  final String userID;
  final String userPAT;
  final List<SerenityUser> userList;
  final List<String> textChannels;
  final List<String> voiceChannels;

  Map<String, dynamic> toMap() {
    return {
      "serverName": serverName,
      "serverIcon": serverIcon,
      "serverBanner": serverBanner,
      "userID": userID,
      "userPAT": userPAT,
      "userList": userList,
      "textChannels": textChannels,
      "voiceChannels": voiceChannels,
    };
  }

  SerenityInitPacket.fromMap(Map<String, dynamic> map)
      : serverName = map['serverName'],
        serverIcon = map['serverIcon'],
        serverBanner = map['serverBanner'],
        userID = map['userID'],
        userPAT = map['userPAT'],
        userList = map['userList'],
        textChannels = List<String>.from(map['textChannels']),
        voiceChannels = List<String>.from(map['voiceChannels']);
}
