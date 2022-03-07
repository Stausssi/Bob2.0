import 'package:bob/constants.dart';
import 'package:flutter/material.dart';

class MicrophoneCircle extends StatelessWidget {
  const MicrophoneCircle(
      {Key? key, required this.clickCallback, this.size = 40})
      : super(key: key);

  final Function() clickCallback;
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
