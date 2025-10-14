import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/widgets/buttons.dart';
import 'package:edify_app/widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateGroupPage extends StatelessWidget {
  const CreateGroupPage({super.key});

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
            children: [
              CustomTexts(
                title: 'Create Group',
                textColor: AppColors.primaryBlack,
                textSize: 20,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.center,
              ),
              SizedBox(height: 54),
              Row(
                children: [
                  CustomTexts(
                    title: 'Group Name',
                    textColor: AppColors.primaryBlack,
                    textSize: 16,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.centerLeft,
                  ),
                  Text(
                    '*',
                    style: GoogleFonts.poppins(color: AppColors.primaryOrange),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: double.infinity,
                      color: AppColors.primaryWhiteNormal,
                    ),
                  ),
                  hintText: 'Enter name',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.primaryBlackLightActive,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 26),
              Row(
                children: [
                  CustomTexts(
                    title: 'Select Course',
                    textColor: AppColors.primaryBlack,
                    textSize: 16,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.centerLeft,
                  ),
                  Text(
                    '*',
                    style: GoogleFonts.poppins(color: AppColors.primaryOrange),
                  ),
                ],
              ),
              SizedBox(child: FullWidthDropdown()),

              SizedBox(height: 37),
              Row(
                children: [
                  CustomTexts(
                    title: 'Group Name',
                    textColor: AppColors.primaryBlack,
                    textSize: 16,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.centerLeft,
                  ),
                  Text(
                    '*',
                    style: GoogleFonts.poppins(color: AppColors.primaryOrange),
                  ),
                ],
              ),
              SizedBox(
                height: 186,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        // width: double.infinity,
                        color: AppColors.primaryWhiteNormal,
                      ),
                    ),
                    hintText: 'Description....',
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.primaryBlackLightActive,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 87),
              CustomButtons(
                buttonColor: AppColors.primaryOrange,
                buttonHeight: 48,
                buttonTitle: 'Add Participant',
                buttonWidth: 395,
                textColor: AppColors.primaryWhiteIcon,
                textSize: 16,
                textWeight: FontWeight.w500,
              ),
              SizedBox(height: 25),
              CustomButtons(
                buttonColor: AppColors.primaryBlackLight,
                buttonHeight: 48,
                buttonTitle: 'Create Group',
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
