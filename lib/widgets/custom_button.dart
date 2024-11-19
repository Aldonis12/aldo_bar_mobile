import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.023, vertical: screenHeight * 0.011),
        textStyle: TextStyle(fontSize: screenHeight * 0.020),
      ),
    );
  }
}
