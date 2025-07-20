import 'package:flutter/material.dart';
import 'package:serenity/audio_output.dart';
import 'package:serenity/globals.dart';
import 'package:serenity/microphone_recorder.dart';
import 'package:serenity/serenity_server.dart';

class ServerView extends StatefulWidget {
  ServerView({super.key});

  final MicrophoneRecorder mic = MicrophoneRecorder();
  final AudioOutput output = AudioOutput();
  final SerenityServer server = SerenityServer('192.168.0.38',null,'', '', 'Bruno');

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
            Container(
              width: screenWidth * .08,
              height: screenHeight,
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Center(
                child: SingleChildScrollView(child: ListBody(),),
              )
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blue,
                      child: InkWell(
                        onTap: () async {
                         
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
