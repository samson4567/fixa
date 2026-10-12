import 'package:fixa/features/auth/domain/entities/register_profile_result.dart';

class RegisterProfileResponseModel {
  const RegisterProfileResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final RegisterProfileDataModel data;

  factory RegisterProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterProfileResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: RegisterProfileDataModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  RegisterProfileResult toEntity() {
    return RegisterProfileResult(message: message, step: data.step);
  }
}

class RegisterProfileDataModel {
  const RegisterProfileDataModel({required this.step});

  final String step;

  factory RegisterProfileDataModel.fromJson(Map<String, dynamic> json) {
    return RegisterProfileDataModel(step: json['step'] as String? ?? '');
  }
}
