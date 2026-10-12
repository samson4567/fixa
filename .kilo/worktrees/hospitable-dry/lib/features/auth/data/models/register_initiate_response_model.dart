import 'package:fixa/features/auth/domain/entities/register_initiate_result.dart';

class RegisterInitiateResponseModel {
  const RegisterInitiateResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final RegisterInitiateDataModel data;

  factory RegisterInitiateResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterInitiateResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: RegisterInitiateDataModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  RegisterInitiateResult toEntity() {
    return RegisterInitiateResult(
      message: message,
      sessionToken: data.sessionToken,
      step: data.step,
    );
  }
}

class RegisterInitiateDataModel {
  const RegisterInitiateDataModel({
    required this.sessionToken,
    required this.step,
  });

  final String sessionToken;
  final String step;

  factory RegisterInitiateDataModel.fromJson(Map<String, dynamic> json) {
    return RegisterInitiateDataModel(
      sessionToken: json['sessionToken'] as String? ?? '',
      step: json['step'] as String? ?? '',
    );
  }
}
