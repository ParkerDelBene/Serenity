import 'dart:convert';
import 'dart:typed_data';

import 'package:serenity/server/class_serenity_user.dart';

/// Name: SerenityInitPacket
///
/// Date Last Updated: 02/18/26
///
/// Last Updater: Parker DelBene
///
/// Function: This class packages all of the data that needs to be served to the
/// client the first time they connect.
///
/// Data:
/// servername, serverIcon, serverBanner, userID, userPAT, userList, textChannels
/// voiceChannels, saveContent
class SerenityInitPacket {
  const SerenityInitPacket(
    this.serverName,
    this.serverIcon,
    this.serverBanner,
    this.userID,
    this.userPAT,
    this.userList,
    this.textChannels,
    this.voiceChannels,
    this.saveContent,
  );

  final String serverName;
  final Uint8List serverIcon;
  final Uint8List serverBanner;
  final String userID;
  final String userPAT;
  final List<SerenityUser> userList;
  final List<String> textChannels;
  final List<String> voiceChannels;
  final bool saveContent;

  Map<String, dynamic> toMap() {
    /// create the List of user data
    List<String> jsonUserList = [];
    for (SerenityUser user in userList) {
      jsonUserList.add(jsonEncode(user.toMap()));
    }

    return {
      "serverName": serverName,
      "serverIcon": serverIcon,
      "serverBanner": serverBanner,
      "userID": userID,
      "userPAT": userPAT,
      "userList": jsonUserList,
      "textChannels": textChannels,
      "voiceChannels": voiceChannels,
      "saveContent": saveContent
    };
  }

  SerenityInitPacket.fromMap(Map<String, dynamic> map)
      : serverName = map['serverName'],
        serverIcon = map['serverIcon'],
        serverBanner = map['serverBanner'],
        userID = map['userID'],
        userPAT = map['userPAT'],
        userList = List<SerenityUser>.from(map['userList']),
        textChannels = List<String>.from(map['textChannels']),
        voiceChannels = List<String>.from(map['voiceChannels']),
        saveContent = map['saveContent'];
}
