import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:serenity/client/data/communication/serenityclient_user.dart';
import 'package:serenity/client/globals.dart';
import 'package:serenity/client/views/pages/dashboard.dart';
import 'package:serenity/client/views/pages/serenity_server.dart';

/// A reusable widget that displays a loading indicator in the center of the screen.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    Size maxSize = MediaQuery.sizeOf(context);
    if (!screenSizeInitialized) {
      maxScreenHeight = maxSize.height;
      maxScreenWidth = maxSize.width;
      screenSizeInitialized = true;

      smallImageIconSize = maxScreenWidth * serverIconRatio;
      largeImageIconSize = maxScreenWidth * serverIconRatio * 2;
    }

    return MaterialApp(
        theme: ThemeData(
          primaryColor: primaryColor,
          highlightColor: highlightColor,
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: WidgetStatePropertyAll(secondaryColor),
          ),
          useMaterial3: true,
        ),
        home: loaded ? Dashboard() : _loadingScreen());
  }

  Widget _loadingScreen() {
    return Scaffold(
      body: Center(
        child: Image.network(
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExYzA3djRjMGgzOGFqbGVyeDd4ZDNsMGp4cmg4ZWgyazAwaHVocjUwOSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/MydKZ8HdiPWALc0Lqf/giphy.gif',
          height: 200,
          width: 200,
          // Fallback if the image fails to load
          errorBuilder: (context, error, stackTrace) =>
              const CircularProgressIndicator(),
        ),
      ),
    );
  }

  void loadData() async {
    await getApplicationDirectory();
    loadLocalUser();
    loadServers();

    if (mounted) {
      setState(() {
        loaded = true;
      });
    }
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
  Directory localUserDirectory = Directory("${applicationDirectory.path}/user");
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

  localUser = SerenityClientUser(
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
  Directory serversDirectory =
      Directory('${applicationDirectory.path}/servers');
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

Future<void> getApplicationDirectory() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  applicationDirectory = Directory("${documentsDirectory.path}/Serenity")
    ..createSync();
}
