import 'dart:typed_data';
import 'package:serenity/client/widget_serenity_image_icon.dart';
import 'package:serenity/server/class_serenity_user.dart';

class SerenityClientUser {
  SerenityClientUser(
      this.userID, this.userName, Uint8List userIcon, this.userBanner)
      : userIcon = SerenityImageIcon(userName, userIcon);

  SerenityClientUser.fromSerenityUSer(SerenityUser user)
      : userID = user.userID,
        userName = user.userName,
        userIcon = SerenityImageIcon(user.userName, user.userIcon),
        userBanner = user.userBanner;

  final String userID;
  String userName;
  SerenityImageIcon userIcon;
  Uint8List userBanner;

  bool isUserEqual(SerenityUser user) {
    if (userID != user.userID) {
      return false;
    }

    if (userName != user.userName) {
      return false;
    }

    if (userIcon.iconImage.value != user.userIcon) {
      return false;
    }

    if (userBanner != user.userBanner) {
      return false;
    }

    return true;
  }
}
