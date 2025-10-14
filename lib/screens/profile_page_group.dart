import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/screens/see_group_members_admin.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/screens/edit_group.dart';

class ProfilePageGroup extends StatelessWidget {
  const ProfilePageGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhiteIcon,
      appBar: AppBar(actions: [Icon(null)], title: CustomAppbar()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.groups_outlined,
                size: 67.23,
                color: AppColors.primaryBlack,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTexts(
                    title: 'Engineering 101 (024 Set)',
                    textColor: AppColors.primaryBlack,
                    textSize: 18,
                    textWeight: FontWeight.w600,
                    textAlignment: AlignmentGeometry.centerLeft,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditGroup()),
                      );
                    },
                    icon: Icon(Icons.edit_outlined, size: 14.83),
                  ),
                ],
              ),
              SizedBox(height: 46),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppColors.primaryOrange),
                        borderRadius: BorderRadiusGeometry.circular(6),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 7, 7, 2),
                    ),
                    onPressed: () {},
                    child: Column(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          color: AppColors.primaryOrange,
                          size: 18,
                        ),
                        SizedBox(height: 6),
                        CustomTexts(
                          title: 'Audio',
                          textColor: AppColors.primaryBlack,
                          textSize: 6,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppColors.primaryOrange),
                        borderRadius: BorderRadiusGeometry.circular(6),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 7, 7, 2),
                    ),
                    onPressed: () {},
                    child: Column(
                      children: [
                        Icon(
                          Icons.mic_off_outlined,
                          color: AppColors.primaryOrange,
                          size: 18,
                        ),
                        SizedBox(height: 6),
                        CustomTexts(
                          title: 'Audio',
                          textColor: AppColors.primaryBlack,
                          textSize: 6,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppColors.primaryOrange),
                        borderRadius: BorderRadiusGeometry.circular(6),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 7, 7, 2),
                    ),
                    onPressed: () {},
                    child: Column(
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          color: AppColors.primaryOrange,
                          size: 18,
                        ),
                        SizedBox(height: 6),
                        CustomTexts(
                          title: 'Audio',
                          textColor: AppColors.primaryBlack,
                          textSize: 6,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppColors.primaryOrange),
                        borderRadius: BorderRadiusGeometry.circular(6),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 7, 7, 2),
                    ),
                    onPressed: () {},
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_outlined,
                          color: AppColors.primaryOrange,
                          size: 18,
                        ),
                        SizedBox(height: 6),
                        CustomTexts(
                          title: 'Audio',
                          textColor: AppColors.primaryBlack,
                          textSize: 6,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26),

              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          size: 10,
                          color: AppColors.primaryAppbarBlack,
                        ),
                        SizedBox(width: 7),
                        CustomTexts(
                          title: 'Media',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CustomTexts(
                          title: '5',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                        SizedBox(width: 7),
                        Icon(
                          Icons.keyboard_arrow_right_outlined,
                          size: 8.19,
                          color: AppColors.primaryAppbarBlack,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 19),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.file_copy_outlined,
                          size: 10,
                          color: AppColors.primaryAppbarBlack,
                        ),
                        SizedBox(width: 7),
                        CustomTexts(
                          title: 'Files',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CustomTexts(
                          title: '5',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                        SizedBox(width: 7),
                        Icon(
                          Icons.keyboard_arrow_right_outlined,
                          size: 8.19,
                          color: AppColors.primaryAppbarBlack,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 19),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.link_outlined,
                          size: 10,
                          color: AppColors.primaryAppbarBlack,
                        ),
                        SizedBox(width: 7),
                        CustomTexts(
                          title: 'Links',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CustomTexts(
                          title: '5',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                        SizedBox(width: 7),
                        Icon(
                          Icons.keyboard_arrow_right_outlined,
                          size: 8.19,
                          color: AppColors.primaryAppbarBlack,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 19),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.mobile_screen_share_outlined,
                          size: 10,
                          color: AppColors.primaryAppbarBlack,
                        ),
                        SizedBox(width: 7),
                        CustomTexts(
                          title: 'Screen sharing',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 19),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          size: 10,
                          color: AppColors.primaryAppbarBlack,
                        ),
                        SizedBox(width: 7),
                        CustomTexts(
                          title: 'Permission',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 19),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 10,
                          color: AppColors.primaryAppbarBlack,
                        ),
                        SizedBox(width: 7),
                        CustomTexts(
                          title: 'Mute',
                          textColor: AppColors.primaryBlack,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.centerLeft,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28),
              CustomTexts(
                title: 'Course mates(28)',
                textColor: AppColors.primaryBlack,
                textSize: 16,
                textWeight: FontWeight.w500,
                textAlignment: AlignmentGeometry.centerLeft,
              ),
              SizedBox(height: 25),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage('assets/duke.png'),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage('assets/duke.png'),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage('assets/duke.png'),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage('assets/duke.png'),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage('assets/duke.png'),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage('assets/duke.png'),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage('assets/duke.png'),
                    ),
                    SizedBox(width: 12),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.all(
                            Radius.circular(2),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeeGroupMembersAdmin(),
                          ),
                        );
                      },
                      child: CustomTexts(
                        title: 'See more...',
                        textColor: AppColors.primaryOrange,
                        textSize: 12,
                        textWeight: FontWeight.w400,
                        textAlignment: AlignmentGeometry.centerLeft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
