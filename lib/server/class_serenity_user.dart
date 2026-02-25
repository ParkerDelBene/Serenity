import 'dart:convert';
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

  SerenityUser.fromMap(Map<String, dynamic> json)
      : userID = json["userID"],
        userName = json["userName"],
        userIcon = Uint8List.fromList(List<int>.from(json["userIcon"])),
        userBanner = Uint8List.fromList(List<int>.from(json["userBanner"]));

  final String userID;
  final String userName;
  final Uint8List userIcon;
  final Uint8List userBanner;

  /// Name: userListFromMap
  ///
  /// Date Last Updated: 02/18/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function takes in a List of json encoded SerenityUsers,
  /// decodes them, and returns them as a List of SerenityUsers
  static List<SerenityUser> userListFromMap(List<dynamic> jsonList) {
    List<SerenityUser> userList = [];

    /// For each Json String in the list, decode it and call SerenityUser.fromMap
    for (String json in jsonList) {
      Map<String, dynamic> userJson = jsonDecode(json);
      userList.add(SerenityUser.fromMap(userJson));
    }

    return userList;
  }

  Map<String, dynamic> toJson() {
    return {
      "userID": userID,
      "userName": userName,
      "userIcon": userIcon.toList(),
      "userBanner": userBanner.toList()
    };
  }
}
