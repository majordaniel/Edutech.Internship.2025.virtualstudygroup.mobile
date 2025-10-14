import 'package:edify_app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';

class JoinGroupPage extends StatelessWidget {
  const JoinGroupPage({super.key});

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                left: 1000,
                bottom: 1000,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Positioned dialog
              Positioned(
                top: 40, // Position from top
                right: 0,
                child: Container(
                  width: 361,
                  height: 185,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.primaryWhiteIcon,
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTexts(
                            title: 'Request Sent',
                            textColor: AppColors.primaryBlack,
                            textSize: 16,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.centerLeft,
                          ),
                          IconButton(
                            iconSize: 20,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.cancel_outlined,
                              color: AppColors.primaryWhiteIcon,
                              size: 12,
                            ),
                          ),
                        ],
                      ),
                      CustomTexts(
                        title:
                            'You will be added once the admin approves your requests',
                        textColor: AppColors.primaryBlack,
                        textSize: 14,
                        textWeight: FontWeight.w400,
                        textAlignment: AlignmentGeometry.center,
                      ),
                      SizedBox(height: 18),
                      Container(
                        width: 160,
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: TextButton(
                          onPressed: () {},
                          child: CustomTexts(
                            title: 'Cancel request',
                            textColor: AppColors.primaryWhiteIcon,
                            textSize: 12,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [Icon(null)], title: CustomAppbar()),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(17),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  hintText: 'search for rooms (course code and names)',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(Icons.search_outlined),
                ),
              ),

              SizedBox(height: 28),
              Container(
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.primaryBlackLight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTexts(
                          title: 'Organic Study',
                          textColor: AppColors.primaryAppbarBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                        CustomTexts(
                          title: 'CHEM 101',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Container(
                      // width: 111,
                      padding: EdgeInsets.symmetric(
                        vertical: 5.5,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: TextButton(
                        onPressed: () {
                          _showCustomDialog(context);
                        },
                        child: CustomTexts(
                          title: 'Join Room',
                          textColor: AppColors.primaryWhiteIcon,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
              Container(
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.primaryBlackLight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTexts(
                          title: 'Literature Circle',
                          textColor: AppColors.primaryAppbarBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                        CustomTexts(
                          title: 'ENG 101',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Container(
                      // width: 111,
                      padding: EdgeInsets.symmetric(
                        vertical: 5.5,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: CustomTexts(
                          title: 'Join Room',
                          textColor: AppColors.primaryWhiteIcon,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
              Container(
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.primaryBlackLight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTexts(
                          title: 'Literature Circle',
                          textColor: AppColors.primaryAppbarBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                        CustomTexts(
                          title: 'ENG 101',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Container(
                      // width: 111,
                      padding: EdgeInsets.symmetric(
                        vertical: 5.5,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: CustomTexts(
                          title: 'Join Room',
                          textColor: AppColors.primaryWhiteIcon,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
              Container(
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.primaryBlackLight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTexts(
                          title: 'Literature Circle',
                          textColor: AppColors.primaryAppbarBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                        CustomTexts(
                          title: 'ENG 101',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Container(
                      // width: 111,
                      padding: EdgeInsets.symmetric(
                        vertical: 5.5,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: CustomTexts(
                          title: 'Join Room',
                          textColor: AppColors.primaryWhiteIcon,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
              Container(
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.primaryBlackLight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTexts(
                          title: 'Engineering (400L)',
                          textColor: AppColors.primaryAppbarBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                        CustomTexts(
                          title: 'ENG 401',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Container(
                      // width: 111,
                      padding: EdgeInsets.symmetric(
                        vertical: 5.5,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: CustomTexts(
                          title: 'Join Room',
                          textColor: AppColors.primaryWhiteIcon,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
              Container(
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.primaryBlackLight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTexts(
                          title: 'Literature Circle',
                          textColor: AppColors.primaryAppbarBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                        CustomTexts(
                          title: 'ENG 101',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Container(
                      // width: 111,
                      padding: EdgeInsets.symmetric(
                        vertical: 5.5,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: CustomTexts(
                          title: 'Join Room',
                          textColor: AppColors.primaryWhiteIcon,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
              Container(
                padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.primaryBlackLight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTexts(
                          title: 'Literacle Circle',
                          textColor: AppColors.primaryAppbarBlack,
                          textSize: 16,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                        CustomTexts(
                          title: 'ENG 101',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Container(
                      // width: 111,
                      padding: EdgeInsets.symmetric(
                        vertical: 5.5,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: CustomTexts(
                          title: 'Join Room',
                          textColor: AppColors.primaryWhiteIcon,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }
}
