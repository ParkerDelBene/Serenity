import 'package:web_socket_channel/web_socket_channel.dart';

class Connection {
  Connection(String uri, String? port)
      : _messageSocket = WebSocketChannel.connect(
          Uri.parse("ws://$uri:${port ?? '12345'}?type=text"),
        ) {
    _messageStream = _messageSocket.stream;
    _messageSink = _messageSocket.sink;
  }

  late WebSocketChannel _voiceSocket;
  final WebSocketChannel _messageSocket;
  late Stream _messageStream;
  late WebSocketSink _messageSink;
  late WebSocketSink _voiceSink;
  late Stream _voiceStream;

  void writeMessageSocket(String message) {
    _messageSink.add(message);
  }

  void disconnectVoice() {
    _voiceSocket.sink.close();
  }

  Future<bool> connectVoice(String uri, String? port, String channel) async{
    try{
      _voiceSocket = WebSocketChannel.connect(Uri.parse("ws://$uri:${port ?? '12345'}}"));
    
      await _voiceSocket.ready;
    }
    catch(e){
      return false;
    }

    _voiceSocket.sink.add(channel);
    
    _voiceSink = _voiceSocket.sink;
    _voiceStream = _voiceSocket.stream;
    
    return true;
  }

  Stream<dynamic> getMessageSocketStream(){
    return _messageStream;
  }


  void writeVoiceSocket(dynamic data){
    _voiceSink.add(data);
  }

  Stream<dynamic> getVoiceSocketStream(){
    return _voiceStream;
  }
  
}
