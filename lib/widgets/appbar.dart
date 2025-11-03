import 'package:flutter/material.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            SizedBox(
              height: 42,
              width: 51,
              child: Image.asset('assets/edify2.png'),
            ),
            CustomTexts(
              title: 'edifyLMS',
              textColor: AppColors.primaryAppbarBlack,
              textSize: 20,
              textWeight: FontWeight.w500,
              textAlignment: AlignmentGeometry.centerLeft,
            ),
          ],
        ),
      ],
    );
  }
}
