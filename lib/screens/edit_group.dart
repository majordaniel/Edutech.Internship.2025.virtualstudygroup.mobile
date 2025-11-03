import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:google_fonts/google_fonts.dart';

class EditGroup extends StatefulWidget {
  final dynamic group;

  const EditGroup({super.key, required this.group});

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
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
              SizedBox(height: 85),
              CustomTexts(
                title: 'Group Name',
                textColor: AppColors.primaryBlack,
                textSize: 16,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.centerLeft,
              ),
              SizedBox(height: 15),
              TextField(
                cursorColor: AppColors.primaryOrange,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      width: double.infinity,
                      color: AppColors.primaryWhiteNormal,
                    ),
                  ),
                  hintText: 'Enter group name',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.primaryBlackLightActive,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 35),

              CustomTexts(
                title: 'Description',
                textColor: AppColors.primaryBlack,
                textSize: 16,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.centerLeft,
              ),
              SizedBox(
                height: 127,
                child: TextField(
                  cursorColor: AppColors.primaryOrange,
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

              SizedBox(height: 255),
              CustomButtons(
                buttonColor: AppColors.primaryOrange,
                buttonHeight: 48,
                buttonTitle: 'Save',
                buttonWidth: 395,
                textColor: AppColors.primaryWhiteIcon,
                textSize: 16,
                textWeight: FontWeight.w500,
                onPressed: () {
                  // to be updated
                },
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
                onPressed: () {
                  // to be updated
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
