import 'package:flutter/material.dart';
import 'package:serenity/audio_output.dart';
import 'package:serenity/connection.dart';
import 'package:serenity/globals.dart';
import 'package:serenity/microphone_recorder.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ServerView extends StatefulWidget {
  ServerView({super.key});

  final MicrophoneRecorder mic = MicrophoneRecorder();
  final AudioOutput output = AudioOutput();
  final Connection server = Connection();

  @override
  State<ServerView> createState() => _ServerViewState();
}

class _ServerViewState extends State<ServerView> {
  @override
  Widget build(BuildContext context) {
    /*
      Query the current screen size so we can
      scale the UI from that.
    */
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Row(
          children: [
            SizedBox(
              width: screenWidth * .08,
              child: Column(
                children: [
                  Expanded(
                      child: Container(
                    color: Colors.green,
                  ))
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blue,
                      child: InkWell(
                        onTap: () async {
                          await widget.mic.startStream();
                          WebSocketSink serverSink =widget.server.getSocketSink();

                          widget.mic.audioStream.listen((data) {
                            serverSink.add(data);
                          });

                          widget.output.addStream(widget.server.getSocketStream());
                        },
                        child: Text('Click to Record Playback'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth * .125,
              child: Column(
                children: [
                  Expanded(
                      child: Container(
                    color: Colors.purple,
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
