import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:serenity/server/class_serenity_init_packet.dart';
import 'package:serenity/server/class_serenity_packet.dart';
import 'package:serenity/server/class_serenity_update_packet.dart';
import 'package:serenity/server/class_serenity_user.dart';
import 'package:uuid/uuid.dart';

import 'class_serenity_config.dart';

class SerenityServer {
  SerenityServer();

  /// Attributes

  late final HttpServer server;
  String errorString = "";
  Map<String, WebSocket> textClients = {};
  HashMap<String, List<WebSocket>> voiceChannels = HashMap();
  late SerenityConfig config;
  late Directory usersDirectory;
  late Directory assetsDirectory;
  late Directory chatsDirectory;
  late Directory keysDirectory;
  List<SerenityUser> userList = [];
  late Uint8List serverIcon;
  late Uint8List serverBanner;

  Future<bool> initialize() async {
    /*
      Run the startup check to verify all of the server directories have been
      created and that the server config file is formatted correctly.
    */
    if (!await startupCheck()) {
      print('Failed Startup Check');
      return false;
    }

    /// Listen functions pipes to the request Handler
    server.listen(
      requestHandler,
      onDone: () {},
      onError: (e) {
        print(e.toString());
      },
    );

    return true;
  }

  /// Name: initialHandshakeHandler
  ///
  /// Date Last Updated: 02/04/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function handles the request
  Future<bool> requestHandler(HttpRequest request) async {
    (HttpRequest request) async {
      /*
        Get the type of request,

        Text types are the initial that handle all incoming text
        Voice connects to a specific channel.
      */
      Map<String, List<String>> queryParameters =
          request.uri.queryParametersAll;
      String? type = queryParameters["type"]?[0];
      String? userID = queryParameters["userID"]?[0];
      String? password = queryParameters["password"]?[0];
      String? userPAT = queryParameters["userPAT"]?[0];
      InternetAddress? requestIP = request.connectionInfo?.remoteAddress;
      bool firstConnect = false;
      List<String> userData = [];

      print("Attempted request from ${requestIP?.address} with userID $userID");

      /// Verify the type is not null
      if (type == null) {
        invalidRequestType(request);
        return;
      }

      /// Return if the requestIP is null
      if (requestIP == null) {
        invalidRequestType(request);
        return;
      }

      /// If the user ID is null, then we need to verify the password supplied
      /// is valid.
      if (userID == null) {
        bool result = password == null
            ? invalidRequestType(request)
            : passwordChecker(password);

        if (!result) {
          return;
        }

        userData = await generateClientData();
        userID = userData[0];
        userPAT = userData[1];

        /// Set first connect to true to run through first time connection setup
        firstConnect = true;
      }

      /// If the userPAT is null then send invalid request and return
      if (userPAT == null) {
        invalidRequestType(request);
        return;
      }

      /// Check if we have client data and the PAT matches
      if (!await checkClientData(userID, userPAT)) {
        invalidRequestType(request);
        return;
      }

      /// switch on type
      switch (type) {
        case 'text':

          /// Branch on first connect
          firstConnect == true
              ? clientFirstConnect(request, userID, userPAT)
              : clientTextConnect(request, userID);
          break;
        case 'voice':
          clientVoiceConnect(request);
          break;
        default:
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.reasonPhrase = 'Invalid Request Type';
          request.response.flush();
          request.response.close();
          break;
      }
    };

    return true;
  }

  bool invalidRequestType(HttpRequest request) {
    request.response.statusCode = HttpStatus.unauthorized;
    request.response.reasonPhrase = 'Invalid Request Type';
    request.response.flush();
    request.response.close();
    return false;
  }

  /// Name: passwordChecker
  ///
  /// Date Last Updated: 02/06/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This takes in the string password and compares it to the password
  /// hash stored within the server config.
  bool passwordChecker(String password) {
    if (config.password == sha256.convert(utf8.encode(password)).toString()) {
      return true;
    }

    return false;
  }

  /// Name: startupCheck
  ///
  /// Date Last Updated: 01/20/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This consolidates all of the initialization checks into one function
  ///
  /// Calls ValidateConfig, ValidateUsersDirectory, and loadUsers before
  /// binding the server to 0.0.0.0 on port 12345
  Future<bool> startupCheck() async {
    /// Load the config
    if (!await loadConfig()) {
      return false;
    }

    /// validate the directories
    if (!validateDirectories()) {
      return false;
    }

    /// Load the User information
    loadUsers();

    /*
      Finally Bind the server before returning
    */
    try {
      print("Binding to ${config.serverAddress} on port ${config.port}");
      if (config.useSSL) {
        SecurityContext securityContext = SecurityContext();
        securityContext.useCertificateChain("./keys/fullchain.pem");
        securityContext.usePrivateKey("./keys/privkey.pem");

        server = await HttpServer.bindSecure(
            config.serverAddress, config.port, securityContext);
      } else {
        server = await HttpServer.bind(config.serverAddress, config.port);
      }
    } catch (e) {
      print(e);
      print("Error Binding Server");
      return false;
    }

    return true;
  }

  /// Name: validateConfig
  ///
  /// Date Last Updated: 02/04/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: reads the server.config file and initializes the SerenityConfig
  /// variable.
  ///
  /// If the config file does not exist then it populates the file with the
  /// default data stored in SerenityConfig.defaultdata static variable. It then
  /// calls the createServerPassword function
  ///
  /// If the config file exists, then it simply reads the file and initializes
  /// the config variable
  ///
  /// Returns true if the config variable was initialized successfully
  Future<bool> loadConfig() async {
    /// Variables
    File configFile = File("./server.config");
    String configString = "";

    /// If the config file doesn't exist, the create it and populate it.
    if (!configFile.existsSync()) {
      try {
        configFile.createSync();

        /// Write the File
        configFile.writeAsStringSync(jsonEncode(SerenityConfig.defaultData));

        /// Initialize the config variable
        config = SerenityConfig.fromMap(SerenityConfig.defaultData);

        /// Call function to create the password for the server
        return await createServerPassword();
      } catch (e) {
        print(e);
        print("Error loading Config File");
        return false;
      }
    }

    /// Else the config file exists, so read it and initialize the variable
    try {
      /// Read the config file as string
      configString = configFile.readAsStringSync();

      /// initialize the config after decoding the string
      config = SerenityConfig.fromMap(jsonDecode(configString));
    } catch (e) {
      print(e);
      print("Error loading Config File");
      return false;
    }

    /// return true
    return true;
  }

  /// Name: createServerPassword
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Date Last Updated: 02/04/26
  ///
  /// Function: Reads input from the console to ask user for server password.
  /// Confirms the password before hashing using SHA256 from crypto package
  Future<bool> createServerPassword() async {
    bool passwordMatch = false;
    String inputPassword = "";
    String confirmPassword = "";

    while (!passwordMatch) {
      print("Create the password for the server");

      /// Wait for the password input
      inputPassword = String.fromCharCodes(await stdin.first);

      print("Confirm the password");

      /// Confirm the password
      confirmPassword = String.fromCharCodes(await stdin.first);

      if (inputPassword == confirmPassword) {
        /// Set variable to break from the while loop
        passwordMatch = true;

        /// Hash the password, set the password in the config, then save the
        /// config to file
        config.password = sha256.convert(utf8.encode(inputPassword)).toString();
      }
    }

    /// Return after writing to config file
    return await writeConfigToFile();
  }

  /// Name: writeConfigToFile
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Date Last Updated: 02/04/26
  ///
  /// Function: Takes the current config and writes it back to the config file.
  Future<bool> writeConfigToFile() async {
    try {
      await File("./server.config").writeAsString(jsonEncode(config.toMap()));
    } catch (e) {
      print(e);
      print("Error writing Config File");
      return false;
    }

    return true;
  }

  /// Name: validateDirectories
  ///
  /// Date Last Updated: 02/04/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: checks that the necessary directories are created. If they have
  /// not, then it creates them based on the path in the config
  ///
  /// Directories:
  ///
  /// assetsDirectory
  ///
  /// usersDirectory
  ///
  /// chatsDirectory
  ///
  bool validateDirectories() {
    /// Assign the directories to the paths in the config
    assetsDirectory = Directory(config.assetDirectory);
    usersDirectory = Directory(config.usersDirectory);
    chatsDirectory = Directory(config.chatsDirectory);
    keysDirectory = Directory(config.keysDirectory);

    /// Checking they have been created / are valid
    try {
      assetsDirectory.createSync();
      usersDirectory.createSync();
      chatsDirectory.createSync();
    } catch (e) {
      print(e);
      print("Error verifying Directories");
      return false;
    }

    /// If they succeeded, then return true;
    return true;
  }

  /// Name: loadUsers
  ///
  /// Date Last Updated 02/03/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: Loads all the users present in the users directory
  void loadUsers() {
    List<FileSystemEntity> directoryList = usersDirectory.listSync();

    for (FileSystemEntity entity in directoryList) {
      /// Check if the entity is a Directory, if it isn't, remove it from the list
      if (entity is! Directory) {
        directoryList.remove(entity);
      } else {
        /// Split the path and grab the last split, this should give us the userID
        List<String> splitPath = entity.path.split('/');
        String userID = splitPath[splitPath.length - 1];
        print("Loaded userId : $userID");

        /// Grab the rest of the data from the files in the
        String userName = File("${entity.path}/username").readAsStringSync();
        Uint8List userIcon =
            File("${entity.path}/userIcon.jpg").readAsBytesSync();
        Uint8List userBanner =
            File("${entity.path}/userBanner.jpg").readAsBytesSync();

        SerenityUser user =
            SerenityUser(userID, userName, userIcon, userBanner);
        userList.add(user);
      }
    }
  }

  ///
  ///Name: checkClientData
  ///
  ///Date Last Updated: 11/17/25
  ///
  ///Last Updater: Parker DelBene
  ///
  ///Function: checks if there is available clientData
  Future<bool> checkClientData(String userID, String userPAT) async {
    Directory usersDirectory = Directory('./users');

    Directory userDirectory = Directory('${usersDirectory.path}/$userID');

    /// Check that the user directory exists.
    if (!await userDirectory.exists()) {
      return false;
    }

    ///Check the PAT for the user
    File patFile = File("${userDirectory.path}/PAT");

    if (!patFile.existsSync()) {
      return false;
    }

    /// Check the pat against the hash stored
    String storedPATHash = patFile.readAsStringSync();
    String userPATHash = sha256.convert(userPAT.codeUnits).toString();

    /// If they are not equal, then return false
    if (storedPATHash != userPATHash) {
      return false;
    }

    return true;
  }

  ///  Name: generateClientData
  ///
  ///  Date Last Updated: 11/17/25
  ///
  ///  Last Updater: Parker DelBene
  ///
  ///  Function: Handles Generating the unique userID and userPAT.
  ///
  /// Format -> ["userID","userPAT"]
  Future<List<String>> generateClientData() async {
    List<String> userData = [];

    //Create the userID based on Time.
    userData.add(Uuid().v1());

    print("Generated userID ${userData[0]}");

    userData.add(Uuid().v4());

    //Create the user's Directory to store their data.
    Directory userDirectory =
        await Directory('./users/${userData[0]}').create();

    // Write the PAT to a plain text file
    File patFile = await File("${userDirectory.path}/PAT").create();

    patFile.writeAsString(sha256.convert(userData[1].codeUnits).toString());

    return userData;
  }

  /*
    Name: clientVoiceConnect

    Date Last Updated: 7/7/25

    Last Updater: Parker DelBene
    
    Function: Handles finding the correct voice channel and connecting
  */
  void clientVoiceConnect(HttpRequest request) {
    String? channelName = request.uri.queryParameters['channelName'];

    /*
        If it does not contain the channel name, return 403 Invalid Channel
      */
    if (!voiceChannels.containsKey(channelName)) {
      request.response.statusCode = HttpStatus.forbidden;
      request.response.reasonPhrase = 'Invalid Channel';
      request.response.close();

      return;
    }

    /*
        Add the websocket to the correct voicechannel 
      */
    WebSocketTransformer.upgrade(request).then((webSocket) {
      voiceChannels[channelName]?.add(webSocket);

      webSocket.listen(
        (data) {
          writeVoiceData(webSocket, voiceChannels[channelName]!, data);
        },
        onDone: () {
          voiceChannels[channelName]?.remove(webSocket);
        },
      );
    });
  }

  /*
    Name: writeVoiceData

    Date Last Updated: 7/17/25

    Last Updater: Parker DelBene

    Function: This function is called by the .listen
      function on the websockets. It replicates the data to 
      the rest of the clients in the voice Channel.

  */
  void writeVoiceData(
    WebSocket sender,
    List<WebSocket> voiceChannel,
    dynamic message,
  ) {
    for (WebSocket client in voiceChannel) {
      if (client != sender) {
        client.add(message);
      }
    }
  }

  ///
  /// Name: clientTextConnect
  ///
  /// Date Last Updated: 7/17/25textClients.add(webSocket);
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: Accepts the request and upgrades to a websocket, sends the
  /// initial messages, and then calls listen on the websocket, piping the
  /// messages to the messageHandler
  void clientTextConnect(HttpRequest request, String userID) async {
    /// Upgrade the request to a websocket
    WebSocket webSocket = await WebSocketTransformer.upgrade(request);

    /// add the userID to the text client Map
    textClients.addAll({userID: webSocket});

    /// Create and Send the Server Update packet
    SerenityUpdatePacket updatePacket = SerenityUpdatePacket(
      config.serverName,
      serverIcon,
      serverBanner,
      userList,
      config.textChannels,
      config.voiceChannels,
    );

    /// Pack the update packet in a Serenity Packet
    SerenityPacket packet = SerenityPacket(
        SerenityPacketTypeEnum.serenityUpdatePacket,
        jsonEncode(updatePacket.toMap()));

    /// Send the packet
    webSocket.add(jsonEncode(packet.toMap()));

    /// Pass the listen method to messageHandler
    ///
    /// Pass onDone to textDisconnectHandler
    webSocket.listen(
      (message) => messageHandler(userID, message),
      onDone: () => textDisconnectHandler(userID),
    );
  }

  ///
  /// Name: clientFirstConnect
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Date Last Updated: 02/12/26
  ///
  /// Function: This function handles the series of data exchanges that happen
  /// when a user first connects to the server. Then it pipes the websocket
  /// stream to the messageHandler function
  void clientFirstConnect(
      HttpRequest request, String userID, String userPAT) async {
    /// Upgrade the request to a websocket
    WebSocket webSocket = await WebSocketTransformer.upgrade(request);

    /// add the userID to the text client Map
    textClients.addAll({userID: webSocket});

    /// Create the Init Packet
    SerenityInitPacket initPacket = SerenityInitPacket(
        config.serverName,
        serverIcon,
        serverBanner,
        userID,
        userPAT,
        userList,
        config.textChannels,
        config.voiceChannels);

    /// Send the Init Packet
    webSocket.add(SerenityPacket(SerenityPacketTypeEnum.serenityInitPacket,
        jsonEncode(initPacket.toMap())));

    /// Wipe the userPAT just in case
    userPAT = "";

    /// Pipe the listen method to the messageHandler
    ///
    /// onDone method is sent to textDisconnectHandler
    webSocket.listen((message) => messageHandler(userID, message),
        onDone: () => textDisconnectHandler(userID));
  }

  void messageHandler(String userID, dynamic message) {
    SerenityPacket packet = SerenityPacket.fromMap(jsonDecode(message));

    /// Switch on the packet type
    switch (packet.type) {
      /// If the type is text, then pass the userID and text data to the
      case SerenityPacketTypeEnum.text:
        writeTextHandler(userID, packet.data);
        break;

      /// If the type is userInfo, pass the user data to the user update Handler
      case SerenityPacketTypeEnum.userInfo:
        userUpdateHandler(
            userID, SerenityUser.fromMap(jsonDecode(packet.data)));
        break;
      default:
        break;
    }
  }

  /// Name: textDisconnectHandler
  ///
  /// Date Last Updated: 02/12/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function removes the client of the textclient map
  ///
  /// It might do more in the future
  void textDisconnectHandler(String userID) {
    textClients.remove(userID);
  }

  /// Name: userUpdateHandler
  ///
  /// Date Last Updated: 02/12/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function checks the userInfo is the same as the sending
  /// user. If it is, then it updates the userInformation and sends the new user
  /// info to the rest of the current clients.
  void userUpdateHandler(String userID, SerenityUser userInfo) {
    /// is the userIDs do not match, simply return.
    if (userID != userInfo.userID) {
      return;
    }

    /// Then find the endex of that user
    int indexOfOldUser = userList.indexWhere((user) => user.userID == userID);

    /// Then replace the user
    userList[indexOfOldUser] = userInfo;

    /// Then, make sure to save all of the userData to their server file
  }

  /// Name: writeTextData
  ///
  /// Date Last Updated: 02/12/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function is called by the .listen
  /// function on the websockets. It replicates the data to
  /// the rest of the clients on the server.
  void saveUserData(SerenityUser user) {
    asdasd
  }

  /// Name: writeTextData
  ///
  /// Date Last Updated: 02/12/26
  ///
  /// Last Updater: Parker DelBene
  ///
  /// Function: This function is called by the .listen
  /// function on the websockets. It replicates the data to
  /// the rest of the clients on the server.
  void writeTextHandler(String userID, dynamic message) {
    textClients.forEach((client, webSocket) {
      if (userID != client) {
        webSocket.add(jsonEncode(
            SerenityPacket(SerenityPacketTypeEnum.text, message).toMap()));
      }
    });
  }
}
