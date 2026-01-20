import 'package:flutter/material.dart';
import 'package:serenity/client/connection.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/serenity_server.dart';

class AddserverView extends StatelessWidget {
  AddserverView({super.key});

  final TextEditingController URIController = TextEditingController();
  final TextEditingController PortController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size viewSize = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Center(
        child: SizedBox(
          height: viewSize.height,
          width: viewSize.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: URIController,
                textAlign: TextAlign.center,
              ),
              TextField(
                controller: PortController,
                textAlign: TextAlign.center,
              ),
              TextField(
                controller: PasswordController,
                textAlign: TextAlign.center,
              ),
              TextButton(
                  onPressed: () async {
                    /*
                        Initialize the connection
                      */
                    Connection newConnection =
                        Connection(URIController.text, PortController.text);

                    if (!await newConnection.initialize()) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  addServerFailed(context)));
                    } else {
                      SerenityServer newServer = SerenityServer(
                          URIController.text,
                          PortController.text,
                          '',
                          '',
                          'Test',
                          newConnection);
                      serverList.add(newServer);
                      Navigator.pop(context);
                    }
                  },
                  child: FittedBox(
                    child: Text('Connect'),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget addServerFailed(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            "Connection Failed",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
