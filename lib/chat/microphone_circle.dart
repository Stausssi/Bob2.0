import 'package:bob/util.dart';
import 'package:flutter/material.dart';

/// Displays a round button with a microphone icon in the middle
class MicrophoneCircle extends StatelessWidget {
  const MicrophoneCircle(
      {Key? key, required this.clickCallback, this.size = 40})
      : super(key: key);

  /// Called after the button was clicked
  final Function() clickCallback;

  /// The size of the icon
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: CustomColors.purpleForeground,
        shape: BoxShape.circle,
      ),
      child: GestureDetector(
        onTap: clickCallback,
        child: Icon(
          Icons.mic,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }
}
