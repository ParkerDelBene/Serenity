import 'dart:typed_data';

/// Name: SerenityUser
///
/// Last Updater: Parker DelBene
///
/// Date Last Updated: 02/12/26
///
/// Function: This class contains all of the data for a user of the server
///
/// userID = The unique ID of the user
///
/// userName = The name of the user
///
/// userIcon = The Byte Data of the user's icon stored as a Uint8List
///
/// userBanner = The Byte data of the user's banner stored as a Uint8List
class SerenityUser {
  const SerenityUser(
      this.userID, this.userName, this.userIcon, this.userBanner);

  final String userID;
  final String userName;
  final Uint8List userIcon;
  final Uint8List userBanner;

  SerenityUser.fromMap(Map<String, dynamic> json)
      : userID = json["userID"],
        userName = json["userName"],
        userIcon = json["userIcon"],
        userBanner = json["userBanner"];

  Map<String, dynamic> toMap() {
    return {
      "userID": userID,
      "userName": userName,
      "userIcon": userIcon,
      "userBanner": userBanner
    };
  }
}
