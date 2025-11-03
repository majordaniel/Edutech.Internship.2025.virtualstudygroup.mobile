import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/providers/user_provider.dart';
import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/notification_icon.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AudioCallPage extends StatefulWidget {
  const AudioCallPage({super.key});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: CustomIconButton(
        //     buttonColor: AppColors.primaryOrangeLight,
        //     iconSize: 24,
        //     iconColor: AppColors.primaryOrange,
        //     buttonPaddingWidth: 8,
        //     buttonPaddingheight: 8,
        //     buttonBorderRadius: 8,
        //   ),
        // ),
        title: const CustomAppbar(),
        actions: [
          NotificationIcon(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 0,
                ),
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return SimpleUserAvatar(
                      imageUrl: userProvider.user?.avatarUrl,
                      userName: userProvider.user?.fullName,
                      size: 40,
                      // onLogout: () => LogoutHandler.logout(context),
                    );
                  },
                ),
              ),
              CustomIconButton(),
              SizedBox(width: 17.81),
            ],
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(17.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [SizedBox(height: 24)],
        ),
      ),
    );
  }
}
