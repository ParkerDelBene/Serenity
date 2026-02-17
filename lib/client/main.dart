import 'dart:io';

import 'package:flutter/material.dart';
import 'package:serenity/client/view_dashboard.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/view_serenity_server.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth != 0) {
          return MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const MainPage(),
          );
        }
        return Container();
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    loadServers();

    Size maxSize = MediaQuery.sizeOf(context);
    if (!screenSizeInitialized) {
      maxScreenHeight = maxSize.height;
      maxScreenWidth = maxSize.width;
      screenSizeInitialized = true;
    }

    return Dashboard();
  }

  /*
    Load the servers from the server directory.

    Checks to see if ther server directory exists, if it does then it loads the 
    servers present. If it doesn't it assumes that the client is not a part of 
    any servers.
  */
  void loadServers() {
    Directory serversDirectory = Directory('./servers');
    bool serversDirectoryCreated = serversDirectory.existsSync();
    List<FileSystemEntity> listOfServers = [];

    // Check to see if the serverDirectory has been created.
    if (!serversDirectoryCreated) {
      return;
    }

    listOfServers = serversDirectory.listSync(followLinks: false);

    //Find all of the directories
    for (FileSystemEntity entity in listOfServers) {
      if (entity is! Directory) {
        listOfServers.remove(entity);
      } else {
        serverList.add(SerenityServer.fromDirectory(entity));
      }
    }
  }
}
