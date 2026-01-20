import 'package:flutter/material.dart';
import 'package:serenity/client/addserver_view.dart';
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
      Building the ServerList
    */
    widgetList = [];
    widgetList += serverList;
    widgetList.add(addServer());

    /*
      Branch on the Aspect Ratio
    */
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxHeight > constraints.maxWidth) {
        return verticalView();
      } else {
        return horizontalView();
      }
    });
  }

  Widget verticalView() {
    return Container(
      width: viewSize.width,
      height: viewSize.height,
      color: Colors.purple,
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

  Widget addServer() {
    return Container(
      height: 100,
      width: 100,
      color: Colors.amber,
      child: InkWell(
        onHover: (value) => {},
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
