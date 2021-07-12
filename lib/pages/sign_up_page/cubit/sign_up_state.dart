part of 'sign_up_cubit.dart';

class SignUpState extends Equatable {
  const SignUpState({
    this.displayName = const Text.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.status = FormzStatus.pure,
    this.error = '',
  });

  final Text displayName;
  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final FormzStatus status;
  final String error;

  @override
  List<Object> get props =>
      [displayName, email, password, confirmedPassword, status, error];

  SignUpState copyWith({
    Text? displayName,
    Email? email,
    Password? password,
    ConfirmedPassword? confirmedPassword,
    FormzStatus? status,
    String? error,
  }) {
    return SignUpState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}
