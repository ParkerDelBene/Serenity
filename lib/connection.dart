import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class Connection {
  Connection(String server)
      : socket = WebSocketChannel.connect(Uri.parse(server)) {
    listener = socket.stream;
    listener.listen((data) {});
  }

  WebSocketChannel socket;
  late Stream listener;

  void writeSocket(String message) {
    socket.sink.add(message);
  }

  void parseConnection(dynamic data) {}
}
