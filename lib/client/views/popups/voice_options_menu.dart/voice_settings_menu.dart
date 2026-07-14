import 'package:flutter/material.dart';
import 'package:serenity/client/data/microphone_recorder.dart';
import 'package:serenity/client/views/popups/voice_options_menu.dart/microphone_testing_widget.dart';

class VoiceSettingsMenu extends StatelessWidget {
  final MicrophoneRecorder microphone = MicrophoneRecorder();

  @override
  Widget build(BuildContext context) {
    return MicrophoneTestingWidget();
  }

  void setVoiceGatePercentage(double value) {
    microphone.setVoiceGatePercentage(value);
  }
}
