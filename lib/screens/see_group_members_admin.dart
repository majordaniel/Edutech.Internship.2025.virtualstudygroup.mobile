import 'package:edify_app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/texts.dart';

class SeeGroupMembersAdmin extends StatelessWidget {
  const SeeGroupMembersAdmin({super.key});

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
                  width: 262,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.primaryWhiteIcon,
                  ),

                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage('assets/jerry.jpg'),
                                radius: 15,
                              ),
                              SizedBox(width: 11),
                              CustomTexts(
                                title: 'Jerry Adison',
                                textColor: AppColors.primaryBlack,
                                textSize: 14,
                                textWeight: FontWeight.w400,
                                textAlignment: AlignmentGeometry.centerLeft,
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.cancel_outlined,
                              color: AppColors.primaryBlack,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 23),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(5),
                          ),
                          backgroundColor: AppColors.primaryOrangeLight,
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTexts(
                              title: 'Make group admin',
                              textColor: AppColors.primaryBlack,
                              textSize: 12,
                              textWeight: FontWeight.w400,
                              textAlignment: AlignmentGeometry.centerLeft,
                            ),
                            Icon(
                              Icons.person_add_alt_1_outlined,
                              color: AppColors.primaryBlack,
                              size: 21,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(5),
                          ),
                          backgroundColor: AppColors.primaryOrangeLight,
                        ),
                        onPressed: () {
                          _showCustomConfirmationDialog(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTexts(
                              title: 'Remove from group',
                              textColor: AppColors.primaryBlack,
                              textSize: 12,
                              textWeight: FontWeight.w400,
                              textAlignment: AlignmentGeometry.centerLeft,
                            ),
                            Icon(
                              Icons.person_remove_alt_1_outlined,
                              color: AppColors.primaryBlack,
                              size: 21,
                            ),
                          ],
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

  void _showCustomConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryWhiteIcon,
              borderRadius: BorderRadius.circular(16),
            ),

            width: 328,
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 51),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTexts(
                  title:
                      'Are you sure you want to remove Jerry Adison from the group?',
                  textColor: AppColors.primaryConfirmBlue,
                  textSize: 12,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),

                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5),
                          side: BorderSide(color: AppColors.primaryOrange),
                        ),
                        backgroundColor: AppColors.primaryWhiteNormal,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTexts(
                            title: 'Cancel',
                            textColor: AppColors.primaryStrongBlack900,
                            textSize: 12,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5),
                          side: BorderSide(color: AppColors.primaryOrange),
                        ),
                        backgroundColor: AppColors.primaryOrange,
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTexts(
                            title: 'Remove',
                            textColor: AppColors.primaryWhiteIcon,
                            textSize: 12,
                            textWeight: FontWeight.w500,
                            textAlignment: AlignmentGeometry.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          padding: const EdgeInsets.all(18.0),
          child: Column(
            //main column for body
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 35),
              CustomTexts(
                title: 'Course mate (20)',
                textColor: AppColors.primaryBlack,
                textSize: 16,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.centerLeft,
              ),
              SizedBox(height: 15),

              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('assets/duke.png'),
                        ),
                        SizedBox(width: 11),
                        CustomTexts(
                          title: 'Jerry Adison',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    CustomTexts(
                      title: 'Admin',
                      textColor: AppColors.primaryBlack,
                      textSize: 12,
                      textWeight: FontWeight.w500,
                      textAlignment: AlignmentGeometry.centerLeft,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {
                  _showCustomDialog(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('assets/jerry.jpg'),
                        ),
                        SizedBox(width: 11),
                        CustomTexts(
                          title: 'Jerry Adison',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('assets/duke.png'),
                        ),
                        SizedBox(width: 11),
                        CustomTexts(
                          title: 'Jerry Adison',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('assets/duke.png'),
                        ),
                        SizedBox(width: 11),
                        CustomTexts(
                          title: 'Jerry Adison',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('assets/duke.png'),
                        ),
                        SizedBox(width: 11),
                        CustomTexts(
                          title: 'Jerry Adison',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('assets/duke.png'),
                        ),
                        SizedBox(width: 11),
                        CustomTexts(
                          title: 'Jerry Adison',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('assets/duke.png'),
                        ),
                        SizedBox(width: 11),
                        CustomTexts(
                          title: 'Jerry Adison',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: AssetImage('assets/duke.png'),
                        ),
                        SizedBox(width: 11),
                        CustomTexts(
                          title: 'Jerry Adison',
                          textColor: AppColors.primaryBlack,
                          textSize: 14,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),

              SizedBox(width: 34),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.group_add_outlined),
                    SizedBox(width: 24),
                    CustomTexts(
                      title: 'Add people',
                      textColor: AppColors.primaryBlack,
                      textSize: 16,
                      textWeight: FontWeight.w500,
                      textAlignment: AlignmentGeometry.centerLeft,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 17),

              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.link_outlined),
                    SizedBox(width: 24),
                    CustomTexts(
                      title: 'Invite to group via link',
                      textColor: AppColors.primaryBlack,
                      textSize: 16,
                      textWeight: FontWeight.w500,
                      textAlignment: AlignmentGeometry.centerLeft,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 17),

              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.exit_to_app_outlined),
                    SizedBox(width: 24),
                    CustomTexts(
                      title: 'Leave',
                      textColor: AppColors.primaryBlack,
                      textSize: 16,
                      textWeight: FontWeight.w500,
                      textAlignment: AlignmentGeometry.centerLeft,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 17),
            ],
          ),
        ),
      ),
    );
  }
}
