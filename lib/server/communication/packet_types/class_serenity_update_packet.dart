import 'dart:convert';
import 'dart:typed_data';
import 'package:serenity/server/class_serenity_user.dart';

/// Name: SerenityUpdatePacket
///
/// Date Last Updated: 02/18/26
///
/// Last Updater: Parker DelBene
///
/// Function: This packet bundles information the server might send to update the
/// client.
///
/// Possible Data:
///
/// serverName, serverIcon, serverBanner, userList, textChannels, voiceChannels,
/// saveContent
///
/// userList: After the first updatePacket sent on connection, this will only
/// contain new users coming into the server.
class SerenityUpdatePacket {
  const SerenityUpdatePacket(
      this.serverName,
      this.serverIcon,
      this.serverBanner,
      this.userList,
      this.textChannels,
      this.voiceChannels,
      this.saveContent);

  final String serverName;
  final Uint8List serverIcon;
  final Uint8List serverBanner;
  final List<SerenityUser> userList;
  final List<String> textChannels;
  final List<String> voiceChannels;
  final bool saveContent;

  Map<String, dynamic> toJson() {
    /// create the List of user data
    List<String> jsonUserList = [];
    for (SerenityUser user in userList) {
      jsonUserList.add(jsonEncode(user.toJson()));
    }

    return {
      "serverName": serverName,
      "serverIcon": serverIcon.toList(),
      "serverBanner": serverBanner.toList(),
      "userList": jsonUserList,
      "textChannels": textChannels,
      "voiceChannels": voiceChannels,
      "saveContent": saveContent,
    };
  }

  SerenityUpdatePacket.fromMap(Map<String, dynamic> map)
      : serverName = map['serverName'],
        serverIcon = Uint8List.fromList(List<int>.from(map['serverIcon'])),
        serverBanner = Uint8List.fromList(List<int>.from(map['serverBanner'])),
        userList = SerenityUser.userListFromMap(map["userList"]),
        textChannels = List<String>.from(map['textChannels']),
        voiceChannels = List<String>.from(map['voiceChannels']),
        saveContent = map["saveContent"];
}
