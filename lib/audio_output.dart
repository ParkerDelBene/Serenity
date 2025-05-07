import 'dart:collection';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

class AudioOutput {
  /*
    Constructor for the AudioOutput

    Generates a queue of AudioPlayers that get cycled
    through the play sounds coming in from the network
    stream.
  */
  AudioOutput() {
    playerQueue = Queue<AudioPlayer>();

    for (int i = 0; i < numPlayers; i++) {
      playerQueue.add(AudioPlayer());
    }
  }

  static const numPlayers = 32;

  late final Queue<AudioPlayer> playerQueue;

  void playBytes(Uint8List bytes) {
    AudioPlayer temp = playerQueue.removeFirst();
    temp.play(BytesSource(bytes), mode: PlayerMode.lowLatency);
    playerQueue.addLast(temp);
  }
}
