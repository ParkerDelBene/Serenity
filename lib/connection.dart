import 'package:web_socket_channel/web_socket_channel.dart';

class Connection {
  Connection()
      : socket = WebSocketChannel.connect(
          Uri.parse("ws://192.168.0.38:12345"),
        ) {
    _listener = socket.stream;
    _sink = socket.sink;
  }

  WebSocketChannel socket;
  late Stream _listener;
  late WebSocketSink _sink;

  void writeSocket(dynamic message) {
    socket.sink.add(message);
  }

  void disconnect() {
    socket.sink.close();
  }

  Stream<dynamic> getSocketStream(){
    return _listener;
  }

  WebSocketSink getSocketSink(){
    return _sink;
  }
  
}
