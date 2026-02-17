import 'dart:io';

import 'class_serenity_server.dart';

void main() async {
  print('Server Starting');
  SerenityServer server = SerenityServer();

  /*
    Initialize the server, end program if server failed to initialize
  */
  if (!await server.initialize()) {
    print("Server Failed to initialize");
    return;
  }

  print('Server Initialized');

  stdin.listen((input) {
    serverCommandLine(String.fromCharCodes(input));
  });
}

void serverCommandLine(String input) {
  stdout.write(input);
}
