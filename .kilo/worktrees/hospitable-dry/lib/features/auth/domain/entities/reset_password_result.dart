import 'package:equatable/equatable.dart';

class ResetPasswordResult extends Equatable {
  const ResetPasswordResult({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
