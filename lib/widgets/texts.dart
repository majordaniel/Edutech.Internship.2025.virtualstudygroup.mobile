import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTexts extends StatelessWidget {
  final String title;
  final Color textColor;
  final FontWeight textWeight;
  final double textSize;
  final AlignmentGeometry textAlignment;

  const CustomTexts({
    super.key,
    required this.title,
    required this.textColor,
    required this.textSize,
    required this.textWeight,
    required this.textAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: textAlignment,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontStyle: FontStyle.normal,
          color: textColor,
          fontSize: textSize,
          fontWeight: textWeight,
        ),
      ),
    );
  }
}
