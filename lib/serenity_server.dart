import 'dart:io';

import 'package:flutter/material.dart';
import 'package:serenity/connection.dart';

class SerenityServer extends StatelessWidget{
  SerenityServer(this.uri,this.port,this.pathToImage,this.pathToConfig,this.serverName,{super.key}): connection = Connection(uri, port);

 

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

     return CircleAvatar(
      backgroundImage: pathToImage == '' ? null : FileImage(File(pathToImage)),
      maxRadius: size.width * scale,
      child: pathToImage == '' ? Text(serverName) : null,
    );
  }
  
}