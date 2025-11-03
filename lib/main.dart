import 'package:edify_app/auth/register_page.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:edify_app/providers/meeting_provider.dart';
import 'package:edify_app/widgets/texts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/providers/join_request_provider.dart';
import 'package:edify_app/screens/join_group_page.dart';
import 'services/api_service.dart';
import 'providers/user_provider.dart';
import 'auth/login_page.dart';
import 'screens/welcome_page.dart';
import 'providers/group_provider.dart';
import 'providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 App starting initialization...');
  await ApiService.initialize();
  print('✅ ApiService initialized');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // Wait for app to be fully loaded
    await Future.delayed(Duration(seconds: 2));

    // Start auto-refresh for join requests
    // Note: We can't use context.read here in initState
    // We'll handle this in AppStartupChecker instead
    // print(
    //   '🔄 App initialization complete - auto-refresh will start in AppStartupChecker',
    // );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => GroupProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => JoinRequestProvider()),
        ChangeNotifierProvider(create: (context) => MeetingProvider()),
      ],
      child: MaterialApp(
        routes: {
          '/register': (context) => RegisterPage(),
          '/join-group': (context) => JoinGroupPage(),
        },
        debugShowCheckedModeBanner: false,
        title: 'EdifyLMS',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AppStartupChecker(),
      ),
    );
  }
}

class AppStartupChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 22,
                        width: 22,
                        child: Image.asset('assets/edify2.png'),
                      ),
                      SizedBox(width: 6),
                      CustomTexts(
                        title: 'edifyLMS',
                        textColor: AppColors.primaryAppbarBlack,
                        textSize: 16,
                        textWeight: FontWeight.w500,
                        textAlignment: AlignmentGeometry.center,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        }

        return Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            print(
              '🏠 Home decision - User: ${userProvider.user != null ? "EXISTS" : "NULL"} - Offline: ${userProvider.isOffline}',
            );

            // Start auto-refresh for join requests once user is loaded
            if (userProvider.user != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final joinRequestProvider = context.read<JoinRequestProvider>();
                joinRequestProvider.startAutoRefresh();
                // print('🔄 Started auto-refresh for join requests');
              });
            }

            return userProvider.user != null ? WelcomePage() : LoginPage();
          },
        );
      },
    );
  }

  Future<void> _initializeApp(BuildContext context) async {
    print('🔄 Starting app initialization to splash screen...');

    // Initialize UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initialize();

    // Initialize JoinRequestProvider if user is logged in
    if (userProvider.user != null) {
      final joinRequestProvider = Provider.of<JoinRequestProvider>(
        context,
        listen: false,
      );
      await joinRequestProvider.loadJoinRequests();
    }

    print('✅ App initialization complete');
  }
}
