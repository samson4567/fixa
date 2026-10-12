import 'package:fixa/features/auth/domain/entities/reset_password_result.dart';

class ResetPasswordResponseModel {
  const ResetPasswordResponseModel({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
    );
  }

  ResetPasswordResult toEntity() {
    return ResetPasswordResult(message: message);
  }
}
