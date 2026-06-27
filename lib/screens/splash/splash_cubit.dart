import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/auth_service.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthService _authService;

  SplashCubit({required AuthService authService})
    : _authService = authService,
      super(const SplashState());

  /// Initialize app and check authentication
  Future<void> initialize() async {
    emit(state.copyWith(status: SplashStatus.loading, loadingProgress: 0.1));

    try {
      // Simulate loading stages
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(loadingProgress: 0.3));

      // Check if user has token
      final hasToken = await _authService.hasToken();
      emit(state.copyWith(loadingProgress: 0.6));

      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(loadingProgress: 0.9));

      if (hasToken) {
        // Validate token by fetching profile
        final response = await _authService.getProfile();

        await Future.delayed(const Duration(milliseconds: 300));
        emit(state.copyWith(loadingProgress: 1.0));

        if (response.success && response.data != null) {
          emit(state.copyWith(status: SplashStatus.authenticated));
        } else {
          // Token invalid, clear and go to login
          await _authService.logout();
          emit(state.copyWith(status: SplashStatus.unauthenticated));
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        emit(state.copyWith(loadingProgress: 1.0));
        emit(state.copyWith(status: SplashStatus.unauthenticated));
      }
    } catch (e) {
      // On error, still allow access (might be offline)
      final hasToken = await _authService.hasToken();
      if (hasToken) {
        emit(state.copyWith(status: SplashStatus.authenticated));
      } else {
        emit(state.copyWith(status: SplashStatus.unauthenticated));
      }
    }
  }
}
