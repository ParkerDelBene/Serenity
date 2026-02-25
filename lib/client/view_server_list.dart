import 'package:flutter/material.dart';
import 'package:serenity/client/route_addserver.dart';
import 'globals.dart';

class ServerlistView extends StatefulWidget {
  const ServerlistView({super.key});

  @override
  State<ServerlistView> createState() => _ServerlistViewState();
}

class _ServerlistViewState extends State<ServerlistView> {
  Size viewSize = Size(0, 0);
  List<Widget> widgetList = [];

  @override
  Widget build(BuildContext context) {
    viewSize = MediaQuery.sizeOf(context);

    /*
      Branch on the Aspect Ratio
    */
    return Container(
      width: viewSize.width,
      height: viewSize.height,
      color: primaryColor,
      child: SingleChildScrollView(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints boxconstraints) {
          double maxWidth = boxconstraints.maxWidth;
          /*
            Building the ServerList
          */
          widgetList = [];

          /*
            For each server, generate the icon, adding a padding box above it.
          */
          for (final server in serverList) {
            widgetList.add(SizedBox(
              height: maxWidth * serverIconPaddingRatio,
            ));

            InkWell temp = InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                activeServer.value = server;
              },
              child: server.toIcon(maxWidth),
            );
            widgetList.add(temp);
          }

          /*
            Then, add the add server widget with a padding box
          */
          widgetList.add(SizedBox(
            height: maxWidth * serverIconPaddingRatio,
          ));
          widgetList.add(addServer(maxWidth));

          return Column(
              mainAxisAlignment: MainAxisAlignment.start, children: widgetList);
        }),
      ),
    );
  }

  Widget verticalView() {
    return Container(
      width: viewSize.width,
      height: viewSize.height,
      color: Colors.blueGrey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widgetList,
        ),
      ),
    );
  }

  Widget horizontalView() {
    return Container(
      width: viewSize.width,
      height: viewSize.height,
      color: Colors.purple,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: widgetList,
      ),
    );
  }

  Widget addServer(double maxWidth) {
    return Container(
      height: maxWidth * serverIconRatio,
      width: maxWidth * serverIconRatio,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AddserverView()));
          //Rebuild the serverlist on return
          if (mounted) {
            setState(() {});
          }
        },
        child: Center(
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
