import 'user_model.dart';

class LoginResponseData {
  final String message;
  final User user;
  final String token;

  LoginResponseData({
    required this.message,
    required this.user,
    required this.token,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    return LoginResponseData(
      message: json['message'],
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}
