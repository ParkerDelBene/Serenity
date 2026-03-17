/// Name SerenityClientsideConfig
///
/// Date Last Updated: 02/18/26
///
/// Last Updater: Parker DelBene
///
/// Function: This class stores the data that the client cares about when
/// interacting with the server.
///
/// serverName\n
/// serverURUI\n
/// port\n
/// userID\n
/// textChannels\n
/// voiceChannels\n
/// saveContent\n
class SerenityServerClientConfig {
  const SerenityServerClientConfig(this.serverName, this.serverURI, this.port,
      this.userID, this.textChannels, this.voiceChannels, this.saveContent);

  /// Takes in a map and initializes the variables
  SerenityServerClientConfig.fromMap(Map<String, dynamic> json)
      : serverName = json["serverName"],
        serverURI = json['serverURI'],
        port = json['port'],
        userID = json['userID'],
        textChannels = List<String>.from(json['textChannels']),
        voiceChannels = List<String>.from(json['voiceChannels']),
        saveContent = json['saveContent'];

  final String serverName;
  final String serverURI;
  final String port;
  final String userID;
  final List<String> textChannels;
  final List<String> voiceChannels;
  final bool saveContent;

  Map<String, dynamic> toJson() {
    return {
      "serverName": serverName,
      "serverURI": serverURI,
      "port": port,
      "userID": userID,
      "textChannels": textChannels,
      "voiceChannels": voiceChannels,
      "saveContent": saveContent,
    };
  }
}
