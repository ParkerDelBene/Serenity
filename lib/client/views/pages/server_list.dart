import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serenity/client/views/popups/addserver.dart';
import 'package:serenity/client/views/popups/invalid_server_connection.dart';
import 'package:serenity/client/views/pages/serenity_server.dart';
import 'package:serenity/client/views/widgets/clickable_widget.dart';
import 'package:serenity/client/views/widgets/serenity_image_icon.dart';
import '../../globals.dart';

class ServerlistView extends StatefulWidget {
  const ServerlistView({super.key});

  @override
  State<ServerlistView> createState() => _ServerlistViewState();
}

class _ServerlistViewState extends State<ServerlistView> {
  @override
  Widget build(BuildContext context) {
    /*
      Branch on the Aspect Ratio
    */
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.separated(
                itemCount: serverList.length + 1,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.transparent,
                ),
                itemBuilder: (context, index) {
                  if (index == serverList.length) {
                    return GestureDetector(
                      onTap: () => addServer(context),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: SerenityImageIcon(
                          "+",
                          Uint8List(0),
                        ),
                      ),
                    );
                  }
                  return ClickableWidget(
                      () => serverIconClickHandler(serverList[index], context),
                      serverList[index].serverIcon);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Name: serverIconClickHandler
  ///
  /// Date Last Updated: 03/02/26
  ///
  /// Last Updater: Parker DelBeneimport 'package:serenity/server/class_serenity_user.dart';
  ///
  /// Function: This function handles what happens when a serverIcon is clicked.
  Future<void> serverIconClickHandler(
      SerenityServer server, BuildContext context) async {
    /// If the server is connected, then set it as the active server
    if (server.connection.connected) {
      activeServer.value = server;
    } else {
      return showDialog(
          context: context,
          builder: (context) {
            return InvalidServerConnection(server);
          });
    }
  }

  Future<void> addServer(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AddserverView();
      },
    );
  }
}
