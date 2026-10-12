import 'package:fixa/features/auth/domain/entities/forgot_password_result.dart';

class ForgotPasswordResponseModel {
  const ForgotPasswordResponseModel({
    required this.success,
    required this.message,
    this.token,
  });

  final bool success;
  final String message;
  final String? token;

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final dataToken = json['data'] is String ? json['data'] as String : null;

    return ForgotPasswordResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      token:
          json['token'] as String? ??
          json['resetToken'] as String? ??
          json['reset_token'] as String? ??
          json['passwordResetToken'] as String? ??
          json['password_reset_token'] as String? ??
          dataToken ??
          data['token'] as String? ??
          data['resetToken'] as String? ??
          data['reset_token'] as String? ??
          data['passwordResetToken'] as String? ??
          data['password_reset_token'] as String?,
    );
  }

  ForgotPasswordResult toEntity() {
    return ForgotPasswordResult(message: message, token: token);
  }
}
