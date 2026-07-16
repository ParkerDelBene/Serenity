import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:serenity/client/data/audio/microphone_recorder.dart';
import 'package:serenity/client/views/popups/voice_options_menu.dart/voice_gate_control_slider.dart';
import 'package:serenity/client/views/popups/voice_options_menu.dart/voice_gate_volume_visualizer.dart';

class MicrophoneTestingWidget extends StatefulWidget {
  const MicrophoneTestingWidget({super.key});

  @override
  State<MicrophoneTestingWidget> createState() =>
      _MicrophoneTestingWidgetState();
}

class _MicrophoneTestingWidgetState extends State<MicrophoneTestingWidget> {
  bool testing = false;
  MicrophoneRecorder microphone = MicrophoneRecorder();
  late StreamSubscription audioSourceSubscription;
  late AudioSource audioSource;

  @override
  Widget build(BuildContext context) {
    if (testing) {
      return Column(
        children: [
          Center(
              child: Text(
            "VOICE GATE SLIDER",
            style: TextStyle(fontSize: 24, color: Colors.white),
          )),
          VoiceControlSlider(
              initialValue: microphone.getVoiceGatePercentage(),
              min: 0,
              max: 1.0,
              onChangedEnd: setVoiceGatePercentage),
          Center(
              child: Text(
            "VOICE GAIN SLIDER",
            style: TextStyle(fontSize: 24, color: Colors.white),
          )),
          VoiceControlSlider(
              initialValue: microphone.getVoiceGainPercentage(),
              min: 1.0,
              max: 3.0,
              onChangedEnd: setVoiceGainPercentage),
          Center(
              child: Text(
            "VOLUME VISUALIZER",
            style: TextStyle(fontSize: 24, color: Colors.white),
          )),
          VoiceGateVolumeVisualizer(audioStream: microphone.ungatedAudio()),
          TextButton(
            onPressed: () => testMicrophone(),
            child: Text("STOP"),
          )
        ],
      );
    }

    return TextButton(
      onPressed: () => testMicrophone(),
      child: Text("TEST MICROPHONE"),
    );
  }

  void testMicrophone() async {
    if (testing) {
      audioSourceSubscription.cancel();
      testing = false;
    } else {
      await SoLoud.instance.init(bufferSize: 2048);

      audioSource = SoLoud.instance.setBufferStream(
          bufferingTimeNeeds: .5,
          bufferingType: BufferingType.released,
          sampleRate: 44100,
          channels: Channels.stereo);
      SoLoud.instance.play(audioSource, volume: 2.0);

      audioSourceSubscription = microphone.getGatedAudio().listen((data) {
        SoLoud.instance.addAudioDataStream(audioSource, data);
      });

      testing = true;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void setVoiceGatePercentage(double value) {
    microphone.setVoiceGatePercentage(value);
  }

  void setVoiceGainPercentage(double value) {
    microphone.setVoiceGainPercentage(value);
  }
}
