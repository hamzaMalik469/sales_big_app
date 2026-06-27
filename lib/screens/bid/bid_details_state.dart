import '../../models/bid_model.dart';

enum BidDetailsStatus { initial, loading, loaded, error, deleting }

class BidDetailsState {
  final BidDetailsStatus status;
  final BidModel? bid;
  final String? errorMessage;
  final String? successMessage;
  final bool isOffline;

  const BidDetailsState({
    this.status = BidDetailsStatus.initial,
    this.bid,
    this.errorMessage,
    this.successMessage,
    this.isOffline = false,
  });

  BidDetailsState copyWith({
    BidDetailsStatus? status,
    BidModel? bid,
    String? errorMessage,
    String? successMessage,
    bool? isOffline,
  }) {
    return BidDetailsState(
      status: status ?? this.status,
      bid: bid ?? this.bid,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  bool get isLoading => status == BidDetailsStatus.loading;
  bool get isDeleting => status == BidDetailsStatus.deleting;
  bool get isLoaded => status == BidDetailsStatus.loaded && bid != null;
  bool get hasError => status == BidDetailsStatus.error;
}
