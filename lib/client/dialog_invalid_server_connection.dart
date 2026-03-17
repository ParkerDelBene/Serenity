import 'package:flutter/material.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/view_serenity_server.dart';

class InvalidServerConnection extends StatelessWidget {
  const InvalidServerConnection(this.server, {super.key});

  final SerenityServer server;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${server.serverConfig.serverName} was not available",
              style: channelTextStyle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    /// Then pop back to the dashboard
                    if (context.mounted) {
                      Navigator.popUntil(
                          context, (route) => route.settings.name == "/");
                    }
                  },
                  child: Text("BACK"),
                ),
                TextButton(
                  onPressed: () async {
                    /// Attempt a Reconnect
                    if (!await server.connection.connect()) {
                      if (context.mounted) {
                        failedReconnect(context);
                      }
                    } else {
                      /// Reconnection Suceeded
                      activeServer.value = server;
                      if (context.mounted) {
                        Navigator.popUntil(
                            context, (route) => route.settings.name == "/");
                      }
                    }
                  },
                  child: Text("RECONNECT"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> failedReconnect(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: primaryColor,
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                "Connection Failed",
                textAlign: TextAlign.center,
                style: channelTextStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}
