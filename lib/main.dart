import 'dart:io';

import 'package:flutter/material.dart';
import 'package:serenity/client/view_dashboard.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/view_serenity_server.dart';
import 'package:serenity/server/class_serenity_user.dart';

void main() {
  loadServers();
  loadLocalUser();
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
    Size maxSize = MediaQuery.sizeOf(context);
    if (!screenSizeInitialized) {
      maxScreenHeight = maxSize.height;
      maxScreenWidth = maxSize.width;
      screenSizeInitialized = true;
    }

    return Dashboard();
  }
}

/// Name: loadLocalUser
///
/// Date Last Update: 02/23/26
///
/// Last Updater: Parker DelBene
///
/// Function: If the local user data exists, it loads the data. If it does not,
/// it creates the standard user files.
void loadLocalUser() {
  Directory localUserDirectory = Directory("./user");
  File localUsernameFile = File("${localUserDirectory.path}/userName");
  File localUserIconFile = File("${localUserDirectory.path}/userIcon.jpg");
  File localUserBannerFile = File("${localUserDirectory.path}/userBanner.jpg");

  /// if the user directory does not exist, create the defaults
  if (!localUserDirectory.existsSync()) {
    localUserDirectory.createSync();
    localUsernameFile.createSync();

    localUsernameFile.writeAsString("defaultusername");
  }

  localUserBannerFile.createSync();
  localUserIconFile.createSync();

  localUser = SerenityUser(
      "",
      localUsernameFile.readAsStringSync(),
      localUserIconFile.readAsBytesSync(),
      localUserBannerFile.readAsBytesSync());
}

/*
  /// Load the servers from the server directory.
  /// 
  /// Checks to see if ther server directory exists, if it does then it loads the 
  /// servers present. If it doesn't it assumes that the client is not a part of 
  /// any servers.
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
