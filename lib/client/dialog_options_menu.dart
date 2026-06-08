import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/widget_clickable_widget.dart';
import 'package:serenity/client/widget_serenity_image_icon.dart';
import 'package:serenity/client/widget_view_divider.dart';

/// Name: OptionsMenu
///
/// Date Last Updated: 02/23/26
///
/// Last Updater: Parker DelBene
///
/// Function: This page will be the single page to show all of the various
/// option menus to the user.
class OptionsMenu extends StatefulWidget {
  const OptionsMenu({super.key});
  static const List<String> _settingsMenus = ["User", "UI", "Voice"];

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  @override
  void initState() {
    super.initState();

    optionMenuWidgetBuilder();
  }

  /// A list of the widget builders, w
  List<Widget Function()> optionMenuWidgetBuilders = [];
  int activeOptionMenuBuilder = 0;

  /// Setting up a temporary user variables that we can edit and then save over when we save from this menu.
  String newUserName = localUser.userName;
  SerenityImageIcon newUserIcon = SerenityImageIcon(
    localUser.userName,
    localUser.userIcon.iconImage.value,
  );
  Uint8List newUserBanner = localUser.userBanner;

  @override
  Widget build(BuildContext context) {
    /// Setting up variables to use while building the option menu
    Size size = MediaQuery.sizeOf(context);
    double dialogWidth = size.width * .5;

    return Container(
      width: dialogWidth,
      decoration: BoxDecoration(
          color: primaryColor, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                /// Menu for selecting the options
                SizedBox(
                  width: dialogWidth * .25,
                  child: ListView.separated(
                    itemCount: OptionsMenu._settingsMenus.length,
                    separatorBuilder: (BuildContext context, int i) {
                      return Divider(
                        color: Colors.transparent,
                        height: 5,
                      );
                    },
                    itemBuilder: (context, index) {
                      return ClickableWidget(
                        /// If the index is within the length of the menuWidgets, then we switch the
                        /// Active menu, else do nothing.
                        /// This is kind of redundant in production but whatever.
                        () => index < optionMenuWidgetBuilders.length
                            ? activeOptionMenuBuilder = index
                            : activeOptionMenuBuilder,
                        Text(
                          OptionsMenu._settingsMenus[index],
                          style: channelTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                ViewDivider(true),

                /// Area for putting the option view
                Expanded(child: optionMenuWidgetBuilders[0]())
              ],
            ),
          ),

          /// Buttons for Back and Save
          bottomNavButtons(),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  /// Name: optionMenuWidgetBuilder
  ///
  /// Date Last Updated: 04/21/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function is a wrapper that initializes the optionMenuWidgets list with
  /// the various menus. It is called within the initState.
  void optionMenuWidgetBuilder() {
    optionMenuWidgetBuilders.add(userConfigWidget);
  }

  /// Widget for building the bottom buttons in a row
  Widget bottomNavButtons() {
    double widthSpacing = 25;

    return Row(
      children: [
        SizedBox(width: widthSpacing),
        bottomNavButtonWidget(
          ClickableWidget(
            () => Navigator.pop(context),
            Text(
              "Close",
              style: channelTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(width: widthSpacing),
        bottomNavButtonWidget(
          ClickableWidget(
            () {
              saveSettings();
              Navigator.pop(context);
            },
            Text(
              "Save",
              style: channelTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(width: widthSpacing),
      ],
    );
  }

  /// Name: saveSettings
  ///
  /// Date Last Updated: 05/20/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function is a wrapper that calls the functions for saving the various configs.
  void saveSettings() {
    saveUserSettings();
  }

  /// Name: saveUserSettings
  ///
  /// Date Last Updated: 05/20/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function creates a new user, sets the localUser to the new one, and then saves.
  void saveUserSettings() {
    /// Update the LocalUser
    localUser.userName = newUserName;
    localUser.userBanner = newUserBanner;
    localUser.userIcon.iconImage.value = newUserIcon.iconImage.value;

    /// Get the localuser Directory and the various files
    Directory localUserDirectory =
        Directory("${applicationDirectory.path}/user");
    File userNameFile = File("${localUserDirectory.path}/userName");
    File userBannerFile = File("${localUserDirectory.path}/userBanner.jpg");
    File userIconFile = File("${localUserDirectory.path}/userIcon.jpg");

    /// Save the Files.
    userNameFile.writeAsStringSync(localUser.userName);
    userBannerFile.writeAsBytesSync(localUser.userBanner);
    userIconFile.writeAsBytesSync(localUser.userIcon.iconImage.value);
  }

  /// Widget for decorating the bottom buttons
  Widget bottomNavButtonWidget(Widget child) {
    return Expanded(
      child: Container(
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: child),
    );
  }

  /// Name: userConfigWidget
  ///
  /// Date Last Updated: 04/21/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This widget displays the options for changing the local user settings
  Widget userConfigWidget() {
    /// Setting up the username controller and populating it with the current username
    TextEditingController userNameController = TextEditingController();
    userNameController.text = localUser.userName;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          spacing: 20,
          children: [
            SizedBox(
              height: 1,
            ),
            Stack(
              children: [
                /// The section for clicking the banner widget.
                /// Lives underneath the rest of the profile selection
                Positioned.fill(
                  child: ClickableWidget(() async {
                    FilePickerResult? result =
                        await FilePicker.pickFiles(type: FileType.image);

                    if (result != null) {
                      File file = File(result.files.single.path!);
                      newUserBanner = file.readAsBytesSync();

                      if (mounted) {
                        setState(() {});
                      }
                    }
                  },
                      newUserBanner.isEmpty
                          ? Container()
                          : Image.memory(newUserBanner)),
                ),
                Row(
                  spacing: 30,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 1,
                    ),

                    /// CLickable Widget to select a new userIcon
                    ClickableWidget(
                      () async {
                        FilePickerResult? result =
                            await FilePicker.pickFiles(type: FileType.image);

                        if (result != null) {
                          File file = File(result.files.single.path!);
                          newUserIcon.iconImage.value = file.readAsBytesSync();

                          if (mounted) {
                            setState(() {});
                          }
                        }
                      },
                      SizedBox(
                          width: constraints.maxWidth * .5, child: newUserIcon),
                    ),

                    /// Textfield to modify the userName
                    Expanded(
                      child: TextField(
                        controller: userNameController,
                        style: channelTextStyle,
                        onEditingComplete: () {
                          newUserName = userNameController.text;
                        },
                        onChanged: (value) {
                          newUserName = value;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 1,
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
