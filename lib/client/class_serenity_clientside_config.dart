import 'package:serenity/server/class_serenity_config.dart';

/// Name SerenityClientsideConfig
///
/// Date Last Updated: 02/18/26
///
/// Last Updater: Parker DelBene
///
/// Function: This class stores the data that the client cares about when
/// interacting with the server.
class SerenityClientsideConfig {
  const SerenityClientsideConfig(
      this.serverURI, this.port, this.textChannels, this.voiceChannels);

  /// Takes in a map and initializes the variables
  SerenityClientsideConfig.fromMap(Map<String, dynamic> json)
      : serverURI = json['serverURI'],
        port = json['port'],
        textChannels = List<String>.from(json['textChannels']),
        voiceChannels = List<String>.from(json['voiceChannels']);

  final String serverURI;
  final String port;
  final List<String> textChannels;
  final List<String> voiceChannels;

  Map<String, dynamic> toMap() {
    return {
      "serverURI": serverURI,
      "port": port,
      "textChannels": textChannels,
      "voiceChannels": voiceChannels,
    };
  }
}
