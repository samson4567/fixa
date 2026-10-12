import 'package:fixa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fixa/features/auth/domain/entities/forgot_password_result.dart';
import 'package:fixa/features/auth/domain/entities/login_result.dart';
import 'package:fixa/features/auth/domain/entities/reset_password_result.dart';
import 'package:fixa/features/auth/domain/entities/register_initiate_result.dart';
import 'package:fixa/features/auth/domain/entities/register_password_result.dart';
import 'package:fixa/features/auth/domain/entities/register_profile_result.dart';
import 'package:fixa/features/auth/domain/entities/register_verify_result.dart';
import 'package:fixa/features/auth/domain/entities/user_profile_result.dart';
import 'package:fixa/features/auth/domain/repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<String> logout({required String refreshToken}) =>
      _remoteDataSource.logout(refreshToken: refreshToken);

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    return response.toEntity();
  }

  @override
  Future<LoginResult> loginWithGoogle({required String credential}) async {
    final response = await _remoteDataSource.loginWithGoogle(
      credential: credential,
    );

    return response.toEntity();
  }

  @override
  Future<ForgotPasswordResult> forgotPassword({required String email}) async {
    final response = await _remoteDataSource.forgotPassword(email: email);

    return response.toEntity();
  }

  @override
  Future<ResetPasswordResult> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _remoteDataSource.resetPassword(
      email: email,
      otp: otp,
      password: password,
      confirmPassword: confirmPassword,
    );

    return response.toEntity();
  }

  @override
  Future<RegisterInitiateResult> registerInitiate({
    required String email,
    required String phone,
  }) async {
    final response = await _remoteDataSource.registerInitiate(
      email: email,
      phone: phone,
    );

    return response.toEntity();
  }

  @override
  Future<RegisterVerifyResult> registerVerify({
    required String sessionToken,
    required String otp,
  }) async {
    final response = await _remoteDataSource.registerVerify(
      sessionToken: sessionToken,
      otp: otp,
    );

    return response.toEntity();
  }

  @override
  Future<RegisterPasswordResult> registerPassword({
    required String sessionToken,
    required String password,
  }) async {
    final response = await _remoteDataSource.registerPassword(
      sessionToken: sessionToken,
      password: password,
    );

    return response.toEntity();
  }

  @override
  Future<RegisterProfileResult> registerProfile({
    required String sessionToken,
    required String firstName,
    required String lastName,
    required String birthday,
    required String address,
    XFile? profilePicture,
  }) async {
    final response = await _remoteDataSource.registerProfile(
      sessionToken: sessionToken,
      firstName: firstName,
      lastName: lastName,
      birthday: birthday,
      address: address,
      profilePicture: profilePicture,
    );

    return response.toEntity();
  }

  @override
  Future<UserProfileResult> getUserProfile() async {
    final response = await _remoteDataSource.getUserProfile();
    return response.toEntity();
  }

  @override
  Future<UserProfileResult> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String birthday,
    required String address,
    XFile? profilePicture,
  }) async {
    final response = await _remoteDataSource.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      birthday: birthday,
      address: address,
      profilePicture: profilePicture,
    );
    return response.toEntity();
  }
}
