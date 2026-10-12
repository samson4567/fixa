import 'package:fixa/features/auth/domain/entities/register_password_result.dart';

class RegisterPasswordResponseModel {
  const RegisterPasswordResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final RegisterPasswordDataModel data;

  factory RegisterPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterPasswordResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: RegisterPasswordDataModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  RegisterPasswordResult toEntity() {
    return RegisterPasswordResult(message: message, step: data.step);
  }
}

class RegisterPasswordDataModel {
  const RegisterPasswordDataModel({required this.step});

  final String step;

  factory RegisterPasswordDataModel.fromJson(Map<String, dynamic> json) {
    return RegisterPasswordDataModel(step: json['step'] as String? ?? '');
  }
}
