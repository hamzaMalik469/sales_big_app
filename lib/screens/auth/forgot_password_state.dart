enum ForgotPasswordStatus { initial, loading, success, failure }

class ForgotPasswordState {
  final ForgotPasswordStatus status;
  final String email;
  final String? emailError;
  final String? errorMessage;
  final String? successMessage;

  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.email = '',
    this.emailError,
    this.errorMessage,
    this.successMessage,
  });

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? email,
    String? emailError,
    String? errorMessage,
    String? successMessage,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      emailError: emailError,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  // Getters
  bool get isLoading => status == ForgotPasswordStatus.loading;
  bool get isSuccess => status == ForgotPasswordStatus.success;
  bool get isFailure => status == ForgotPasswordStatus.failure;
  bool get isFormValid => email.isNotEmpty && emailError == null;
  bool get canSubmit => isFormValid && !isLoading;
}
