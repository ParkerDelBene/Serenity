class SerenityConfig {
  SerenityConfig(
    this.serverName,
    this.textChannels,
    this.voiceChannels,
    this.saveContent,
    this.port,
  );

  String serverName;
  List<String> textChannels;
  List<String> voiceChannels;
  bool saveContent;
  int port;

  final defaultData = [
    {
      "serverName": "DefaultServer",
      "textChannels": ["general"],
      "voiceChannels": ["general"],
      "saveContent": false,
      "port": 12345,
    },
  ];

  /*
    Returns the Config File as a Map so it can be JSON Encoded.
  */
  Map<String, dynamic> toMap() {
    return {
      "serverName": serverName,
      "textChannels": textChannels,
      "voiceChannels": voiceChannels,
      "saveContent": saveContent,
      "port": port,
    };
  }
}
