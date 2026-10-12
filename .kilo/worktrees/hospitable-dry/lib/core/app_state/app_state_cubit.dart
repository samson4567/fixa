import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/app_state/app_state.dart';

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(const AppState());

  void setRegistrationSession({
    required String email,
    required String phone,
    required String sessionToken,
    required String step,
  }) {
    emit(
      state.copyWith(
        registrationEmail: email,
        registrationPhone: phone,
        registrationSessionToken: sessionToken,
        registrationStep: step,
      ),
    );
  }

  void clearRegistrationSession() {
    emit(state.copyWith(clearRegistration: true));
  }
}
