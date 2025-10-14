import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/screens/chatroom_unread.dart';
import 'package:edify_app/screens/dm_chat_page.dart';
import 'package:edify_app/screens/group_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/chat_widget.dart';

class Chatroom extends StatelessWidget {
  const Chatroom({super.key});

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
                  hintText: 'search or start a new chat',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(Icons.search_outlined),
                ),
              ),
              SizedBox(height: 28),
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 34.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () {},
                    child: CustomTexts(
                      title: 'Chat',
                      textColor: AppColors.primaryWhiteIcon,
                      textSize: 14,
                      textWeight: FontWeight.w600,
                      textAlignment: AlignmentGeometry.center,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryWhiteNormal,
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 26,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatroomUnread(),
                        ),
                      );
                    },
                    child: CustomTexts(
                      title: 'Unread',
                      textColor: AppColors.primaryUnread,
                      textSize: 14,
                      textWeight: FontWeight.w600,
                      textAlignment: AlignmentGeometry.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28),

              TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupChatPage()),
                  );
                },
                child: ChatWidget(
                  chatName: CustomTexts(
                    title: 'Engineering 111 (024 Set)',
                    textColor: AppColors.primaryBlack,
                    textSize: 16,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.centerLeft,
                  ),
                  lastChat: CustomTexts(
                    title: 'Haha oh man',
                    textColor: AppColors.primaryBlack,
                    textSize: 12,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.centerLeft,
                  ),
                  leadIcon: Icon(
                    Icons.groups_outlined,
                    color: AppColors.primaryBlack,
                    size: 40,
                    weight: 100,
                  ),
                  pinChat: Icon(
                    Icons.push_pin_outlined,
                    color: AppColors.primaryBlack,
                    size: 16,
                  ),
                  timeStamp: CustomTexts(
                    title: '05:14 PM',
                    textColor: AppColors.primaryOrange,
                    textSize: 9,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.centerLeft,
                  ),
                ),
              ),
              SizedBox(height: 28),

              TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DmChatPage()),
                  );
                },
                child: ChatWidget(
                  chatName: CustomTexts(
                    title: 'Duke Manni',
                    textColor: AppColors.primaryBlack,
                    textSize: 16,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.centerLeft,
                  ),
                  lastChat: CustomTexts(
                    title: 'haha that\'s terrifying',
                    textColor: AppColors.primaryReadChatBlue,
                    textSize: 12,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.centerLeft,
                  ),
                  leadIcon: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/duke.png'),
                  ),
                  pinChat: Icon(
                    Icons.done_all_outlined,
                    color: AppColors.primaryReadChatBlue,
                    size: 16,
                  ),
                  timeStamp: CustomTexts(
                    title: '07:38 AM',
                    textColor: AppColors.primaryOrange,
                    textSize: 9,
                    textWeight: FontWeight.w500,
                    textAlignment: AlignmentGeometry.centerLeft,
                  ),
                ),
              ),
              SizedBox(height: 28),

              ChatWidget(
                chatName: CustomTexts(
                  title: 'Statistics 111 (024 Set)',
                  textColor: AppColors.primaryBlack,
                  textSize: 16,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                lastChat: CustomTexts(
                  title: 'Perfect!',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                leadIcon: Icon(
                  Icons.groups_outlined,
                  color: AppColors.primaryBlack,
                  size: 40,
                  weight: 100,
                ),
                pinChat: CircleAvatar(
                  backgroundColor: AppColors.primaryOrange,
                  radius: 10,
                  child: Text(
                    '5+',
                    style: TextStyle(
                      color: AppColors.primaryBlackLight,
                      fontSize: 9,
                    ),
                  ),
                ),
                timeStamp: CustomTexts(
                  title: '11:49 PM',
                  textColor: AppColors.primaryOrange,
                  textSize: 9,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
              ),
              SizedBox(height: 28),

              ChatWidget(
                chatName: CustomTexts(
                  title: 'Duke Manni',
                  textColor: AppColors.primaryBlack,
                  textSize: 16,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                lastChat: CustomTexts(
                  title: 'haha that\'s terrifying',
                  textColor: AppColors.primaryReadChatBlue,
                  textSize: 12,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                leadIcon: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/duke.png'),
                ),
                pinChat: Icon(
                  Icons.done_all_outlined,
                  color: AppColors.primaryReadChatBlue,
                  size: 16,
                ),
                timeStamp: CustomTexts(
                  title: '07:38 AM',
                  textColor: AppColors.primaryOrange,
                  textSize: 9,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
              ),

              SizedBox(height: 28),
              ChatWidget(
                chatName: CustomTexts(
                  title: 'Statistics 111 (024 Set)',
                  textColor: AppColors.primaryBlack,
                  textSize: 16,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                lastChat: CustomTexts(
                  title: 'Perfect!',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                leadIcon: Icon(
                  Icons.groups_outlined,
                  color: AppColors.primaryBlack,
                  size: 40,
                  weight: 100,
                ),
                pinChat: CircleAvatar(
                  backgroundColor: AppColors.primaryOrange,
                  radius: 10,
                  child: Text(
                    '5+',
                    style: TextStyle(
                      color: AppColors.primaryBlackLight,
                      fontSize: 9,
                    ),
                  ),
                ),
                timeStamp: CustomTexts(
                  title: '11:49 PM',
                  textColor: AppColors.primaryOrange,
                  textSize: 9,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
              ),

              SizedBox(height: 28),
              ChatWidget(
                chatName: CustomTexts(
                  title: 'Engineering 111 (024 Set)',
                  textColor: AppColors.primaryBlack,
                  textSize: 16,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                lastChat: CustomTexts(
                  title: 'Perfect!',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                leadIcon: Icon(
                  Icons.groups_outlined,
                  color: AppColors.primaryBlack,
                  size: 40,
                  weight: 100,
                ),
                pinChat: CircleAvatar(
                  backgroundColor: AppColors.primaryOrange,
                  radius: 10,
                  child: Text(
                    '5+',
                    style: TextStyle(
                      color: AppColors.primaryBlackLight,
                      fontSize: 9,
                    ),
                  ),
                ),
                timeStamp: CustomTexts(
                  title: '11:49 PM',
                  textColor: AppColors.primaryOrange,
                  textSize: 9,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
              ),

              SizedBox(height: 28),
              ChatWidget(
                chatName: CustomTexts(
                  title: 'Engineering 121 (024 Set)',
                  textColor: AppColors.primaryBlack,
                  textSize: 16,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                lastChat: CustomTexts(
                  title: 'Perfect!',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                leadIcon: Icon(
                  Icons.groups_outlined,
                  color: AppColors.primaryBlack,
                  size: 40,
                  weight: 100,
                ),
                pinChat: CircleAvatar(
                  backgroundColor: AppColors.primaryOrange,
                  radius: 10,
                  child: Text(
                    '5+',
                    style: TextStyle(
                      color: AppColors.primaryBlackLight,
                      fontSize: 9,
                    ),
                  ),
                ),
                timeStamp: CustomTexts(
                  title: '11:49 PM',
                  textColor: AppColors.primaryOrange,
                  textSize: 9,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
              ),

              SizedBox(height: 28),

              ChatWidget(
                chatName: CustomTexts(
                  title: 'Engineering Admin (024 Set)',
                  textColor: AppColors.primaryBlack,
                  textSize: 16,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                lastChat: CustomTexts(
                  title: 'Perfect!',
                  textColor: AppColors.primaryBlack,
                  textSize: 12,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
                leadIcon: Icon(
                  Icons.groups_outlined,
                  color: AppColors.primaryBlack,
                  size: 40,
                  weight: 100,
                ),
                pinChat: CircleAvatar(
                  backgroundColor: AppColors.primaryOrange,
                  radius: 10,
                  child: Text(
                    '5+',
                    style: TextStyle(
                      color: AppColors.primaryBlackLight,
                      fontSize: 9,
                    ),
                  ),
                ),
                timeStamp: CustomTexts(
                  title: '11:49 PM',
                  textColor: AppColors.primaryOrange,
                  textSize: 9,
                  textWeight: FontWeight.w500,
                  textAlignment: AlignmentGeometry.centerLeft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
