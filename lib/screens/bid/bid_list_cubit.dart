import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/bid_model.dart';
import '../../services/bid_service.dart';
import '../../services/connectivity_service.dart';
import 'bid_list_state.dart';

class BidListCubit extends Cubit<BidListState> {
  final BidService _bidService;
  final ConnectivityService _connectivityService;

  BidListCubit({
    required BidService bidService,
    required ConnectivityService connectivityService,
  }) : _bidService = bidService,
       _connectivityService = connectivityService,
       super(const BidListState()) {
    _initConnectivity();
  }

  void _initConnectivity() {
    emit(state.copyWith(isOffline: !_connectivityService.isConnected));
    _connectivityService.statusStream.listen((status) {
      emit(state.copyWith(isOffline: status == ConnectionStatus.offline));
    });
  }

  Future<void> loadBids() async {
    emit(state.copyWith(status: BidListStatus.loading));

    try {
      final response = await _bidService.getBids();

      if (response.success && response.data != null) {
        final bids = response.data!;
        emit(
          state.copyWith(
            status: BidListStatus.loaded,
            bids: bids,
            filteredBids: _applyFilters(
              bids,
              state.currentFilter,
              state.searchQuery,
            ),
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: BidListStatus.error,
            errorMessage: response.message ?? 'Failed to load bids',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: BidListStatus.error,
          errorMessage: 'An unexpected error occurred',
        ),
      );
    }
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;

    emit(state.copyWith(isRefreshing: true));
    await loadBids();
    emit(state.copyWith(isRefreshing: false));
  }

  void setFilter(BidFilter filter) {
    emit(
      state.copyWith(
        currentFilter: filter,
        filteredBids: _applyFilters(state.bids, filter, state.searchQuery),
      ),
    );
  }

  void search(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        filteredBids: _applyFilters(state.bids, state.currentFilter, query),
      ),
    );
  }

  List<BidModel> _applyFilters(
    List<BidModel> bids,
    BidFilter filter,
    String query,
  ) {
    List<BidModel> filtered = bids;

    // Apply Status Filter
    if (filter != BidFilter.all) {
      filtered = filtered.where((bid) {
        switch (filter) {
          case BidFilter.pending:
            return bid.isPending;
          case BidFilter.approved:
            return bid.isApproved;
          case BidFilter.draft:
            return bid.isDraft;
          case BidFilter.rejected:
            return bid.isRejected;
          default:
            return true;
        }
      }).toList();
    }

    // Apply Search
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((bid) {
        return bid.clientName.toLowerCase().contains(q) ||
            bid.projectName.toLowerCase().contains(q) ||
            (bid.projectType?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Sort by Date (Newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }
}
