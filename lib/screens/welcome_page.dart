import 'package:edify_app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/widgets/wrapper_text.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.all(8.0),
        title: CustomAppbar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          //main column for body
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: CustomTexts(
                title: 'Welcome Andrew',
                textColor: AppColors.primaryOrange,
                textSize: 24,
                textWeight: FontWeight.w600,
                textAlignment: AlignmentGeometry.centerLeft,
              ),
            ),
            SizedBox(height: 24),
            Container(
              width: 396,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 21),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryProgressBlack,
                  width: 0.1,
                ),
                borderRadius: BorderRadius.circular(6),
                // boxShadow: [
                //   BoxShadow(
                //     color: AppColors.primaryProgressBlack.withOpacity(0.1),
                //     blurRadius: 10,
                //     offset: Offset(0, 4),
                //   ),
                // ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.school_outlined),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //for the two texts 2 and courses
                    children: [
                      CustomTexts(
                        title: '2',
                        textColor: AppColors.primaryBlack,
                        textSize: 17.75,
                        textWeight: FontWeight.w500,
                        textAlignment: AlignmentGeometry.centerLeft,
                      ),
                      CustomTexts(
                        title: 'Courses',
                        textColor: AppColors.primaryBlack,
                        textSize: 13.78,
                        textWeight: FontWeight.w500,
                        textAlignment: AlignmentGeometry.centerLeft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.14),
            Container(
              width: 396,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 21),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryProgressBlack,
                  width: 0.1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.school_outlined),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTexts(
                        title: '3',
                        textColor: AppColors.primaryBlack,
                        textSize: 17.75,
                        textWeight: FontWeight.w500,
                        textAlignment: AlignmentGeometry.centerLeft,
                      ),
                      CustomTexts(
                        title: 'Courses Grouping',
                        textColor: AppColors.primaryBlack,
                        textSize: 13.78,
                        textWeight: FontWeight.w500,
                        textAlignment: AlignmentGeometry.centerLeft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.14),
            Container(
              width: 396,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 21),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryProgressBlack,
                  width: 0.1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.school_outlined),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTexts(
                        title: '2',
                        textColor: AppColors.primaryBlack,
                        textSize: 17.75,
                        textWeight: FontWeight.w500,
                        textAlignment: AlignmentGeometry.centerLeft,
                      ),
                      CustomTexts(
                        title: 'Courses Grouping',
                        textColor: AppColors.primaryBlack,
                        textSize: 13.78,
                        textWeight: FontWeight.w500,
                        textAlignment: AlignmentGeometry.centerLeft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.14),
            Container(
              width: 396,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 21),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryProgressBlack,
                  width: 0.1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.school_outlined),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTexts(
                        title: '4',
                        textColor: AppColors.primaryBlack,
                        textSize: 17.75,
                        textWeight: FontWeight.w500,
                        textAlignment: AlignmentGeometry.centerLeft,
                      ),
                      CustomTexts(
                        title: 'Study Group',
                        textColor: AppColors.primaryBlack,
                        textSize: 13.78,
                        textWeight: FontWeight.w500,
                        textAlignment: AlignmentGeometry.centerLeft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.58),

            // Course progress
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 0),
              child: CustomTexts(
                title: 'Course Progress Information',
                textColor: AppColors.primaryBlack,
                textSize: 20,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.centerLeft,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                // height: 58.28,
                // width: 396,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CustomWrapperTexts(
                          title: 'Name',
                          textColor: AppColors.primaryProgressBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.bold,
                          wrapperHeight: 21.96,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 5.98,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: 'Cr 001 - Criminal Law',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: 'Cr 001 - Criminal Law',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: 'Cr 001 - Criminal Law',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        CustomWrapperTexts(
                          title: 'Assignment Completion',
                          textColor: AppColors.primaryProgressBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.bold,
                          wrapperHeight: 21.96,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 5.98,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: '0 out of 3',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: '0 out of 3',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: '0 out of 3',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        CustomWrapperTexts(
                          title: 'Quiz Completion',
                          textColor: AppColors.primaryProgressBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.bold,
                          wrapperHeight: 21.96,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 5.98,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: '0 out of 3',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: '0 out of 3',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: '0 out of 3',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        CustomWrapperTexts(
                          title: 'Forum Participation',
                          textColor: AppColors.primaryProgressBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.bold,
                          wrapperHeight: 21.96,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 5.98,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: '0 out of 3',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: '0 out of 3',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                        SizedBox(height: 9),
                        CustomWrapperTexts(
                          title: '0 out of 3',
                          textColor: AppColors.primaryBlack,
                          textSize: 6.99,
                          textWeight: FontWeight.w400,
                          wrapperHeight: 35.94,
                          wrapperWidth: 119.79,
                          horizontalPadding: 11.98,
                          verticalPadding: 12.97,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
