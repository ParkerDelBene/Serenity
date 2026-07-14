import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:serenity/client/data/microphone_recorder.dart';

class VoiceGateVolumeVisualizer extends StatelessWidget {
  final Stream<Uint8List> audioStream;

  const VoiceGateVolumeVisualizer({
    super.key,
    required this.audioStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Uint8List>(
      stream: audioStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final view = snapshot.data!.buffer.asInt16List();
        int maxPeak = 0;

        for (int sample in view) {
          if (sample.abs() > maxPeak) maxPeak = sample.abs();
        }

        // Map intensity 0.0 to 1.0
        final double intensity =
            (maxPeak / MicrophoneRecorder.MAXINT16).clamp(0.0, 1.0);

        // Interpolate between Blue (Low) and Red/Yellow (High)
        final Color baseColor = Color.lerp(Colors.blue, Colors.red, intensity)!;

        return Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [baseColor, baseColor.withValues(alpha: 0.5)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FractionallySizedBox(
              widthFactor: intensity,
              alignment: Alignment.centerLeft,
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [baseColor, baseColor.withValues(alpha: 1.5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  border: Border.all(color: Colors.white24),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
