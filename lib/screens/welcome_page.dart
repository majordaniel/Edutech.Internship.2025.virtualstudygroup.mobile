import 'package:edify_app/providers/join_request_provider.dart';
import 'package:edify_app/widgets/icon_button.dart';
import 'package:edify_app/widgets/notification_icon.dart';
import 'package:edify_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/widgets/appbar.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:edify_app/widgets/wrapper_text.dart';
import 'package:edify_app/providers/user_provider.dart';
import 'package:edify_app/services/group_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _hasLoadedNotifications = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load notifications only once when dependencies change
    if (!_hasLoadedNotifications) {
      _hasLoadedNotifications = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final joinRequestProvider = Provider.of<JoinRequestProvider>(
          context,
          listen: false,
        );
        // print('🔄 Loading join requests in WelcomePage...');
        joinRequestProvider.loadJoinRequests();
      });
    }
  }

  // When opening a group chat
  void _onGroupOpened(int groupId) {
    final joinRequestProvider = context.read<JoinRequestProvider>();
    joinRequestProvider.forceRefresh();
  }

  // When returning to the main screen
  void _onResume() {
    final joinRequestProvider = context.read<JoinRequestProvider>();
    joinRequestProvider.forceRefresh();
  }

  // When approving/rejecting from anywhere in the app
  void _onRequestHandled() {
    final joinRequestProvider = context.read<JoinRequestProvider>();
    joinRequestProvider.forceRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.primaryWhiteIcon,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhiteIcon,
        elevation: 0,
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

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dynamic Welcome Message with Real User Data
              Align(
                alignment: Alignment.centerLeft,
                child: CustomTexts(
                  title: 'Welcome ${userProvider.user?.firstName ?? 'Andrew'}!',
                  textColor: AppColors.primaryOrange, // Your original orange
                  textSize: 24,
                  textWeight: FontWeight.w600,
                  textAlignment: Alignment.centerLeft,
                ),
              ),
              SizedBox(height: 24),

              // Your Original Stats Cards with Real Data Integration
              _buildOriginalStatsSection(userProvider, context),
              SizedBox(height: 24.58),

              // Your Original Course Progress Section
              _buildOriginalCourseProgressSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Your Original Stats Section with Real Data Integration
  Widget _buildOriginalStatsSection(
    UserProvider userProvider,
    BuildContext context,
  ) {
    return FutureBuilder(
      future: GroupService.getGroups(),
      builder: (context, snapshot) {
        int studyGroupCount = 4; // Default fallback
        int coursesCount = 2; // Default fallback
        int coursesGrouping1 = 3; // Default fallback
        int coursesGrouping2 = 2; // Default fallback

        // Update study group count with real data if available
        if (snapshot.hasData && snapshot.data!.isSuccess) {
          studyGroupCount = snapshot.data!.data?.length ?? 4;
        }

        return Column(
          children: [
            // Courses Card (Original)
            Container(
              width: 396,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 21),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryProgressBlack,
                  width: 0.1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Container(
                decoration: BoxDecoration(
                  // color: AppColors.primaryWBlackWhiteHover,
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: AppColors.primaryDropShadow,
                  //     offset: Offset(0.85, -0.85),
                  //   ),
                  // ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Icon(Icons.school_outlined),
                    SizedBox(
                      height: 38.5,
                      width: 38.5,
                      child: Image.asset('assets/icon.png'),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTexts(
                          title: coursesCount.toString(),
                          textColor: AppColors.primaryBlack,
                          textSize: 17.75,
                          textWeight: FontWeight.w500,
                          textAlignment: Alignment.centerLeft,
                        ),
                        CustomTexts(
                          title: 'Courses',
                          textColor: AppColors.primaryBlack,
                          textSize: 13.78,
                          textWeight: FontWeight.w500,
                          textAlignment: Alignment.centerLeft,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.14),

            // Courses Grouping 1 (Original)
            Container(
              width: 396,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 21),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryProgressBlack,
                  width: 0.1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Icon(Icons.school_outlined),
                  SizedBox(
                    height: 38.5,
                    width: 38.5,
                    child: Image.asset('assets/icon.png'),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTexts(
                        title: coursesGrouping1.toString(),
                        textColor: AppColors.primaryBlack,
                        textSize: 17.75,
                        textWeight: FontWeight.w500,
                        textAlignment: Alignment.centerLeft,
                      ),
                      CustomTexts(
                        title: 'Courses Grouping',
                        textColor: AppColors.primaryBlack,
                        textSize: 13.78,
                        textWeight: FontWeight.w500,
                        textAlignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.14),

            // Courses Grouping 2 (Original)
            Container(
              width: 396,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 21),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryProgressBlack,
                  width: 0.1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Icon(Icons.school_outlined),
                  SizedBox(
                    height: 38.5,
                    width: 38.5,
                    child: Image.asset('assets/icon.png'),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTexts(
                        title: coursesGrouping2.toString(),
                        textColor: AppColors.primaryBlack,
                        textSize: 17.75,
                        textWeight: FontWeight.w500,
                        textAlignment: Alignment.centerLeft,
                      ),
                      CustomTexts(
                        title: 'Courses Grouping',
                        textColor: AppColors.primaryBlack,
                        textSize: 13.78,
                        textWeight: FontWeight.w500,
                        textAlignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.14),

            // Study Group Card with Real Data
            Container(
              width: 396,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 21),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryProgressBlack,
                  width: 0.1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Icon(Icons.school_outlined),
                  SizedBox(
                    height: 38.5,
                    width: 38.5,
                    child: Image.asset('assets/icon.png'),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTexts(
                        title: studyGroupCount.toString(), // Real data here
                        textColor: AppColors.primaryBlack,
                        textSize: 17.75,
                        textWeight: FontWeight.w500,
                        textAlignment: Alignment.centerLeft,
                      ),
                      CustomTexts(
                        title: 'Study Group',
                        textColor: AppColors.primaryBlack,
                        textSize: 13.78,
                        textWeight: FontWeight.w500,
                        textAlignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Your Original Course Progress Section (No Changes)
  Widget _buildOriginalCourseProgressSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 0),
          child: CustomTexts(
            title: 'Course Progress Information',
            textColor: AppColors.primaryBlack,
            textSize: 20,
            textWeight: FontWeight.w500,
            textAlignment: Alignment.centerLeft,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CustomWrapperTexts(
                      title: 'Name',
                      textColor: AppColors.primaryProgressBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.bold,
                      wrapperHeight: 21.96,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 5.98,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: 'Cr 001 - Criminal Law',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: 'Cr 001 - Criminal Law',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: 'Cr 001 - Criminal Law',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomWrapperTexts(
                      title: 'Assignment Completion',
                      textColor: AppColors.primaryProgressBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.bold,
                      wrapperHeight: 21.96,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 5.98,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: '0 out of 3',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: '0 out of 3',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: '0 out of 3',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomWrapperTexts(
                      title: 'Quiz Completion',
                      textColor: AppColors.primaryProgressBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.bold,
                      wrapperHeight: 21.96,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 5.98,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: '0 out of 3',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: '0 out of 3',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: '0 out of 3',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomWrapperTexts(
                      title: 'Forum Participation',
                      textColor: AppColors.primaryProgressBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.bold,
                      wrapperHeight: 21.96,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 5.98,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: '0 out of 3',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: '0 out of 3',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                    SizedBox(height: 9),
                    CustomWrapperTexts(
                      title: '0 out of 3',
                      textColor: AppColors.primaryBlack,
                      textSize: 6.99,
                      textWeight: FontWeight.w400,
                      wrapperHeight: 35.94,
                      wrapperWidth: 119.79,
                      horizontalPadding: 11.98,
                      verticalPadding: 12.97,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
