import 'package:flutter/material.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/view_server_list.dart';
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
      body: Container(
        height: dashboardSize.height,
        width: dashboardSize.width,
        decoration: BoxDecoration(color: primaryColor),
        child: Row(
          children: [
            SizedBox(
              width: maxScreenWidth * .04,
              child: ServerlistView(),
            ),
            ViewDivider(true),
            SizedBox(
              width: 1,
            ),
            Expanded(
                child: SizedBox(
              height: dashboardSize.height,
              child: activeServer.value ?? Container(),
            ))
          ],
        ),
      ),
    );
  }

  void _activeServerListener() {
    if (mounted) {
      setState(() {});
    }
  }
}
