
class SerenityConfig {
  SerenityConfig(
    this.serverName,
    this.serverAddress,
    this.password,
    this.assetDirectory,
    this.usersDirectory,
    this.chatsDirectory,
    this.keysDirectory,
    this.textChannels,
    this.voiceChannels,
    this.useSSL,
    this.saveContent,
    this.port,
  );

  SerenityConfig.fromMap(Map<String, dynamic> map)
      : serverName = map['serverName'],
        serverAddress = map['serverAddress'],
        password = map['password'],
        assetDirectory = map['assetDirectory'],
        usersDirectory = map['usersDirectory'],
        chatsDirectory = map['chatsDirectory'],
        keysDirectory = map['keysDirectory'],
        textChannels = List<String>.from(map['textChannels']),
        voiceChannels = List<String>.from(map['voiceChannels']),
        useSSL = map['useSSL'],
        saveContent = map['saveContent'],
        port = map['port'];

  String serverName;
  String serverAddress;
  String password;
  String assetDirectory;
  String usersDirectory;
  String chatsDirectory;
  String keysDirectory;
  List<String> textChannels;
  List<String> voiceChannels;
  bool useSSL;
  bool saveContent;
  int port;

  static final defaultData = {
    "serverName": "DefaultServer",
    "serverAddress": "0.0.0.0",
    "password": "",
    "assetDirectory": "./assets",
    "usersDirectory": "./users",
    "chatsDirectory": "./chats",
    "keysDirectory": "./keys",
    "textChannels": ["general"],
    "voiceChannels": ["general"],
    "useSSL": false,
    "saveContent": false,
    "port": 12345,
  };

  /*
    Returns the Config File as a Map so it can be JSON Encoded.
  */
  Map<String, dynamic> toMap() {
    return {
      "serverName": serverName,
      "serverAddress": serverAddress,
      "password": password,
      "assetDirestory": assetDirectory,
      "usersDirectory": usersDirectory,
      "chatsDirectory": chatsDirectory,
      "textChannels": textChannels,
      "voiceChannels": voiceChannels,
      "useSSL": useSSL,
      "saveContent": saveContent,
      "port": port,
    };
  }
}
