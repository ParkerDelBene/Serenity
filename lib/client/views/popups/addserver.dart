import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:serenity/client/data/communication/connection.dart';
import 'package:serenity/client/data/communication/serenityclient_user.dart';
import 'package:serenity/client/data/config/serenityserver_client_config.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/views/pages/serenity_server.dart';
import 'package:serenity/client/views/pages/text_channel.dart';
import 'package:serenity/client/views/pages/voice_channel.dart';
import 'package:serenity/client/views/widgets/serenity_image_icon.dart';
import 'package:serenity/server/communication/packet_types/class_serenity_init_packet.dart';
import 'package:serenity/server/class_serenity_user.dart';

class AddserverView extends StatelessWidget {
  AddserverView({super.key});

  final TextEditingController uriController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size viewSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: SizedBox(
          height: viewSize.height * .5,
          width: viewSize.height * .5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              textFieldWidget(uriController, "URI"),
              textFieldWidget(portController, "PORT"),
              textFieldWidget(passwordController, "PASSWORD"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => {
                      /// Then pop back to the dashboard
                      if (context.mounted)
                        {
                          Navigator.popUntil(
                              context, (route) => route.settings.name == "/")
                        }
                    },
                    child: FittedBox(
                      child: Text(
                        'Back',
                        style: channelTextStyle,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setupConnectionHandler(context),
                    child: FittedBox(
                      child: Text(
                        'Connect',
                        style: channelTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Name: addServerFailed
  ///
  /// Date Last Updated: 03/12/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function pushes the server failed dialog
  Future<void> addServerFailed(BuildContext context) {
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

  Widget textFieldWidget(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: channelTextStyle,
      ),
      style: channelTextStyle,
      cursorColor: highlightColor,
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
    if (!await newConnection.connect()) {
      if (context.mounted) {
        addServerFailed(context);
      }
      return;
    }

    ///Get the stream and then read the first few messages that will
    ///initialize the Server Config and UUID
    try {
      SerenityServer newServer = await initServer(newConnection);

      /// If initializing the server succeeded, add it to the serverList.
      serverList.add(newServer);

      /// Then pop back to the dashboard
      if (context.mounted) {
        Navigator.popUntil(context, (route) => route.settings.name == "/");
      }
    } catch (e) {
      /// If initializing the server failed somehow. Push the ServerFailed view
      if (context.mounted) {
        addServerFailed(context);
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
    Map<String, VoiceChannel> voiceChannels = <String, VoiceChannel>{};

    /// get the initial Connection messages from the server
    List<dynamic> initialConnectionMessages =
        await SerenityServer.getSerenityInitPacket(newConnection);

    /// Get the userID, userPAT, and InitPacket from the initial messages
    String userID = initialConnectionMessages[0];
    String userPAT = initialConnectionMessages[1];
    SerenityInitPacket initPacket = initialConnectionMessages[2];

    /// Call to create the necessary Server Directories
    List<Directory> directoryList =
        createServerDirectory(initPacket, userID, userPAT);

    /// Check if creating the directories failed
    if (directoryList.isEmpty) {
      throw Exception("Could not create Server Directories");
    }

    /// Create the clientSideConfig and push it to the config directory
    SerenityServerClientConfig clientsideConfig = SerenityServerClientConfig(
        initPacket.serverName,
        uriController.text,
        portController.text,
        initPacket.userID,
        initPacket.textChannels,
        initPacket.voiceChannels,
        initPacket.saveContent);

    /// Make the File
    File clientsideConfigFile = File("${directoryList[1].path}/config")
      ..createSync();

    /// Save to file
    clientsideConfigFile
        .writeAsStringSync(jsonEncode(clientsideConfig.toJson()));

    /// Get a map of the users
    Map<String, SerenityClientUser> userList = <String, SerenityClientUser>{
      for (SerenityUser user in initPacket.userList)
        user.userID: SerenityClientUser.fromSerenityUSer(user)
    };

    /// Add our user to the userMap
    userList.addAll({userID: localUser});

    /// Create the TextChannels
    for (String channel in initPacket.textChannels) {
      /// Checks if the length is 4, if so it returns the chat directory
      /// Else it pipes in null
      TextChannel newChannel = TextChannel(channel, !initPacket.saveContent,
          directoryList.length == 4 ? directoryList[3] : null, userList);

      textChannels.addAll({channel: newChannel});
    }

    /// Create the VoiceChannels
    for (String channel in initPacket.voiceChannels) {
      VoiceChannel newChannel =
          VoiceChannel(channel, {}, VoiceChannel.defaultSettings);

      voiceChannels.addAll({channel: newChannel});
    }

    /// Get the ServerBanner and ServerIcon Files
    File serverIconFile = File("${directoryList[0].path}/serverIcon.jpg");
    File serverBannerFIle = File("${directoryList[0].path}/serverBanner.jpg");

    /*
      Create the Serenity Server and then return it.
    */
    return SerenityServer(
      clientsideConfig,

      /// The localUser should always exist
      userList[userID]!,
      SerenityImageIcon(
          clientsideConfig.serverName, serverIconFile.readAsBytesSync()),
      serverBannerFIle.readAsBytesSync(),
      directoryList[0],
      directoryList[1],
      directoryList[2],
      initPacket.saveContent ? null : directoryList[3],
      textChannels,
      voiceChannels,
      userList,
      newConnection,
    );
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
  List<Directory> createServerDirectory(
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
    File serverBannerFile;
    File serverIconFile;
    File userIDFile;
    File userPATFile;

    /*
      Create the directory structure for the server
    */
    try {
      /// Create the Servers Directory and then create the server by servername
      serversDirectory = Directory('${applicationDirectory.path}/servers')
        ..createSync();

      serverDirectory =
          Directory('${serversDirectory.path}/${initPacket.serverName}')
            ..createSync();

      /// Create the assets directory and populate the serverIcon and serverbanner
      serverAssetsDirectory = Directory('${serverDirectory.path}/assets')
        ..createSync();

      serverIconFile = File("${serverAssetsDirectory.path}/serverIcon.jpg")
        ..createSync();
      serverIconFile.writeAsBytesSync(initPacket.serverIcon);

      serverBannerFile = File("${serverAssetsDirectory.path}/serverBanner.jpg")
        ..createSync();
      serverBannerFile.writeAsBytesSync(initPacket.serverBanner);

      /*
        Create the Config directory and then create the config file
      */
      serverConfigDirectory = Directory('${serverDirectory.path}/config')
        ..createSync();

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
      if (!initPacket.saveContent) {
        serverChatsDirectory = Directory('${serverDirectory.path}/chats')
          ..createSync();

        for (String textChannel in initPacket.textChannels) {
          File('${serverChatsDirectory.path}/$textChannel').createSync();
        }

        /// Add the directories to the returnedList
        returnedList.add(serverAssetsDirectory);
        returnedList.add(serverConfigDirectory);
        returnedList.add(serverUsersDirectory);
        returnedList.add(serverChatsDirectory);

        return returnedList;
      }

      /// Adds every directory except for the Chats Directory
      returnedList.add(serverAssetsDirectory);
      returnedList.add(serverConfigDirectory);
      returnedList.add(serverUsersDirectory);

      return returnedList;
    } catch (e) {
      return returnedList;
    }
  }
}
