import 'package:flutter/material.dart';

/// A reusable slider component specifically designed for controlling
/// audio parameters like the "Voice Gate".
class VoiceControlSlider extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final Function(double) onChangedEnd;
  final String label;

  const VoiceControlSlider({
    super.key,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.onChangedEnd,
    this.label = "Voice Gate",
  });

  @override
  State<VoiceControlSlider> createState() => _VoiceControlSliderState();
}

class _VoiceControlSliderState extends State<VoiceControlSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: _currentValue,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          label: "${(_currentValue)}",
          activeColor: Theme.of(context).primaryColorLight,
          secondaryActiveColor: Theme.of(context).highlightColor,
          inactiveColor: Theme.of(context).primaryColor,
          onChanged: (double value) {
            setState(() {
              _currentValue = value;
            });
          },
          onChangeEnd: (double value) => widget.onChangedEnd(value),
        ),
      ],
    );
  }
}
