import 'package:flutter/material.dart';

class SectionHeading extends StatelessWidget {
  final String headingText;
  const SectionHeading({super.key, required this.headingText});

  @override
  Widget build(BuildContext context) {
    return Text(
      headingText,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black,
      ),
    );
  }
}
