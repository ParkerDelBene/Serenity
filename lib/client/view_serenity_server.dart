import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:serenity/client/class_connection.dart';
import 'package:serenity/client/class_serenity_clientside_config.dart';
import 'package:serenity/client/view_text_channel.dart';
import 'package:serenity/client/widget_server_icon.dart';
import 'package:serenity/server/class_serenity_config.dart';
import 'package:serenity/server/class_serenity_init_packet.dart';
import 'package:serenity/server/class_serenity_packet.dart';

class SerenityServer extends StatefulWidget {
  SerenityServer(
      this.serverName,
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
    File uriFile = File("${configDirectory.path}/URI");
    File userIDFile = File("${usersDirectory.path}/this/UUID");
    File userPATFile = File("${usersDirectory.path}/this/PAT");

    /*
      Creating the SerenityConfig
    */
    String serverConfigString = serverConfigFile.readAsStringSync();
    SerenityConfig serverConfig =
        SerenityConfig.fromMap(jsonDecode(serverConfigString));

    /*
      Getting the uri
    */
    String uri = uriFile.readAsStringSync();

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
        uri, serverConfig.port.toString(), userID, userPAT);

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

    /*
      Return the Serenity Server Object
    */
    return SerenityServer(
        serverConfig.serverName,
        uri,
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
    if (!File("${assetsDirectory.path}/server.icon").existsSync()) {
      return ServerIcon(serverName, null, maxWidth);
    } else {
      return ServerIcon(serverName,
          Image.file(File("${assetsDirectory.path}/server.icon")), maxWidth);
    }
  }

  /// Name: getInitialPacket
  ///
  /// Date Last Updated: 02/18/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This funtion takes in the connection object. Pulls the first
  /// incoming packet, which will always be a SerenityInitPacket.
  ///
  /// It then returns a list of userID, userPAT, and SerenityInitPacket
  static Future<List<dynamic>> getInitialPacket(Connection connection) async {
    String userID = "";
    String userPAT = "";
    SerenityInitPacket? initPacket;

    /// We know the first packet form the server is going to be the initPacket
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

SerenityConfig? incomingConfig;

class _SerenityServerState extends State<SerenityServer> {
  List<Widget> channelWidgets = [];
  TextChannel? activeChannel;
  late StreamSubscription incomingTextChannelSubscription;
  List<StreamSubscription> outGoingTextChannelSubscriptions = [];
  List<dynamic> initialConnectionMessages = [];

  /*
    Initialize the listeners for textChannels and voiceChannels

    Initialize the listeners for incoming messages
  */
  @override
  void initState() {
    super.initState();

    /// initializes initialConnectionMessages
    _setupServerListeners();

    validateServerConfig();
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

      channelWidgets.add(Divider(
        height: 10,
      ));

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
          decoration: BoxDecoration(color: Colors.blue),
          height: size.height,
          width: size.width * .1,
          child: SingleChildScrollView(
            child: Column(
              children: channelWidgets,
            ),
          ),
        ),
        /*
          The area to view the text Channel / voice Channel
        */
        Expanded(
            child: SizedBox(
          height: size.height,
          child: activeChannel,
        )),
        /*
          Area to see people who are online
        */
        SizedBox()
      ],
    );
  }

  /*
    The Text Channel Listener attaches to the chatAdd of the Textchannel.

    When prompted, it drains the Queue an sends out the messages, then sets the 
    chatAdd flag to false.
  */
  void _outgoingTextChannelListener(TextChannel channel) {
    if (channel.outgoingChatAdd.value) {
      String message;
      while (channel.outgoingChat.isNotEmpty) {
        message = channel.outgoingChat.removeFirst();
        widget.connection.writeMessageSocket("${channel.channelName};$message");
      }

      channel.outgoingChatAdd.value = false;
    }
  }

  /*
    Listens to the incoming text messages and then filters them to the correct
    chat channel.
  */
  void _incomingTextChannelListener(dynamic message) async {
    String incomingMessage = message;

    int indexOfSemi = -1;
    String channelName = "";
    String chatMessage = "";

    indexOfSemi = incomingMessage.indexOf(';');

    if (indexOfSemi == -1) {
      return;
    }

    channelName = incomingMessage.substring(0, indexOfSemi);
    chatMessage = incomingMessage.substring(indexOfSemi + 1);
    chatMessage = chatMessage.trim();

    /*
      If the channelExists for the user, which it might not, then add the
      message to the channel
    */
    if (widget.textChannels.containsKey(channelName)) {
      widget.textChannels[channelName]?.addChat(chatMessage);
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

  /// Called by validateServerConfig
  ///
  /// It is meant to separate the creation of the incoming and outgoing
  /// chat listeners from the validateServerConfig Function, and also call
  /// SerenityServer.initialConnectionSetup, which pulls the initial server
  /// messages
  void _setupServerListeners() async {
    /// Getting the initial Messages.
    List<dynamic> initialConnectionMessage =
        await SerenityServer.getInitialPacket(widget.connection);

    ///Initialize the listener fo the incoming messages
    incomingTextChannelSubscription = widget.connection
        .getMessageSocketStream()
        .listen((message) => _incomingTextChannelListener(message));

    ///Initialize the listener for the outgoingChats
    widget.textChannels.forEach((channelName, channel) {
      channel.outgoingChatAdd
          .addListener(() => _outgoingTextChannelListener(channel));
      channel.activeChat.addListener(() => _activeChatListener(channel));
    });
  }

  /// Name: validateServerConfig
  ///
  /// This function pulls the first connection messages from the server,
  /// initializes the incoming message handlers, and then validates the incoming
  /// server config vs the local cached one.
  Future<void> validateServerConfig(SerenityConfig incomingServerConfig) async {
    /// check if the setupListeners have been initialized yet
    if (!setupListeners) {}

    ///Continue with validating the incomingServerConfig
    String userID = initialConnectionMessages[0];
    SerenityConfig incomingServerConfig = initialConnectionMessages[1];

    /*
      If the incoming ServerConfig is the same as the cached one do nothing.
    */
    if (incomingServerConfig == widget.serverConfig) {
      return;
    }

    /*
      If the serverName has changed, we will need to recreate the entire Serenity Server
      since we cannot modify final fields.
    */
    if (incomingServerConfig.serverName != widget.serverName) {
      // Rewrite the directories

      // Replace all instances of the old serverName with the new one
      widget.assetsDirectory = widget.assetsDirectory.renameSync(widget
          .assetsDirectory.path
          .replaceAll(widget.serverName, incomingServerConfig.serverName));

      widget.configDirectory = widget.configDirectory.renameSync(widget
          .configDirectory.path
          .replaceAll(widget.serverName, incomingServerConfig.serverName));

      widget.usersDirectory = widget.usersDirectory.renameSync(widget
          .usersDirectory.path
          .replaceAll(widget.serverName, incomingServerConfig.serverName));

      // Check if the the server is saving content, if not then we have a chats
      // Directory
      if (!incomingServerConfig.saveContent) {
        widget.chatsDirectory = widget.chatsDirectory?.renameSync(widget
            .chatsDirectory!.path
            .replaceAll(widget.serverName, incomingServerConfig.serverName));
      }
    }

    // Replace the serverConfig
    widget.serverConfig = incomingServerConfig;

    widget.textChannels.clear();
    for (String channel in widget.serverConfig.textChannels) {
      widget.textChannels.addAll({
        channel: TextChannel(
            channel, widget.serverConfig.saveContent, widget.chatsDirectory)
      });
    }

    // Add back the voice channels
    widget.voiceChannels.clear();
    widget.voiceChannels.addAll(widget.serverConfig.voiceChannels);

    // Reset the state if its mounted.
    if (mounted) {
      setState(() {});
    }
  }
}
