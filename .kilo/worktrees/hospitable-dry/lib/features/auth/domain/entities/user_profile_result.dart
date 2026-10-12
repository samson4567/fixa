import 'package:equatable/equatable.dart';

class UserProfileResult extends Equatable {
  const UserProfileResult({
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

  String get fullName => '$firstName $lastName'.trim();

  UserProfileResult copyWith({
    String? id,
    String? email,
    String? role,
    bool? isVerified,
    String? firstName,
    String? lastName,
    String? phone,
    String? birthday,
    String? address,
    String? profilePicture,
  }) {
    return UserProfileResult(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    role,
    isVerified,
    firstName,
    lastName,
    phone,
    birthday,
    address,
    profilePicture,
  ];
}
