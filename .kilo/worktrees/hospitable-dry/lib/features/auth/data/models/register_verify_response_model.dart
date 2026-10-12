import 'package:fixa/features/auth/domain/entities/register_verify_result.dart';

class RegisterVerifyResponseModel {
  const RegisterVerifyResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final RegisterVerifyDataModel data;

  factory RegisterVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterVerifyResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: RegisterVerifyDataModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  RegisterVerifyResult toEntity() {
    return RegisterVerifyResult(message: message, step: data.step);
  }
}

class RegisterVerifyDataModel {
  const RegisterVerifyDataModel({required this.step});

  final String step;

  factory RegisterVerifyDataModel.fromJson(Map<String, dynamic> json) {
    return RegisterVerifyDataModel(step: json['step'] as String? ?? '');
  }
}
