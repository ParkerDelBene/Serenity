import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  final wsURL = Uri.parse("ws://192.168.0.39:12345?type=text&userID=");
  final webSocket = WebSocketChannel.connect(wsURL);

  webSocket.stream.listen((message) {
    print(message);
  });

  stdin.listen((message) {
    webSocket.sink.add(String.fromCharCodes(message));
  });
}
