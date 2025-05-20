import 'dart:typed_data';

import 'package:record/record.dart';


class MicrophoneRecorder {
  MicrophoneRecorder();

  final AudioRecorder microphone = AudioRecorder();
  late Stream<Uint8List> audioStream;
  InputDevice device = InputDevice(id: '0', label: 'Default');

  Future<List<InputDevice>> getInputDevices() async {
    return await microphone.listInputDevices();
  }

  Future<bool> startStream() async {
    // If we don't have permission return false;
    if (!await microphone.hasPermission()) {
      return false;
    }

    //Start the audio Stream from the microphone selected
    /*
      If device.id == '0', start the stream with the system
      default device
    */
    
    if (device.id == '0') {
      
      audioStream = await microphone.startStream(RecordConfig());
      return true;
    }

    audioStream = await microphone.startStream(RecordConfig(device: device));
    return true;
  }

  Future<bool> stopStream() async {
    // If we don't have permission return false;
    if (!await microphone.hasPermission()) {
      return false;
    }

    // Stop the recording
    microphone.stop();
    return true;
  }

  void dispose() {
    microphone.dispose();
  }
}
