import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:serenity/client/class_connection.dart';
import 'package:serenity/client/class_serenity_clientside_config.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/view_serenity_server.dart';
import 'package:serenity/client/view_text_channel.dart';
import 'package:serenity/server/class_serenity_config.dart';
import 'package:serenity/server/class_serenity_init_packet.dart';
import 'package:serenity/server/class_serenity_user.dart';
import 'package:win32/win32.dart';

class AddserverView extends StatelessWidget {
  AddserverView({super.key});

  final TextEditingController uriController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                  onPressed: () => setupConnectionHandler(context),
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

  /// Name setupConnectionHandler
  ///
  /// Last Date Updated: 02/18/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function handles the initial connection setup from pressing
  /// the connect textbutton
  void setupConnectionHandler(BuildContext context) async {
    ///
    /// Initialize the connection
    Connection newConnection = Connection.withPassword(
        uriController.text, portController.text, passwordController.text);

    /// If the Connection failed then push the serverFailed Page
    /// Else, pull the first two mesasges from the server, which are the UUID
    /// of the user, and then the ServerConfig
    if (!await newConnection.initialize()) {
      if (context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => addServerFailed(context)));
      }
    } else {
      ///Get the stream and then read the first few messages that will
      ///initialize the Server Config and UUID
      SerenityServer newServer = await initServer(newConnection);

      serverList.add(newServer);

      if (context.mounted) {
        Navigator.popUntil(context, (route) => route.settings.name == "/");
      }
    }
  }

  /// Name: initServer
  ///
  /// Last Date Updated: 01/22/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function takes in the connection, and then initializes the
  /// server and spits out the serenity server
  Future<SerenityServer> initServer(Connection newConnection) async {
    /// Init Variables for use
    Map<String, TextChannel> textChannels = <String, TextChannel>{};

    /// get the initial Connection messages from the server
    List<dynamic> initialConnectionMessages =
        await SerenityServer.getInitialPacket(newConnection);

    /// Get the userID, userPAT, and InitPacket from the initial messages
    String userID = initialConnectionMessages[0];
    String userPAT = initialConnectionMessages[1];
    SerenityInitPacket initPacket = initialConnectionMessages[2];

    /// Call to create the necessary Server Directories
    List<Directory> directoryList =
        createServerDirectory(initPacket, userID, newConnection.uri);

    if (directoryList.isEmpty) {
      throw Exception("Could not create Server Directories");
    }

    /*
      Create the TextChannels
    */
    for (String channel in initPacket.textChannels) {
      /// Checks if the length is 4, if so it returns the chat directory
      /// Else it pipes in null
      TextChannel newChannel = TextChannel(channel, !initPacket.saveContent,
          directoryList.length == 4 ? directoryList[3] : null);

      textChannels.addAll({channel: newChannel});
    }

    /*
      Create the Serenity Server and then return it.
    */
    return SerenityServer(
        initPacket.serverName,
        newConnection.uri,
        newConnection.port,
        userID,
        directoryList[0],
        directoryList[1],
        directoryList[2],
        initPacket.saveContent == false ? directoryList[3] : null,
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
  ///Returns {Assets,Config,Users,Chat,cliensideConfig} directory list if saving locally
  ///
  ///Returns {Assets,Config,Users,clientsideConfig} directory list if not saving locally
  ///
  List<dynamic> createServerDirectory(
      SerenityInitPacket initPacket, String userID, String userPAT) {
    /// Declare Variables to use

    List<Directory> returnedList = [];
    Directory serversDirectory;
    Directory serverDirectory;
    Directory serverAssetsDirectory;
    Directory serverConfigDirectory;
    Directory serverUsersDirectory;
    Directory serverUserDirectory;
    Directory serverChatsDirectory;
    File serverBanner;
    File serverIcon;
    File serverConfig;
    File userIDFile;
    File userPATFile;

    /*
      Create the directory structure for the server
    */
    try {
      /// Create the Servers Directory and then create the server by servername
      serversDirectory = Directory('./servers')..createSync();

      serverDirectory =
          Directory('${serversDirectory.path}/${initPacket.serverName}')
            ..createSync();

      /// Create the assets directory and populate the serverIcon and serverbanner
      serverAssetsDirectory = Directory('${serverDirectory.path}/assets')
        ..createSync();

      serverIcon = File("${serverAssetsDirectory.path}/serverIcon.jpg")
        ..createSync();
      serverIcon.writeAsBytesSync(initPacket.serverIcon);

      serverBanner = File("${serverAssetsDirectory.path}/serverBanner.jpg")
        ..createSync();
      serverBanner.writeAsBytesSync(initPacket.serverBanner);

      /*
        Create the Config directory and then create the config file
      */
      serverConfigDirectory = Directory('${serverDirectory.path}/config')
        ..createSync();

      serverConfig = File('${serverConfigDirectory.path}/config')..createSync();

      /// Create the clienside config
      SerenityClientsideConfig clientsideConfig = SerenityClientsideConfig(
        uriController.text,
        portController.text,
        initPacket.textChannels,
        initPacket.voiceChannels,
      );

      /// Write the clientSideConfig to the serverConfig file
      serverConfig.writeAsString(jsonEncode(clientsideConfig.toMap()));

      /*
        Create the user directory and populate it with the UUID and PAT
      */
      serverUsersDirectory = Directory('${serverDirectory.path}/users')
        ..createSync();

      serverUserDirectory = Directory('${serverUsersDirectory.path}/this')
        ..createSync();

      userIDFile = File('${serverUserDirectory.path}/UUID')..createSync();

      userIDFile.writeAsString(userID);

      userPATFile = File("${serverUserDirectory.path}/PAT")..createSync();

      userPATFile.writeAsString(userPAT);

      /// Then we need to populate the users directory with all of the users in
      /// the initPacket

      for (SerenityUser user in initPacket.userList) {
        /// Create the userDirectory
        Directory userDirectory =
            Directory("${serverUsersDirectory.path}/${user.userID}")
              ..createSync();

        /// populate the userIcon, userBanner, and userName
        File userIcon = File("${userDirectory.path}/userIcon.jpg")
          ..createSync();
        userIcon.writeAsBytesSync(user.userIcon);
        File userBanner = File("${userDirectory.path}/userBanner.jpg")
          ..createSync();
        userBanner.writeAsBytesSync(user.userBanner);
        File username = File("${userDirectory.path}/username")..createSync();
        username.writeAsStringSync(user.userName);
      }

      /// If the server is not saving chat on the server side then
      /// create the chats directory and then populate it with text files for each
      /// text channel
      if (initPacket.saveContent) {
        serverChatsDirectory = Directory('${serverDirectory.path}/chats')
          ..createSync();

        for (String textChannel in initPacket.textChannels) {
          File('${serverChatsDirectory.path}/$textChannel.txt').createSync();
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
