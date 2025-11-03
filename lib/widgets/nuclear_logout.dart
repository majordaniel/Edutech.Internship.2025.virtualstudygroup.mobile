// nuclear_logout.dart - This WILL work
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edify_app/providers/user_provider.dart';
import 'package:edify_app/screens/welcome_page.dart';

void nuclearLogout(BuildContext context) async {
  // Store navigator key before any async operations
  final navigator = Navigator.of(context);

  try {
    // Show immediate feedback
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logging out...')));

    // Perform logout
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logout();

    // Navigate immediately without any delays
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logout failed: $e'), backgroundColor: Colors.red),
    );
  }
}
