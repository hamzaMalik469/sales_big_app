import '../../models/bid_model.dart';

enum BidListStatus { initial, loading, loaded, error }

enum BidFilter { all, pending, approved, draft, rejected }

class BidListState {
  final BidListStatus status;
  final List<BidModel> bids;
  final List<BidModel> filteredBids;
  final BidFilter currentFilter;
  final String searchQuery;
  final String? errorMessage;
  final bool isRefreshing;
  final bool isOffline;

  const BidListState({
    this.status = BidListStatus.initial,
    this.bids = const [],
    this.filteredBids = const [],
    this.currentFilter = BidFilter.all,
    this.searchQuery = '',
    this.errorMessage,
    this.isRefreshing = false,
    this.isOffline = false,
  });

  BidListState copyWith({
    BidListStatus? status,
    List<BidModel>? bids,
    List<BidModel>? filteredBids,
    BidFilter? currentFilter,
    String? searchQuery,
    String? errorMessage,
    bool? isRefreshing,
    bool? isOffline,
  }) {
    return BidListState(
      status: status ?? this.status,
      bids: bids ?? this.bids,
      filteredBids: filteredBids ?? this.filteredBids,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  bool get isLoading => status == BidListStatus.loading;
  bool get isLoaded => status == BidListStatus.loaded;
  bool get hasError => status == BidListStatus.error;
  bool get isEmpty => isLoaded && filteredBids.isEmpty;
}