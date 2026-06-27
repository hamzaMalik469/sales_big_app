enum SplashStatus { initial, loading, authenticated, unauthenticated, error }

class SplashState {
  final SplashStatus status;
  final String? errorMessage;
  final double loadingProgress;

  const SplashState({
    this.status = SplashStatus.initial,
    this.errorMessage,
    this.loadingProgress = 0.0,
  });

  SplashState copyWith({
    SplashStatus? status,
    String? errorMessage,
    double? loadingProgress,
  }) {
    return SplashState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      loadingProgress: loadingProgress ?? this.loadingProgress,
    );
  }

  bool get isLoading => status == SplashStatus.loading;
  bool get isAuthenticated => status == SplashStatus.authenticated;
  bool get isUnauthenticated => status == SplashStatus.unauthenticated;
  bool get hasError => status == SplashStatus.error;
}
