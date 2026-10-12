import 'package:fixa/core/constants/endpoint_constant.dart';
import 'package:fixa/core/network/api_client.dart';
import 'package:fixa/core/network/app_error.dart';
import 'package:dio/dio.dart';
import 'package:fixa/features/auth/data/models/forgot_password_response_model.dart';
import 'package:fixa/features/auth/data/models/login_response_model.dart';
import 'package:fixa/features/auth/data/models/register_initiate_response_model.dart';
import 'package:fixa/features/auth/data/models/register_password_response_model.dart';
import 'package:fixa/features/auth/data/models/register_profile_response_model.dart';
import 'package:fixa/features/auth/data/models/register_verify_response_model.dart';
import 'package:fixa/features/auth/data/models/reset_password_response_model.dart';
import 'package:fixa/features/auth/data/models/user_profile_response_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<LoginResponseModel> loginWithGoogle({required String credential});

  Future<String> logout({required String refreshToken});

  Future<ForgotPasswordResponseModel> forgotPassword({required String email});

  Future<ResetPasswordResponseModel> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  });

  Future<RegisterInitiateResponseModel> registerInitiate({
    required String email,
    required String phone,
  });

  Future<RegisterVerifyResponseModel> registerVerify({
    required String sessionToken,
    required String otp,
  });

  Future<RegisterPasswordResponseModel> registerPassword({
    required String sessionToken,
    required String password,
  });

  Future<RegisterProfileResponseModel> registerProfile({
    required String sessionToken,
    required String firstName,
    required String lastName,
    required String birthday,
    required String address,
    XFile? profilePicture,
  });

  Future<UserProfileResponseModel> getUserProfile();

  Future<UserProfileResponseModel> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String birthday,
    required String address,
    XFile? profilePicture,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<String> logout({required String refreshToken}) async {
    final response = await _apiClient.postFlexible(
      EndpointConstant.logout,
      data: <String, dynamic>{'refreshToken': refreshToken},
    );
    final success = response['success'] as bool? ?? false;
    final message = response['message'] as String? ?? '';
    if (!success) {
      throw AppError(
        message.trim().isEmpty
            ? 'Unable to sign out. Please try again.'
            : message,
      );
    }
    return message.trim().isEmpty ? 'Logged out successfully.' : message;
  }

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      EndpointConstant.login,
      data: <String, dynamic>{'email': email, 'password': password},
    );
    final model = LoginResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<LoginResponseModel> loginWithGoogle({
    required String credential,
  }) async {
    final response = await _apiClient.post(
      EndpointConstant.googleLogin,
      data: <String, dynamic>{'credential': credential},
    );
    final model = LoginResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<ForgotPasswordResponseModel> forgotPassword({
    required String email,
  }) async {
    final response = await _apiClient.post(
      EndpointConstant.forgotPassword,
      data: <String, dynamic>{'email': email},
    );
    final model = ForgotPasswordResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<ResetPasswordResponseModel> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.post(
      EndpointConstant.resetPassword,
      data: <String, dynamic>{
        'email': email,
        'otp': otp,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    final model = ResetPasswordResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<RegisterInitiateResponseModel> registerInitiate({
    required String email,
    required String phone,
  }) async {
    final response = await _apiClient.post(
      EndpointConstant.registerInitiate,
      data: <String, dynamic>{'email': email, 'phone': phone},
    );
    final model = RegisterInitiateResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<RegisterVerifyResponseModel> registerVerify({
    required String sessionToken,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      EndpointConstant.registerVerify,
      data: <String, dynamic>{'sessionToken': sessionToken, 'otp': otp},
    );
    final model = RegisterVerifyResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<RegisterPasswordResponseModel> registerPassword({
    required String sessionToken,
    required String password,
  }) async {
    final response = await _apiClient.post(
      EndpointConstant.registerPassword,
      data: <String, dynamic>{
        'sessionToken': sessionToken,
        'password': password,
      },
    );
    final model = RegisterPasswordResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<RegisterProfileResponseModel> registerProfile({
    required String sessionToken,
    required String firstName,
    required String lastName,
    required String birthday,
    required String address,
    XFile? profilePicture,
  }) async {
    MultipartFile? profilePicturePart;
    if (profilePicture != null) {
      final profilePictureBytes = await profilePicture.readAsBytes();
      profilePicturePart = MultipartFile.fromBytes(
        profilePictureBytes,
        filename: profilePicture.name,
      );
    }

    final formFields = <String, dynamic>{
      'sessionToken': sessionToken,
      'firstName': firstName,
      'lastName': lastName,
      'birthday': birthday,
      'address': address,
    };

    if (profilePicturePart != null) {
      formFields['profilePicture'] = profilePicturePart;
    }

    final formData = FormData.fromMap(formFields);

    final response = await _apiClient.postMultipart(
      EndpointConstant.registerProfile,
      data: formData,
    );
    final model = RegisterProfileResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Something went wrong. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<UserProfileResponseModel> getUserProfile() async {
    final response = await _apiClient.get(EndpointConstant.userProfile);
    final model = UserProfileResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Unable to load profile. Please try again.'
            : model.message,
      );
    }

    return model;
  }

  @override
  Future<UserProfileResponseModel> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String birthday,
    required String address,
    XFile? profilePicture,
  }) async {
    MultipartFile? profilePicturePart;
    if (profilePicture != null) {
      final profilePictureBytes = await profilePicture.readAsBytes();
      profilePicturePart = MultipartFile.fromBytes(
        profilePictureBytes,
        filename: profilePicture.name,
      );
    }

    final formFields = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'birthday': birthday,
      'address': address,
    };

    if (profilePicturePart != null) {
      formFields['profilePicture'] = profilePicturePart;
    }

    final response = await _apiClient.putMultipart(
      EndpointConstant.userProfile,
      data: FormData.fromMap(formFields),
    );
    final model = UserProfileResponseModel.fromJson(response);

    if (!model.success) {
      throw AppError(
        model.message.isEmpty
            ? 'Unable to update profile. Please try again.'
            : model.message,
      );
    }

    return model;
  }
}
