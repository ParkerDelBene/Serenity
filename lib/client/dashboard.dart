import 'dart:math';

import 'package:flutter/material.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/serverlist_view.dart';

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
  Widget build(BuildContext context) {
    dashboardSize = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        height: dashboardSize.height,
        width: dashboardSize.width,
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            SizedBox(
              width: max(maxScreenWidth * .1, dashboardSize.width * .1),
              child: ServerlistView(),
            )
          ],
        ),
      ),
    );
  }
}
