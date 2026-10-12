import 'package:fixa/features/auth/domain/entities/login_result.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final LoginDataModel data;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: LoginDataModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  LoginResult toEntity() {
    return LoginResult(
      message: message,
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
    );
  }
}

class LoginDataModel {
  const LoginDataModel({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    final accessToken =
        json['accessToken'] as String? ??
        json['access_token'] as String? ??
        json['token'] as String? ??
        json['authToken'] as String? ??
        '';

    final refreshToken =
        json['refreshToken'] as String? ??
        json['refresh_token'] as String? ??
        '';

    return LoginDataModel(accessToken: accessToken, refreshToken: refreshToken);
  }
}
