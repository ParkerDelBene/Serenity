import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';

class MicrophoneRecorder {
  MicrophoneRecorder() {
    _startStream();
  }

  static final int MAXINT16 = 32767;

  final AudioRecorder _microphone = AudioRecorder();
  bool listening = false;
  bool status = false;
  late Stream<Uint8List> _internalMicrophoneStream;
  late Timer _voiceTimeoutTimer =
      Timer(_timeoutDuration, _voiceTimeoutCallback);
  bool _voiceActivity = false;
  final Duration _timeoutDuration = Duration(milliseconds: 500);

  double _gatePercentage = .02;
  double _gainPercentage = 1.5;
  InputDevice _device = InputDevice(id: "0", label: "Default");

  void initMicrophone() {}

  Future<List<InputDevice>> getInputDevices() async {
    return await _microphone.listInputDevices();
  }

  void setInputDevice(InputDevice device) {
    _device = device;
  }

  double getVoiceGatePercentage() {
    return _gatePercentage;
  }

  void setVoiceGatePercentage(double percentage) {
    _gatePercentage = percentage;
  }

  double getVoiceGainPercentage() {
    return _gainPercentage;
  }

  void setVoiceGainPercentage(double percentage) {
    _gainPercentage = percentage;
  }

  Future<bool> _startStream() async {
    // If we don't have permission return false;
    if (!await _microphone.hasPermission()) {
      return false;
    }

    _internalMicrophoneStream = _gainStream(
        await _microphone.startStream(RecordConfig(device: _device)));

    return true;
  }

  Future<bool> stopStream() async {
    // If we don't have permission return false;
    if (!await _microphone.hasPermission()) {
      return false;
    }

    // Stop the recording
    _microphone.stop();
    return true;
  }

  void dispose() {
    _microphone.dispose();
  }

  Stream<Uint8List> _gainStream(Stream<Uint8List> input) {
    return input.asBroadcastStream().expand((bytes) {
      // We use expand to effectively "filter" by returning an empty iterable
      // if the condition isn't met, or a single-item iterable if it is.

      final view = bytes.buffer.asInt16List();
      for (int value in view) {
        /// Apply Gain
        value = (value * _gainPercentage).clamp(-MAXINT16, MAXINT16).toInt();
      }

      return [bytes];
    });
  }

  Stream<Uint8List> ungatedAudio() {
    return _internalMicrophoneStream;
  }

  /// Processes a stream of byte arrays, only emitting those containing
  /// a Uint16 value exceeding the threshold.
  Stream<Uint8List> gatedAudio() {
    return _internalMicrophoneStream.expand((bytes) {
      // We use expand to effectively "filter" by returning an empty iterable
      // if the condition isn't met, or a single-item iterable if it is.

      if (_containsValueAboveThreshold(bytes.buffer)) {
        _voiceActivity = true;
        _voiceTimeoutTimer.cancel();
        _voiceTimeoutTimer = Timer(_timeoutDuration, _voiceTimeoutCallback);
        return [bytes];
      }

      if (_voiceActivity) {
        return [bytes];
      }

      return [];
    });
  }

  bool _containsValueAboveThreshold(ByteBuffer bytes) {
    // Uint16View allows you to read 2-byte chunks as unsigned 16-bit integers
    int threshold = (_gatePercentage * MAXINT16).toInt();
    final view = bytes.asInt16List();
    for (int value in view) {
      /// Apply Gain
      value = (value * _gainPercentage).toInt();
      if (value > threshold || value < -threshold) return true;
    }
    return false;
  }

  void _voiceTimeoutCallback() {
    _voiceActivity = false;
  }
}
