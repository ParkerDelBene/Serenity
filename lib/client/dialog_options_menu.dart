import 'package:flutter/material.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/widget_clickable_widget.dart';
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
  Widget build(BuildContext context) {
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
                        () {},
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
                Expanded(child: Container())
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
            () => Navigator.pop(context),
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
}
