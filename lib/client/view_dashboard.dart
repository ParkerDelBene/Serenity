import 'package:flutter/material.dart';
import 'package:serenity/client/dialog_options_menu.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/view_server_list.dart';
import 'package:serenity/client/widget_clickable_widget.dart';
import 'package:serenity/client/widget_view_divider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  /*
    Getting the size of the viewport on every build
  */
  Size dashboardSize = Size(0, 0);

  @override
  void initState() {
    super.initState();

    activeServer.addListener(_activeServerListener);
  }

  @override
  Widget build(BuildContext context) {
    dashboardSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          SizedBox(
            height: dashboardSize.height,
            width: dashboardSize.width,
            child: Row(
              children: [
                SizedBox(
                  width: maxScreenWidth * .04,
                  child: ServerlistView(),
                ),
                ViewDivider(true),
                Expanded(
                    child: SizedBox(
                  height: dashboardSize.height,
                  child: activeServer.value ?? Container(),
                ))
              ],
            ),
          ),
          floatingUserMenu(),
        ],
      ),
    );
  }

  void _activeServerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget floatingUserMenu() {
    double width = maxScreenWidth * .15;
    double height = maxScreenHeight * .075;

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 20, bottom: 20),
        child: Container(
          decoration: BoxDecoration(
              color: secondaryColor, borderRadius: BorderRadius.circular(10)),
          width: width,
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ClickableWidget(() {}, localUser.userIcon),
              ClickableWidget(
                () {},
                Icon(
                  Icons.mic,
                  color: highlightColor,
                ),
              ),
              ClickableWidget(
                () {},
                Icon(
                  Icons.headphones,
                  color: highlightColor,
                ),
              ),
              ClickableWidget(
                () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: OptionsMenu(),
                        );
                      });
                },
                Icon(
                  Icons.settings,
                  color: highlightColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
