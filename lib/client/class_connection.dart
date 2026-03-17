import 'package:web_socket_channel/web_socket_channel.dart';

class Connection {
  /// Initialize with the uri, port, userID, and userPAT
  Connection.withUserID(this.uri, this.port, this.userID, this.userPAT);

  /// Initialize with the uri, port, and password
  Connection.withPassword(this.uri, this.port, this.password)
      : userID = "",
        userPAT = "";

  final String uri;
  final String port;
  final String userID;
  final String userPAT;
  String password = "";
  late bool connected;
  late WebSocketChannel _voiceSocket;
  late WebSocketChannel _messageSocket;
  late Stream _messageStream;
  late WebSocketSink _messageSink;
  late WebSocketSink _voiceSink;
  late Stream _voiceStream;

  Future<bool> connect() async {
    try {
      _messageSocket = WebSocketChannel.connect(
        Uri.parse(
            "ws://$uri:$port?type=text&userID=$userID&userPAT=$userPAT&password=$password"),
      );
      await _messageSocket.ready;
      _messageStream = _messageSocket.stream.asBroadcastStream();
      _messageSink = _messageSocket.sink;
      connected = true;
    } catch (e) {
      connected = false;
      return false;
    }

    return true;
  }

  void writeMessageSocket(String message) {
    _messageSink.add(message);
  }

  void disconnectVoice() {
    _voiceSocket.sink.close();
  }

  Future<bool> connectVoice(String uri, String? port, String channel) async {
    try {
      _voiceSocket =
          WebSocketChannel.connect(Uri.parse("ws://$uri:${port ?? '12345'}}"));

      await _voiceSocket.ready;
    } catch (e) {
      return false;
    }

    _voiceSocket.sink.add(channel);

    _voiceSink = _voiceSocket.sink;
    _voiceStream = _voiceSocket.stream;

    return true;
  }

  Stream<dynamic> getMessageSocketStream() {
    return _messageStream;
  }

  void writeVoiceSocket(dynamic data) {
    _voiceSink.add(data);
  }

  Stream<dynamic> getVoiceSocketStream() {
    return _voiceStream;
  }
}
