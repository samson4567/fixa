import 'package:fixa/features/auth/domain/entities/forgot_password_result.dart';
import 'package:fixa/features/auth/domain/entities/login_result.dart';
import 'package:fixa/features/auth/domain/entities/reset_password_result.dart';
import 'package:fixa/features/auth/domain/entities/register_initiate_result.dart';
import 'package:fixa/features/auth/domain/entities/register_password_result.dart';
import 'package:fixa/features/auth/domain/entities/register_profile_result.dart';
import 'package:fixa/features/auth/domain/entities/register_verify_result.dart';
import 'package:fixa/features/auth/domain/entities/user_profile_result.dart';
import 'package:image_picker/image_picker.dart';

abstract class AuthRepository {
  Future<LoginResult> login({required String email, required String password});
  Future<LoginResult> loginWithGoogle({required String credential});
  Future<String> logout({required String refreshToken});

  Future<ForgotPasswordResult> forgotPassword({required String email});

  Future<ResetPasswordResult> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  });

  Future<RegisterInitiateResult> registerInitiate({
    required String email,
    required String phone,
  });

  Future<RegisterVerifyResult> registerVerify({
    required String sessionToken,
    required String otp,
  });

  Future<RegisterPasswordResult> registerPassword({
    required String sessionToken,
    required String password,
  });

  Future<RegisterProfileResult> registerProfile({
    required String sessionToken,
    required String firstName,
    required String lastName,
    required String birthday,
    required String address,
    XFile? profilePicture,
  });

  Future<UserProfileResult> getUserProfile();

  Future<UserProfileResult> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String birthday,
    required String address,
    XFile? profilePicture,
  });
}
