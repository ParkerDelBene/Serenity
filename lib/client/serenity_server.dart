import 'package:flutter/material.dart';
import 'package:serenity/client/connection.dart';

class SerenityServer extends StatelessWidget {
  const SerenityServer(this.uri, this.port, this.pathToImage, this.pathToConfig,
      this.serverName, this.connection,
      {super.key});

  final String uri;
  final String? port;
  final String pathToImage;
  final String pathToConfig;
  final String serverName;
  final double scale = .80;
  final Connection connection;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: 100,
      height: 100,
      color: Colors.amber,
      child: Center(
        child: Text(serverName),
      ),
    );
  }

  void initialize() {}
}
