import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class Connection {
  Connection(this.server)
      : socket = WebSocketChannel.connect(
          Uri.parse(server),
        ) {
    listener = socket.stream;
  }

  String server;
  WebSocketChannel socket;
  late Stream listener;

  void writeSocket(String type, dynamic data) {
    String message = jsonEncode(<String, dynamic>{'type': type, 'data': data});

    socket.sink.add(message);
  }

  void disconnect() {
    socket.sink.close();
  }

  void attachListener(Function function) {
    listener.listen((data) {
      function(data);
    });
  }
}
