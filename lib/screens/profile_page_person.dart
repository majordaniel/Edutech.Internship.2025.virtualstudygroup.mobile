import 'package:edify_app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';

class ProfilePagePerson extends StatelessWidget {
  const ProfilePagePerson({super.key});

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 361,
            height: 185,
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTexts(
                      title: 'Edit Contact',
                      textColor: AppColors.primaryBlack,
                      textSize: 16,
                      textWeight: FontWeight.w500,
                      textAlignment: AlignmentGeometry.centerLeft,
                    ),
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppColors.primaryWhiteIcon,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 50,
                  child: Image.asset('assets/adeola.png'),
                ),
                CustomTexts(
                  title: 'First name',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w400,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                TextField(
                  decoration: InputDecoration(
                    focusColor: AppColors.primaryOrange,
                    hintText: 'first name',
                    hintStyle: TextStyle(color: AppColors.primaryBlack),
                  ),
                ),
                SizedBox(height: 18),
                CustomTexts(
                  title: 'Last name',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w400,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                TextField(
                  decoration: InputDecoration(
                    focusColor: AppColors.primaryOrange,
                    hintText: 'Last name',
                    hintStyle: TextStyle(color: AppColors.primaryBlack),
                  ),
                ),
                SizedBox(height: 18),
                CustomTexts(
                  title: 'Email',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w400,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                TextField(
                  decoration: InputDecoration(
                    focusColor: AppColors.primaryOrange,
                    hintText: 'email',
                    hintStyle: TextStyle(color: AppColors.primaryBlack),
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  children: [
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
                          title: 'Save',
                          textColor: AppColors.primaryWhiteIcon,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 160,
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        border: Border.all(color: AppColors.primaryOrange),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: CustomTexts(
                          title: 'cancel ',
                          textColor: AppColors.primaryWhiteIcon,
                          textSize: 12,
                          textWeight: FontWeight.w500,
                          textAlignment: AlignmentGeometry.center,
                        ),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(radius: 50, child: Image.asset('assets/adeola.png')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTexts(
                    title: 'Adeola Manni',
                    textColor: AppColors.primaryBlack,
                    textSize: 14,
                    textWeight: FontWeight.w600,
                    textAlignment: AlignmentGeometry.center,
                  ),
                  IconButton(
                    onPressed: () {
                      _showCustomDialog(context);
                    },
                    icon: Icon(Icons.edit_outlined, size: 14.83),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline_outlined, size: 14),
                  CustomTexts(
                    title: 'AdeolaManni@gmail.com',
                    textColor: AppColors.primaryBlack,
                    textSize: 14,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.center,
                  ),
                ],
              ),

              SizedBox(height: 26),
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

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTexts(
                      title: 'Send a quick message',
                      textColor: AppColors.primaryOrange,
                      textSize: 14,
                      textWeight: FontWeight.w500,
                      textAlignment: AlignmentGeometry.centerLeft,
                    ),
                    Icon(
                      Icons.send_outlined,
                      size: 14,
                      color: AppColors.primaryBlack,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle_notifications_outlined, size: 14),
                    SizedBox(width: 7),
                    CustomTexts(
                      title: 'Last seen yesterday',
                      textColor: AppColors.primaryBlack,
                      textSize: 14,
                      textWeight: FontWeight.w500,
                      textAlignment: AlignmentGeometry.centerLeft,
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
            ],
          ),
        ),
      ),
    );
  }
}
