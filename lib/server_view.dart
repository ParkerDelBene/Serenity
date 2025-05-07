import 'package:flutter/material.dart';
import 'package:serenity/audio_output.dart';
import 'package:serenity/globals.dart';
import 'package:serenity/microphone_recorder.dart';

class ServerView extends StatefulWidget {
  ServerView({super.key});

  final MicrophoneRecorder mic = MicrophoneRecorder();
  final AudioOutput output = AudioOutput();

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

                          widget.mic.audioStream.listen((data) {
                            widget.output.playBytes(data);
                          });
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
