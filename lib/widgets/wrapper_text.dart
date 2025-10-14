import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomWrapperTexts extends StatelessWidget {
  final String title;
  final Color textColor;
  final FontWeight textWeight;
  final double textSize;
  final double wrapperWidth;
  final double wrapperHeight;
  final double verticalPadding;
  final double horizontalPadding;

  const CustomWrapperTexts({
    super.key,
    required this.title,
    required this.textColor,
    required this.textSize,
    required this.textWeight,
    required this.wrapperHeight,
    required this.wrapperWidth,
    required this.horizontalPadding,
    required this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: wrapperWidth,
      height: wrapperHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: textSize,
            fontWeight: textWeight,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
