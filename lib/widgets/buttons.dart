import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edify_app/screens/add_participant.dart';

class CustomButtons extends StatelessWidget {
  final String buttonTitle;
  final Color textColor;
  final Color? buttonColor;
  final FontWeight textWeight;
  final double textSize;
  final double buttonHeight;
  final double buttonWidth;

  const CustomButtons({
    super.key,
    required this.buttonColor,
    required this.buttonHeight,
    required this.buttonTitle,
    required this.buttonWidth,
    required this.textColor,
    required this.textSize,
    required this.textWeight,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: buttonColor,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 21),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddParticipantPage()),
        );
      },
      child: Text(
        buttonTitle,
        style: GoogleFonts.poppins(fontSize: textSize, fontWeight: textWeight),
        textAlign: TextAlign.center,
      ),
    );
  }
}
