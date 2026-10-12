import 'package:fixa/features/auth/domain/entities/user_profile_result.dart';

class UserProfileResponseModel {
  const UserProfileResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final UserProfileDataModel data;

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: UserProfileDataModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  UserProfileResult toEntity() {
    return UserProfileResult(
      id: data.id,
      email: data.email,
      role: data.role,
      isVerified: data.isVerified,
      firstName: data.firstName,
      lastName: data.lastName,
      phone: data.phone,
      birthday: data.birthday,
      address: data.address,
      profilePicture: data.profilePicture,
    );
  }
}

class UserProfileDataModel {
  const UserProfileDataModel({
    required this.id,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.birthday,
    required this.address,
    required this.profilePicture,
  });

  final String id;
  final String email;
  final String role;
  final bool isVerified;
  final String firstName;
  final String lastName;
  final String phone;
  final String birthday;
  final String address;
  final String profilePicture;

  factory UserProfileDataModel.fromJson(Map<String, dynamic> json) {
    return UserProfileDataModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isVerified: json['isVerified'] == true,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      birthday: json['birthday'] as String? ?? '',
      address: json['address'] as String? ?? '',
      profilePicture: json['profilePicture'] as String? ?? '',
    );
  }
}
