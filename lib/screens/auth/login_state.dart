enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final LoginStatus status;
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool rememberMe;
  final String? errorMessage;
  final String? emailError;
  final String? passwordError;

  const LoginState({
    this.status = LoginStatus.initial,
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.rememberMe = false,
    this.errorMessage,
    this.emailError,
    this.passwordError,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? rememberMe,
    String? errorMessage,
    String? emailError,
    String? passwordError,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: errorMessage,
      emailError: emailError,
      passwordError: passwordError,
    );
  }

  // Getters
  bool get isLoading => status == LoginStatus.loading;
  bool get isSuccess => status == LoginStatus.success;
  bool get isFailure => status == LoginStatus.failure;
  bool get hasError =>
      errorMessage != null || emailError != null || passwordError != null;

  bool get isFormValid {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        emailError == null &&
        passwordError == null;
  }

  bool get canSubmit => isFormValid && !isLoading;
}
