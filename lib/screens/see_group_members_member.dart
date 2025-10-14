import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/screens/leave_group_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/texts.dart';

class SeeGroupMembersMember extends StatelessWidget {
  const SeeGroupMembersMember({super.key});

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

              ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          child: Image.asset('assets/duke.png'),
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
              ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          child: Image.asset('assets/jerry.png'),
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
                    Icon(Icons.arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          child: Image.asset('assets/duke.png'),
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
                    Icon(Icons.arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          child: Image.asset('assets/duke.png'),
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
                    Icon(Icons.arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          child: Image.asset('assets/duke.png'),
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
                    Icon(Icons.arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          child: Image.asset('assets/duke.png'),
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
                    Icon(Icons.arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          child: Image.asset('assets/duke.png'),
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
                    Icon(Icons.arrow_right_outlined),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          child: Image.asset('assets/duke.png'),
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
                    Icon(Icons.arrow_right_outlined),
                  ],
                ),
              ),

              SizedBox(width: 34),
              ElevatedButton(
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

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaveGroupConfirmation(),
                    ),
                  );
                },
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
