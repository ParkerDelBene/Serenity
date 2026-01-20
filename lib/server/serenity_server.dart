import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'serenity_config.dart';

class SerenityServer {
  SerenityServer(this.server);
  HttpServer server;
  String errorString = "";
  List<WebSocket> textClients = [];
  HashMap<String, List<WebSocket>> voiceChannels = HashMap();
  SerenityConfig config = SerenityConfig('NUll', [], [], false, 0);

  Future<bool> initialize() async {
    /*
      Run the startup chekc to verify all of the server directories have been
      created and that the server config file is formatted correctly.
    */
    if (!await startupCheck()) {
      print('Failed Startup Check');
      return false;
    }

    /*
      Listen Function checks the query type and pushes the 
      request to the correct function, or drops it.
    */
    server.listen(
      (HttpRequest request) async {
        /*
        Get the type of request,

        Text types are the initial that handle all incoming text
        Voice connects to a specific channel.
      */
        String? type = request.uri.queryParameters['type'];
        String? userID = request.uri.queryParameters['userID'];
        String? password = request.uri.queryParameters['password'];
        InternetAddress? requestIP = request.connectionInfo?.remoteAddress;

        bool clientData = false;

        /*
          Verify the Remote address is not null
        */
        if (requestIP == null) {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.reasonPhrase = 'Invalid Request Type';
          request.response.flush();
          request.response.close();
          return;
        }

        /*
          Verify the userID is not null
        */
        if (userID == null) {
          request.response.statusCode = HttpStatus.unauthorized;
          request.response.reasonPhrase = 'Invalid Request Type';
          request.response.flush();
          request.response.close();
          return;
        }

        /*
          Check if the user has client Data.

          If no Client Data then check the userID is empty and generate User Data
        */
        clientData = await checkClientData(userID);

        if (!clientData) {
          /*
            If the request supplied a userID, then we return an invalid User Data Error
          */
          if (userID.isNotEmpty) {
            request.response.statusCode = HttpStatus.unauthorized;
            request.response.reasonPhrase = 'Invalid User Data';
            request.response.flush();
            request.response.close();
            return;
          }
          /*
            Generate the userID
          */
          userID = await generateClientData();
        }

        switch (type) {
          case 'text':
            clientTextConnect(request, userID);
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
      },
      onDone: () {},
      onError: (e) {
        print(e.toString());
      },
    );

    return true;
  }

  /*
    Name: startupCheck

    Date Last Updated: 01/20/26

    Last Updater: Parker DelBene

    Function: This consolidates all of the initialization checks into one function
  */
  Future<bool> startupCheck() async {
    bool configCheck = await readConfig();

    if (!configCheck) {
      return false;
    }

    bool userCheck = await validateUserDirectory();

    if (!userCheck) {
      return false;
    }

    return true;
  }

  /*
    Name: readConfig

    Date Last Updated: 7/17/25

    Last Updater: Parker DelBene

    Function: reads the server.config file and initializes the SerenityConfig variable
  */
  Future<bool> readConfig() async {
    Directory configDirectory = Directory('./config');
    bool configExists = await configDirectory.exists();

    /*
      If the config directory does not exist, create the directory,
      then create the config File, and then populate the config file
      with the default values.
    */
    if (!configExists) {
      configDirectory = await configDirectory.create();
      File configFile = File('${configDirectory.path}/server.config');
      configFile = await configFile.create();
      await configFile.writeAsString(jsonEncode(config.defaultData));
    }

    /*
      Read the File as a string, parse the json, and load the config into
      the config variable.
    */
    File configFile = File('${configDirectory.uri}server.config');
    String configString = await configFile.readAsString();

    /*
      Wrap in try catch because some people may incorrectly format 
      their server.config
    */
    try {
      var jsonConfig = jsonDecode(configString);
      config = SerenityConfig(
        jsonConfig[0]['serverName'],
        List<String>.from(jsonConfig[0]['textChannels']),
        List<String>.from(jsonConfig[0]['voiceChannels']),
        jsonConfig[0]['saveContent'],
        jsonConfig[0]['port'],
      );
    } catch (e) {
      print(e);
      print('Error in Config File');
      return false;
    }

    return true;
  }

  /*
    Name: validateUserDirectory

    Date Last Updated: 01/20/26

    Last Updater: Parker DelBene

    Function: Checks if the user Directory has been created, if not, it creates it.
  */
  Future<bool> validateUserDirectory() async {
    Directory userDirectory = Directory('./users');
    bool userExists = await userDirectory.exists();

    if (!userExists) {
      try {
        userDirectory = await userDirectory.create();
      } catch (e) {
        print(e);
        print('Error creating User Directory');

        return false;
      }
    }

    return true;
  }

  /*
    Name: checkClientData

    Date Last Updated: 11/17/25

    Last Updater: Parker DelBene

    Function: checks if there is available clientData
  */
  Future<bool> checkClientData(String userID) async {
    Directory userDirectory = Directory('./users');
    bool userExists = await userDirectory.exists();

    userDirectory = Directory('./user/$userID');
    userExists = await userDirectory.exists();

    if (!userExists) {
      return false;
    }

    return true;
  }

  /*
    Name: generateClientData

    Date Last Updated: 11/17/25

    Last Updater: Parker DelBene
    
    Function: Handles Generating the unique userID
  */
  Future<String> generateClientData() async {
    //Create the userID based on Time.
    String userID = Uuid().v1();

    //Create the user's Directory to store their data.
    Directory userDirectory = Directory('./users/$userID');
    userDirectory = Directory('./user/$userID');
    userDirectory = await userDirectory.create();

    return userID;
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

  /*
    Name: clientTextConnect

    Date Last Updated: 7/17/25

    Last Updater: Parker DelBene
    
    Function: Handles the initial text connection and handshake
  */
  void clientTextConnect(HttpRequest request, String userID) {
    WebSocketTransformer.upgrade(request).then((webSocket) {
      textClients.add(webSocket);

      /*
        Send the UUID as the first message, for UUID validation
      */
      webSocket.add("UUID;$userID");
      /*
        Send the Server Config as the Second message so they can initialize the
        Interface on their side.
      */
      webSocket.add("ServerConfig;${jsonEncode(config.toMap())}");
      /*
        Replicate the data to the rest of the clients
      */
      webSocket.listen(
        (message) {
          writeTextData(webSocket, message);
        },

        onDone: () {
          textClients.remove(webSocket);
        },
      );
    });
  }

  /*
    Name: writeTextData

    Date Last Updated: 7/17/25

    Last Updater: Parker DelBene

    Function: This function is called by the .listen
      function on the websockets. It replicates the data to 
      the rest of the clients on the server.
  */
  void writeTextData(WebSocket sender, dynamic message) {
    for (WebSocket client in textClients) {
      if (client != sender) {
        client.add(message);
      }
    }
  }
}
