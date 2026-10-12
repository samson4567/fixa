import 'package:equatable/equatable.dart';

class AppState extends Equatable {
  const AppState({
    this.registrationEmail,
    this.registrationPhone,
    this.registrationSessionToken,
    this.registrationStep,
  });

  final String? registrationEmail;
  final String? registrationPhone;
  final String? registrationSessionToken;
  final String? registrationStep;

  AppState copyWith({
    String? registrationEmail,
    String? registrationPhone,
    String? registrationSessionToken,
    String? registrationStep,
    bool clearRegistration = false,
  }) {
    if (clearRegistration) {
      return const AppState();
    }

    return AppState(
      registrationEmail: registrationEmail ?? this.registrationEmail,
      registrationPhone: registrationPhone ?? this.registrationPhone,
      registrationSessionToken:
          registrationSessionToken ?? this.registrationSessionToken,
      registrationStep: registrationStep ?? this.registrationStep,
    );
  }

  @override
  List<Object?> get props => [
    registrationEmail,
    registrationPhone,
    registrationSessionToken,
    registrationStep,
  ];
}
