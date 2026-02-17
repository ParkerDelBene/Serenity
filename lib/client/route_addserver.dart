import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:serenity/client/class_connection.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/view_serenity_server.dart';
import 'package:serenity/client/view_text_channel.dart';
import 'package:serenity/server/class_serenity_config.dart';

class AddserverView extends StatelessWidget {
  AddserverView({super.key});

  final TextEditingController uriController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /*
    Initialize the variables for the server and userID and the variable to let
    the setup continue
  */
  String userID = "";
  late final SerenityConfig serverConfig;
  bool setupDone = false;

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
                controller: uriController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    hint: Text(
                  'URL',
                  textAlign: TextAlign.center,
                )),
              ),
              TextField(
                controller: portController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    hint: Text(
                  'PORT',
                  textAlign: TextAlign.center,
                )),
              ),
              TextField(
                controller: passwordController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    hint: Text(
                  'PASSWORD',
                  textAlign: TextAlign.center,
                )),
              ),
              TextButton(
                  onPressed: () async {
                    /*
                        Initialize the connection
                      */
                    Connection newConnection =
                        Connection(uriController.text, portController.text, "");

                    /*
                      If the Connection failed then push the serverFailed Page
                      Else, pull the first two mesasges from the server, which are the UUID
                      of the user, and then the ServerConfig
                    */
                    if (!await newConnection.initialize()) {
                      if (context.mounted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    addServerFailed(context)));
                      }
                    } else {
                      /*
                        Get the stream and then read the first few messages that will
                        initialize the Server Config and UUID
                      */
                      SerenityServer newServer =
                          await initServer(newConnection);

                      serverList.add(newServer);

                      if (context.mounted) {
                        Navigator.popUntil(
                            context, (route) => route.settings.name == "/");
                      }
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

  /*
    Name initServer

    Last Date Updated 01/22/26

    Last Updater: Parker DelBene

    Function: This function takes in the connection, and then initializes the
    server and spits out the serenity server
  */
  Future<SerenityServer> initServer(Connection newConnection) async {
    /*
      Init Variables for use
    */
    Map<String, TextChannel> textChannels = <String, TextChannel>{};

    // get the initial Connection messages from the server
    List<dynamic> initialConnectionMessages =
        await SerenityServer.initialConnectionSetup(newConnection);

    // Get the serverConfig and userID from the initial messages
    SerenityConfig serverConfig = initialConnectionMessages[0];
    String userID = initialConnectionMessages[1];

    /*
      Call to create the necessary Server Directories
    */
    List<Directory> directoryList =
        await createServerDirectory(serverConfig, userID, newConnection.uri);

    if (directoryList.isEmpty) {
      throw Exception("Could not create Server Directories");
    }

    /*
      Create the TextChannels
    */
    for (String channel in serverConfig.textChannels) {
      //Checks if the length is 4, if so it returns the chat directory
      //Else it pipes in null
      TextChannel newChannel = TextChannel(channel, !serverConfig.saveContent,
          directoryList.length == 4 ? directoryList[3] : null);

      textChannels.addAll({channel: newChannel});
    }

    /*
      Create the Serenity Server and then return it.
    */
    return SerenityServer(
        serverConfig.serverName,
        newConnection.uri,
        newConnection.port,
        userID,
        directoryList[0],
        directoryList[1],
        directoryList[2],
        serverConfig.saveContent == false ? directoryList[3] : null,
        serverConfig,
        textChannels,
        serverConfig.voiceChannels,
        newConnection);
  }

  ///Name: createServerDirectory
  ///
  ///Last Date Updated: 01/21/26
  ///
  ///Last Updater: Parker DelBene
  ///
  ///Function: create ther server file structure, populate the config file,
  ///    then populate the text channel files.
  ///
  ///Called by the initServer function
  ///
  ///Returns {Assets,Config,Users,Chat} directory list if saving locally
  ///
  ///Returns {Assets,Config,Users} directory list if not saving locally
  ///
  Future<List<Directory>> createServerDirectory(
      SerenityConfig config, String userID, String uri) async {
    List<Directory> returnedList = [];
    /*
      Declare Variables Used
    */
    Directory serversDirectory;
    Directory serverDirectory;
    Directory serverAssetsDirectory;
    Directory serverConfigDirectory;
    Directory serverUsersDirectory;
    Directory serverUserDirectory;
    Directory serverChatsDirectory;
    File serverConfig;
    File serverURI;
    File userIDFile;

    /*
      Create the directory structure for the server
    */
    try {
      /*
        Create the Servers Directory and then create the server by servername
      */
      serversDirectory = await Directory('./servers').create();

      serverDirectory =
          await Directory('${serversDirectory.path}/${config.serverName}')
              .create();
      serverAssetsDirectory =
          await Directory('${serverDirectory.path}/assets').create();

      /*
        Create the Config directory and then create the config file
        and save the URI.
      */
      serverConfigDirectory =
          await Directory('${serverDirectory.path}/config').create();

      serverConfig =
          await File('${serverConfigDirectory.path}/config').create();

      serverConfig.writeAsString(jsonEncode(config.toMap()));

      serverURI = await File('${serverConfigDirectory.path}/URI').create();

      serverURI.writeAsString(uri);

      /*
        Create the user directory and populate it with the UUID
      */
      serverUsersDirectory =
          await Directory('${serverDirectory.path}/users').create();

      serverUserDirectory =
          await Directory('${serverUsersDirectory.path}/this').create();

      userIDFile = await File('${serverUserDirectory.path}/UUID').create();

      userIDFile.writeAsString(userID);

      /*
        If the server is not saving chat on the server side then
        create the chats directory and then populate it with text files for each
        text channel
      */
      if (!config.saveContent) {
        serverChatsDirectory =
            await Directory('${serverDirectory.path}/chats').create();

        for (String textChannel in config.textChannels) {
          await File('${serverChatsDirectory.path}/$textChannel.txt').create();
        }

        returnedList.add(serverAssetsDirectory);
        returnedList.add(serverConfigDirectory);
        returnedList.add(serverUsersDirectory);
        returnedList.add(serverChatsDirectory);
      }
    } catch (e) {
      return returnedList;
    }

    returnedList.add(serverAssetsDirectory);
    returnedList.add(serverConfigDirectory);
    returnedList.add(serverUsersDirectory);

    return returnedList;
  }
}
