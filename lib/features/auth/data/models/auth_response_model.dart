import '../../domain/entities/user.dart';

class AuthResponseModel {
  final String token;
  final String? refreshToken;
  final User? user;

  AuthResponseModel({required this.token, this.refreshToken, this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String? ?? json['access_token'] as String?;
    if (token == null) {
      throw const FormatException('Auth response missing token');
    }
    final rawUser = json['user'];
    return AuthResponseModel(
      token: token,
      refreshToken:
          json['refreshToken'] as String? ?? json['refresh_token'] as String?,
      user: rawUser is Map<String, dynamic>
          ? User(id: rawUser['id'] as String, email: rawUser['email'] as String)
          : null,
    );
  }
}
