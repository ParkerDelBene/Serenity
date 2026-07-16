import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';

class AudioOutput {
  AudioOutput();

  final SoLoud _soloud = SoLoud.instance;
  final List<AudioSource> _audioStreams = [];

  AudioSource addStreamAudioSource(int sampleRate, double volume) {
    AudioSource audioSource = _soloud.setBufferStream(
        bufferingTimeNeeds: 1,
        bufferingType: BufferingType.released,
        sampleRate: sampleRate,
        channels: Channels.stereo);

    _soloud.play(audioSource, volume: volume);

    return audioSource;
  }

  void removeAudioStreamSource(AudioSource source) {
    _audioStreams.remove(source);
  }

  void addAudioDataToStream(AudioSource source, Uint8List data) {
    _soloud.addAudioDataStream(source, data);
  }
}
