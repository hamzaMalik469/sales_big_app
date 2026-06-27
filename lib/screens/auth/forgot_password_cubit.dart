import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthService _authService;

  ForgotPasswordCubit({required AuthService authService})
    : _authService = authService,
      super(const ForgotPasswordState());

  /// Update email
  void emailChanged(String value) {
    String? error;
    if (value.isNotEmpty) {
      error = Validators.email(value);
    }
    emit(state.copyWith(email: value, emailError: error, errorMessage: null));
  }

  /// Submit forgot password request
  Future<void> submit() async {
    // Validate email
    final emailError = Validators.email(state.email);
    if (emailError != null) {
      emit(state.copyWith(emailError: emailError));
      return;
    }

    emit(
      state.copyWith(status: ForgotPasswordStatus.loading, errorMessage: null),
    );

    try {
      final response = await _authService.forgotPassword(
        email: state.email.trim(),
      );

      if (response.success) {
        emit(
          state.copyWith(
            status: ForgotPasswordStatus.success,
            successMessage:
                response.message ??
                'Password reset link has been sent to your email.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ForgotPasswordStatus.failure,
            errorMessage: response.message ?? 'Failed to send reset link.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  /// Reset to initial state
  void reset() {
    emit(const ForgotPasswordState());
  }
}
