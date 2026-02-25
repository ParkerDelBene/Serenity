import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:serenity/client/class_connection.dart';
import 'package:serenity/client/class_serenity_clientside_config.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/view_text_channel.dart';
import 'package:serenity/client/widget_serenity_image_icon.dart';
import 'package:serenity/client/widget_view_divider.dart';
import 'package:serenity/server/class_serenity_init_packet.dart';
import 'package:serenity/server/class_serenity_packet.dart';
import 'package:serenity/server/class_serenity_update_packet.dart';
import 'package:serenity/server/class_serenity_user.dart';

class SerenityServer extends StatefulWidget {
  SerenityServer(
      this.serverName,
      this.serverIcon,
      this.serverBanner,
      this.uri,
      this.port,
      this.userID,
      this.assetsDirectory,
      this.configDirectory,
      this.usersDirectory,
      this.chatsDirectory,
      this.serverConfig,
      this.textChannels,
      this.voiceChannels,
      this.connection,
      {super.key});

  /*
    Constructor for a directory. The directory must be checked if it exists before
    calling the constructor on it.
  */
  factory SerenityServer.fromDirectory(Directory serverDirectory) {
    Directory configDirectory = Directory("${serverDirectory.path}/config");
    Directory assetsDirectory = Directory("${serverDirectory.path}/assets");
    Directory usersDirectory = Directory("${serverDirectory.path}/users");
    Directory chatsDirectory = Directory("${serverDirectory.path}/chats");
    File serverConfigFile = File("${configDirectory.path}/config");
    File userIDFile = File("${usersDirectory.path}/this/UUID");
    File userPATFile = File("${usersDirectory.path}/this/PAT");
    File serverIconFile = File("${assetsDirectory.path}/serverIcon.jpg");
    File serverBannerFile = File("${assetsDirectory.path}/serverBanner.jpg");

    ///Creating the SerenityClientsideConfig
    String serverConfigString = serverConfigFile.readAsStringSync();
    SerenityClientsideConfig serverConfig =
        SerenityClientsideConfig.fromMap(jsonDecode(serverConfigString));

    /*
      Getting UUID of this
    */
    String userID = userIDFile.readAsStringSync();

    /// Get the userPAT
    String userPAT = userPATFile.readAsStringSync();

    /*
      Establish the connection to the server
    */
    Connection connection = Connection.withUserID(
        serverConfig.serverURI, serverConfig.port, userID, userPAT);

    connection.initialize(); //Initialize the Conection;

    /*
      Generate the Text Channels
    */
    Map<String, TextChannel> textChannels = {};
    for (String channel in serverConfig.textChannels) {
      textChannels.addAll({
        channel: TextChannel(channel, !serverConfig.saveContent, chatsDirectory)
      });
    }

    /// Making sure the Iconfile and BannerFile exist
    serverIconFile.createSync();
    serverBannerFile.createSync();

    /*
      Return the Serenity Server Object
    */
    return SerenityServer(
        serverConfig.serverName,
        serverIconFile.readAsBytesSync(),
        serverBannerFile.readAsBytesSync(),
        serverConfig.serverURI,
        serverConfig.port.toString(),
        userID,
        assetsDirectory,
        configDirectory,
        usersDirectory,
        chatsDirectory,
        serverConfig,
        textChannels,
        serverConfig.voiceChannels,
        connection);
  }

  String serverName;
  Uint8List serverIcon;
  Uint8List serverBanner;
  final String uri;
  final String? port;
  final String userID;
  Directory assetsDirectory;
  Directory configDirectory;
  Directory usersDirectory;
  Directory? chatsDirectory;
  SerenityClientsideConfig serverConfig;
  Map<String, TextChannel> textChannels;
  List<String> voiceChannels;
  final Connection connection;

  @override
  State<SerenityServer> createState() => _SerenityServerState();

  /*
    Needs Full Implementation
  */
  Widget toIcon(double maxWidth) {
    if (serverIcon.isEmpty) {
      return SerenityServerIcon(serverName, null, maxWidth);
    } else {
      return SerenityServerIcon(serverName, serverIcon, maxWidth);
    }
  }

  /// Name:
  Widget serverBannerWidget() {
    return Stack(
      children: [
        Widget() =
        serverBanner.isEmpty ? Container() : Image.memory(serverBanner),
        Center(
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              serverName,
              style: TextStyle(fontSize: 20, color: highlightColor),
            ),
          ),
        ),
      ],
    );
  }

  /// Name: getSerenityInitPacket
  ///
  /// Date Last Updated: 02/18/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This funtion takes in the connection object. Pulls the first
  /// incoming packet, which will always be a SerenityInitPacket.
  ///
  /// It then returns a list of userID, userPAT, and SerenityInitPacket
  static Future<List<dynamic>> getSerenityInitPacket(
      Connection connection) async {
    String userID = "";
    String userPAT = "";
    SerenityInitPacket? initPacket;

    /// We know the first packet from the server is going to be the initPacket
    /// So we go ahead and go through with decoding the data to a SerenityPacket
    /// and then decoding the packet.data to a SerenityInitPacket
    connection.getMessageSocketStream().first.then(
      (data) {
        /// Get the packet data
        SerenityPacket packet = SerenityPacket.fromMap(jsonDecode(data));
        SerenityInitPacket incomingInitPacket =
            SerenityInitPacket.fromMap(jsonDecode(packet.data));

        /// Get the userID
        userID = incomingInitPacket.userID;

        /// Get the userPAT
        userPAT = incomingInitPacket.userPAT;

        initPacket = incomingInitPacket;
      },
    );

    while (initPacket == null) {
      await Future.delayed(Duration(milliseconds: 250));
    }

    return [userID, userPAT, initPacket];
  }
}

class _SerenityServerState extends State<SerenityServer> {
  List<Widget> channelWidgets = [];
  TextChannel? activeChannel;
  late StreamSubscription incomingTextChannelSubscription;
  Map<String, SerenityUser> userList = {};

  /*
    Initialize the listeners for textChannels and voiceChannels

    Initialize the listeners for incoming messages
  */
  @override
  void initState() {
    super.initState();

    /// initializes initialConnectionMessages
    _setupServerListeners();

    _sendUpdatedUSerInfo();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    /*
      If the widgetlist length and list of channels differ, generate the widgetlist
      and the textChannelName
    */
    if (channelWidgets.length !=
        widget.textChannels.length + widget.voiceChannels.length) {
      channelWidgets = [];

      widget.textChannels.forEach((channelName, channel) {
        channelWidgets.add(channel.toIcon());
      });

      channelWidgets.add(ViewDivider(false));

      for (String channel in widget.voiceChannels) {
        channelWidgets.add(Text(channel));
      }
    }

    return Row(
      children: [
        /*
          The area for the text and voice channels list
        */
        Container(
          decoration: BoxDecoration(color: primaryColor),
          height: size.height,
          width: maxScreenWidth * .1,
          child: Column(
            children: [
              widget.serverBannerWidget(),
              SingleChildScrollView(
                child: Column(
                  children: channelWidgets,
                ),
              ),
            ],
          ),
        ),
        ViewDivider(true),
        /*
          The area to view the text Channel / voice Channel
        */
        Expanded(
          child: SizedBox(
            height: size.height,
            child: activeChannel ?? Container(),
          ),
        ),
        /*
          Area to see people who are online
        */
        SizedBox()
      ],
    );
  }

  /// Name: _outgoingTectChannelListener
  ///
  /// Date Last Updated: 02/18/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: The Text Channel Listener attaches to the chatAdd of the
  /// Textchannel.  When prompted, it drains the Queue and sends out the messages,
  /// then sets the chatAdd flag to false.
  void _outgoingTextChannelListener(TextChannel channel) {
    if (channel.outgoingChatAdd.value) {
      while (channel.outgoingChat.isNotEmpty) {
        /// Remove the first of the queue and send it along the socket
        widget.connection
            .writeMessageSocket(channel.outgoingChat.removeFirst());
      }

      channel.outgoingChatAdd.value = false;
    }
  }

  /// Name: _incomingTextChannelListener
  ///
  /// Date Last Updated: 02/18/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function takes in all the incoming SerenityPacket messages,
  /// switches on the type, and directs the packet to the correct handler function
  void _incomingTextChannelListener(dynamic message) async {
    /// decode the incoming message
    SerenityPacket serenityPacket = SerenityPacket.fromMap(jsonDecode(message));

    switch (serenityPacket.type) {
      /// If it is a text packet, send the data to the _chatChannelHandler
      case SerenityPacketTypeEnum.text:
        _chatChannelHandler(serenityPacket.data);
        break;

      /// If it is userInfo, then decode the data and pass to _userInfoHandler
      case SerenityPacketTypeEnum.userInfo:
        _userInfoHandler(SerenityUser.fromMap(jsonDecode(serenityPacket.data)));
        break;

      /// If it is the serverBanner, then overwrite the serverBanner file
      case SerenityPacketTypeEnum.serverBanner:
        File serverBanner =
            File("${widget.assetsDirectory.path}/serverBanner.jpg")
              ..createSync();
        serverBanner.writeAsBytesSync(serenityPacket.data);

        /// Refresh the state if mounted
        if (mounted) {
          setState(() {});
        }
        break;

      /// If it is the serverIcon, then overwrite the serverIcon File
      case SerenityPacketTypeEnum.serverIcon:
        File serverIcon = File("${widget.assetsDirectory.path}/serverIcon.jpg")
          ..createSync();
        serverIcon.writeAsBytesSync(serenityPacket.data);

        /// Refresh the state if mounted
        if (mounted) {
          setState(() {});
        }
        break;

      /// If it is an UpdatePacket, then decode the packet data and send to the
      /// updatePacketHandler function
      case SerenityPacketTypeEnum.serenityUpdatePacket:
        _updatePacketHandler(
            SerenityUpdatePacket.fromMap(jsonDecode(serenityPacket.data)));
      default:
        break;
    }
  }

  /// Name: _chatChannelHandler
  ///
  /// Date Last Updated: 02/18/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function receives the incoming string messages, splits on
  /// the first and second ";" to get the userID and the channel name, then sends
  /// the message to the correct textChannel
  void _chatChannelHandler(String message) {
    /// We need to get the channelName, the message, and the userID
    int indexOfSemi = -1;
    String channelName = "";
    String chatMessage = "";
    String userID = "";

    /// Get the index of the first semicolon
    indexOfSemi = message.indexOf(';');

    if (indexOfSemi == -1) {
      return;
    }

    /// Get the userID
    userID = message.substring(0, indexOfSemi);
    String remainingMessage = message.substring(indexOfSemi + 1);

    /// Get the index of the second semicolon
    indexOfSemi = remainingMessage.indexOf(";");

    if (indexOfSemi == -1) {
      return;
    }

    /// Get the channelName
    channelName = remainingMessage.substring(0, indexOfSemi);
    chatMessage = remainingMessage.substring(indexOfSemi + 1);

    /*
      If the channelExists for the user, which it might not, then add the
      message to the channel
    */
    if (widget.textChannels.containsKey(channelName)) {
      widget.textChannels[channelName]?.addChat(userList[userID]!, chatMessage);
    }
  }

  /*
    listens to the active chat and swaps the active one, and deactivates the old one.
  */
  void _activeChatListener(TextChannel channel) {
    if (channel.activeChat.value) {
      if (activeChannel != null) {
        activeChannel?.activeChat.value = false;
      }

      activeChannel = channel;

      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Name: _setupServerListeners
  ///
  /// Date Last Updated: 02/18/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This initializes the incoming message listener
  void _setupServerListeners() async {
    ///Initialize the listener fo the incoming messages
    incomingTextChannelSubscription = widget.connection
        .getMessageSocketStream()
        .listen((message) => _incomingTextChannelListener(message));
  }

  /// Name: _setupServerListeners
  ///
  /// Date Last Updated: 02/23/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This initializes the listeners for the Text Channels
  void _setupTextChannelListeners() {
    ///Initialize the listener for the outgoingChats
    widget.textChannels.forEach((channelName, channel) {
      channel.outgoingChatAdd.addListener(() {
        _outgoingTextChannelListener(channel);
      });
      channel.activeChat.addListener(() {
        _activeChatListener(channel);
      });
    });
  }

  /// Name: updatePacketHandler
  ///
  /// Date Last Updated: 02/18/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function uses the update packet to check for server changes.
  ///
  /// It can update the serverIcon, serverBanner, textChannels, voiceChannels
  Future<void> _updatePacketHandler(SerenityUpdatePacket updatePacket) async {
    /// If the serverName has changes, we need to modify the server directory
    if (updatePacket.serverName != widget.serverName) {
      /// Create the new server directory
      Directory newServerDirectory =
          Directory("./servers/${updatePacket.serverName}")..createSync();

      /// Get all of the FileSystem Entities within the old server
      List<FileSystemEntity> entityList =
          Directory("./servers/${widget.serverName}").listSync(recursive: true);
      List<File> fileList = [];
      List<Directory> directoryList = [];

      /// Loop on the Filesystem entities. Putting File into fileList Putting
      /// Directory in directoryList
      for (FileSystemEntity entity in entityList) {
        if (entity is File) {
          fileList.add(entity);
        }

        if (entity is Directory) {
          directoryList.add(entity);
        }
      }

      /// Now, we need to recreate all of the Files inside of the newserverDirectory
      /// The files can recursively create their directories
      for (File file in fileList) {
        /// create the new path, changing the old serverName to the new one.
        String newPath =
            file.path.replaceAll(widget.serverName, updatePacket.serverName);

        /// Recursively create the new file. Then we are going to copy the old
        /// file to the new one.
        File newFile = File(newPath)..createSync(recursive: true);

        /// Copy the old file to the new file.
        file.copySync(newFile.path);

        /// delete the old file
        file.deleteSync();
      }

      /// Now verify that all of the Directories we found were recreated. If they
      /// Were not, then create them
      for (Directory directory in directoryList) {
        /// Create the new path, changing the old serverName to the new one
        String newPath = directory.path
            .replaceAll(widget.serverName, updatePacket.serverName);

        /// create the new directory, createSync does nothing if the directory
        /// already exists, so there is no reason to check if it exists, just try
        /// to create it.
        ///
        /// This helps create the directories that do not have files in them yet.
        /// I am not sure what directories that would be, but just in case.
        Directory(newPath).createSync(recursive: true);
      }

      /// Replace all instances of the old serverName with the new one
      /// Make sure to delete the old directories and then move them to the new
      /// path
      widget.assetsDirectory.deleteSync(recursive: true);
      widget.assetsDirectory = Directory(widget.assetsDirectory.path
          .replaceAll(widget.serverName, updatePacket.serverName));

      widget.configDirectory.deleteSync(recursive: true);
      widget.configDirectory = Directory(widget.configDirectory.path
          .replaceAll(widget.serverName, updatePacket.serverName));

      widget.usersDirectory.deleteSync(recursive: true);
      widget.usersDirectory = Directory(widget.usersDirectory.path
          .replaceAll(widget.serverName, updatePacket.serverName));

      /// If we have a chats directory, and the updatePacket tells us that the
      /// server is not saving content, then move the chats directory over
      if (widget.chatsDirectory != null && !updatePacket.saveContent) {
        widget.chatsDirectory?.deleteSync();
        widget.chatsDirectory = Directory(widget.chatsDirectory!.path
            .replaceAll(widget.serverName, updatePacket.serverName));
      }

      ///Delete the parent Directory
      Directory("./servers/${widget.serverName}").deleteSync(recursive: true);
    }

    // Replace the serverConfig
    widget.serverConfig = SerenityClientsideConfig(
        updatePacket.serverName,
        widget.serverConfig.serverURI,
        widget.serverConfig.port,
        updatePacket.textChannels,
        updatePacket.voiceChannels,
        updatePacket.saveContent);

    /// Replace ServerName
    widget.serverName = widget.serverConfig.serverName;

    /// Save the new Config File
    File("${widget.configDirectory.path}/config")
        .writeAsStringSync(jsonEncode(widget.serverConfig));

    /// Add back the text channels
    widget.textChannels.clear();
    for (String channel in widget.serverConfig.textChannels) {
      widget.textChannels.addAll({
        channel: TextChannel(
            channel, !widget.serverConfig.saveContent, widget.chatsDirectory)
      });
    }

    /// Setup text channel listeners again.
    _setupTextChannelListeners();

    // Add back the voice channels
    widget.voiceChannels.clear();
    widget.voiceChannels.addAll(widget.serverConfig.voiceChannels);

    /// Finally, load all of the users from the updatePacket
    for (SerenityUser user in updatePacket.userList) {
      _userInfoHandler(user);
    }

    ///Load the serverBanner and serverIcon
    File serverIconFile = File("${widget.assetsDirectory.path}/serverIcon.jpg")
      ..createSync();
    serverIconFile.writeAsBytesSync(updatePacket.serverIcon);
    widget.serverIcon = updatePacket.serverIcon;
    File serverBannerFile =
        File("${widget.assetsDirectory.path}/serverBanner.jpg")..createSync();
    serverBannerFile.writeAsBytesSync(updatePacket.serverBanner);
    widget.serverBanner = updatePacket.serverBanner;

    // Reset the state if its mounted.
    if (mounted) {
      setState(() {});
    }
  }

  /// Name: Parker DelBene
  ///
  /// Date Last Updated: 02/19/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function takes in a SerenityUser, creating them if we do not
  /// have them yet, and updating their information if we do have them.
  void _userInfoHandler(SerenityUser userInfo) async {
    /// If we have not received out info, then update the user.
    if (userInfo.userID != widget.userID) {
      /// Go ahead and just create the directory, if it exists it wont do anything.
      Directory userDirectory =
          Directory("${widget.usersDirectory.path}/${userInfo.userID}")
            ..createSync();

      /// Create the usernameFile and write the username to it as a String
      File usernameFile = File("${userDirectory.path}/username")..createSync();
      usernameFile.writeAsStringSync(userInfo.userName);

      /// Create the userIcon and userBanner files and populate them with the data
      File userIconFile = File("${userDirectory.path}/userIcon.jpg");
      userIconFile.writeAsBytesSync(userInfo.userIcon);
      File userBannerFile = File("${userDirectory.path}/userBanner.jpg");
      userBannerFile.writeAsBytesSync(userInfo.userBanner);

      userList.addAll({userInfo.userID: userInfo});
    }
  }

  /// Name: _sendUpdatedUserInfo
  ///
  /// Date Last Updated: 02/23/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This user send the localUser's Info to the server to be updated
  void _sendUpdatedUSerInfo() {
    /// Create the userInfo, using the userID for the server
    SerenityUser userInfo = SerenityUser(widget.userID, localUser.userName,
        localUser.userIcon, localUser.userBanner);

    /// Create the SerenityPacket
    SerenityPacket packet =
        SerenityPacket(SerenityPacketTypeEnum.userInfo, jsonEncode(userInfo));

    /// Send the packet
    widget.connection.writeMessageSocket(jsonEncode(packet));
  }
}
