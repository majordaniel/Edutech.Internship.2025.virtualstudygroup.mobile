import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/texts.dart';

class LeaveGroupConfirmation extends StatelessWidget {
  const LeaveGroupConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [Icon(null)], title: CustomAppbar()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            //main column for body
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTexts(
                title: 'Are you sure you want to Leave the group?',
                textColor: AppColors.primaryBlack,
                textSize: 16,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.center,
              ),
              SizedBox(height: 34),
              Row(
                children: [
                  SizedBox(width: 3),
                  CustomTexts(
                    title: 'Remove chat history',
                    textColor: AppColors.primaryBlack,
                    textSize: 14,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.centerLeft,
                  ),
                ],
              ),
              SizedBox(height: 8),

              SizedBox(height: 26),

              CustomTexts(
                title: 'This will remove the chat from your list and search',
                textColor: AppColors.primaryBlack,
                textSize: 12,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.centerLeft,
              ),

              SizedBox(height: 224),

              CustomButtons(
                buttonColor: AppColors.primaryOrange,
                buttonHeight: 48,
                buttonTitle: 'Leave',
                buttonWidth: 395,
                textColor: AppColors.primaryWhiteIcon,
                textSize: 16,
                textWeight: FontWeight.w500,
              ),
              SizedBox(height: 25),
              CustomButtons(
                buttonColor: AppColors.primaryBlackLight,
                buttonHeight: 48,
                buttonTitle: 'Cancel',
                buttonWidth: 395,
                textColor: AppColors.primaryBlack,
                textSize: 16,
                textWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
