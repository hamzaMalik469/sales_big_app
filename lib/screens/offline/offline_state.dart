import '../../models/bid_model.dart';

enum OfflineStatus { initial, loading, loaded, error }

class OfflineState {
  final OfflineStatus status;
  final List<BidModel> offlineBids;
  final String? errorMessage;
  final String? successMessage;
  final bool isSyncing;

  const OfflineState({
    this.status = OfflineStatus.initial,
    this.offlineBids = const [],
    this.errorMessage,
    this.successMessage,
    this.isSyncing = false,
  });

  OfflineState copyWith({
    OfflineStatus? status,
    List<BidModel>? offlineBids,
    String? errorMessage,
    String? successMessage,
    bool? isSyncing,
  }) {
    return OfflineState(
      status: status ?? this.status,
      offlineBids: offlineBids ?? this.offlineBids,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  bool get isLoading => status == OfflineStatus.loading;
  bool get isEmpty => offlineBids.isEmpty;
}
