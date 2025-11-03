import 'package:edify_app/auth/register_page.dart';
import 'package:edify_app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isServerConnected = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _debugInitialState();
    _checkServerConnection();
  }

  bool get isSafe => mounted && !_isDisposed;

  Future<void> _debugInitialState() async {
    print('🔄 LoginPage initializing...');
    await AuthService.debugTokenStatus();
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await AuthService.testApiConnection();

    if (isSafe) {
      setState(() {
        _isServerConnected = isConnected;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLoginSuccess() {
    // Navigate to homepage immediately after successful login
    if (isSafe) {
      // Use Navigator.pushReplacement to replace login page with homepage
      Navigator.pushReplacementNamed(context, '/');

      // Show success message after navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        String message;
        Color backgroundColor;

        if (userProvider.isOffline) {
          message = 'Welcome back! (Offline Mode)';
          backgroundColor = Colors.blue;
        } else {
          message = 'Welcome back, ${userProvider.user?.firstName ?? "User"}!';
          backgroundColor = Colors.green;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  // Add these helper methods to LoginPage:
  Color _getErrorColor(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('incorrect password')) {
      return Colors.orange[50]!;
    } else if (errorLower.contains('no account') ||
        errorLower.contains('email not found')) {
      return Colors.orange[50]!;
    } else if (errorLower.contains('no internet') ||
        errorLower.contains('network')) {
      return Colors.blue[50]!;
    } else if (errorLower.contains('server') ||
        errorLower.contains('unavailable')) {
      return Colors.red[50]!;
    }

    return Colors.orange[50]!;
  }

  Color _getErrorBorderColor(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('incorrect password')) {
      return Colors.orange;
    } else if (errorLower.contains('no account') ||
        errorLower.contains('email not found')) {
      return Colors.orange;
    } else if (errorLower.contains('no internet') ||
        errorLower.contains('network')) {
      return Colors.blue;
    } else if (errorLower.contains('server') ||
        errorLower.contains('unavailable')) {
      return Colors.red;
    }

    return Colors.orange;
  }

  Color _getErrorTextColor(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('incorrect password')) {
      return Colors.orange[800]!;
    } else if (errorLower.contains('no account') ||
        errorLower.contains('email not found')) {
      return Colors.orange[800]!;
    } else if (errorLower.contains('no internet') ||
        errorLower.contains('network')) {
      return Colors.blue[800]!;
    } else if (errorLower.contains('server') ||
        errorLower.contains('unavailable')) {
      return Colors.red[800]!;
    }

    return Colors.orange[800]!;
  }

  IconData _getErrorIcon(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('incorrect password')) {
      return Icons.lock_outline;
    } else if (errorLower.contains('no account') ||
        errorLower.contains('email not found')) {
      return Icons.person_outline;
    } else if (errorLower.contains('no internet') ||
        errorLower.contains('network')) {
      return Icons.wifi_off;
    } else if (errorLower.contains('server') ||
        errorLower.contains('unavailable')) {
      return Icons.error_outline;
    }

    return Icons.warning;
  }

  Color _getErrorIconColor(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('incorrect password')) {
      return Colors.orange;
    } else if (errorLower.contains('no account') ||
        errorLower.contains('email not found')) {
      return Colors.orange;
    } else if (errorLower.contains('no internet') ||
        errorLower.contains('network')) {
      return AppColors.primaryRejected;
    } else if (errorLower.contains('server') ||
        errorLower.contains('unavailable')) {
      return AppColors.primaryRejected;
    }

    return Colors.orange;
  }

  String _getErrorTitle(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('incorrect password')) {
      return 'Incorrect Password';
    } else if (errorLower.contains('no account') ||
        errorLower.contains('email not found')) {
      return 'Account Not Found';
    } else if (errorLower.contains('no internet') ||
        errorLower.contains('network')) {
      return 'No Internet Connection';
    } else if (errorLower.contains('server') ||
        errorLower.contains('unavailable')) {
      return 'Server Issue';
    }

    return 'Login Issue';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),

                // Offline Mode Indicator
                if (userProvider.isOffline)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.blue, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Offline Mode - Using cached data',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Server Connection Status
                if (!_isServerConnected && !userProvider.isOffline)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.red, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Server Unavailable',
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Cannot connect to the server. Try offline login if you have cached credentials.',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh, color: Colors.red),
                          onPressed: () {
                            if (isSafe) {
                              _checkServerConnection();
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                // Title and Logo
                Row(
                  children: [
                    SizedBox(
                      height: 42,
                      width: 51,
                      child: Image.asset('assets/edify2.png'),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'edifyLMS',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryAppbarBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 40),

                // Welcome text
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAppbarBlack,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sign in to your account to continue',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),

                SizedBox(height: 40),
                // In your LoginPage build method, update the error display:

                // Provider error message - make it more specific
                if (userProvider.error != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: _getErrorColor(userProvider.error!),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getErrorBorderColor(userProvider.error!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getErrorIcon(userProvider.error!),
                              color: _getErrorIconColor(userProvider.error!),
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getErrorTitle(userProvider.error!),
                                style: TextStyle(
                                  color: _getErrorTextColor(
                                    userProvider.error!,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          userProvider.error!,
                          style: TextStyle(
                            color: _getErrorTextColor(userProvider.error!),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (userProvider.error != null) SizedBox(height: 20),
                // Email field
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlack,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  cursorColor: AppColors.primaryOrange,
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryOrange,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                // Password field
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlack,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  cursorColor: AppColors.primaryOrange,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryOrange,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        if (isSafe) {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        }
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if (isSafe) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Forgot password feature coming soon!',
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Forgot your Password?',
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: userProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              userProvider.clearError();

                              final success = await userProvider.login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );

                              if (success && isSafe) {
                                // Handle successful login
                                _handleLoginSuccess();
                              } else if (isSafe) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      userProvider.error ?? 'Login failed',
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userProvider.isOffline
                          ? Colors.blue
                          : AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: userProvider.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (userProvider.isOffline)
                                Icon(Icons.wifi_off, size: 18),
                              if (userProvider.isOffline) SizedBox(width: 8),
                              Text(
                                userProvider.isOffline
                                    ? 'Sign In Offline'
                                    : 'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: 32),

                // Sign up link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (isSafe) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      }
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          color: AppColors.primaryBlack,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
