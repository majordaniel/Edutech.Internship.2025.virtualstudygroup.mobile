// bulletproof_logout_handler.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/providers/user_provider.dart';
import 'package:edify_app/screens/welcome_page.dart';

class LogoutHandler {
  static Future<void> logout(BuildContext context) async {
    try {
      print('🚪 Starting logout process...');

      // Get provider BEFORE any async operations
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Show loading immediately
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Logging out...'),
            ],
          ),
          duration: Duration(seconds: 5),
        ),
      );

      // Perform logout
      await userProvider.logout();

      // Hide snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Use Navigator with a fresh context
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (route) => false,
      );
    } catch (e) {
      print('❌ Logout error: $e');

      // Hide snackbar and show error
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
