import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/bid_service.dart';
import 'bid_details_state.dart';

class BidDetailsCubit extends Cubit<BidDetailsState> {
  final BidService _bidService;

  BidDetailsCubit({required BidService bidService})
    : _bidService = bidService,
      super(const BidDetailsState());

  Future<void> loadBid(String id) async {
    emit(state.copyWith(status: BidDetailsStatus.loading));

    try {
      final response = await _bidService.getBidById(id);

      if (response.success && response.data != null) {
        emit(
          state.copyWith(status: BidDetailsStatus.loaded, bid: response.data),
        );
      } else {
        emit(
          state.copyWith(
            status: BidDetailsStatus.error,
            errorMessage: response.message ?? 'Bid not found',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: BidDetailsStatus.error,
          errorMessage: 'Failed to load bid details',
        ),
      );
    }
  }

  Future<void> deleteBid() async {
    if (state.bid == null) return;

    emit(state.copyWith(status: BidDetailsStatus.deleting));

    try {
      final response = await _bidService.deleteBid(state.bid!.id);

      if (response.success) {
        emit(state.copyWith(successMessage: 'Bid deleted successfully'));
      } else {
        emit(
          state.copyWith(
            status: BidDetailsStatus.error,
            errorMessage: response.message ?? 'Failed to delete bid',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: BidDetailsStatus.error,
          errorMessage: 'An unexpected error occurred',
        ),
      );
    }
  }

  Future<void> submitBid() async {
    if (state.bid == null) return;

    emit(state.copyWith(status: BidDetailsStatus.loading));

    try {
      final response = await _bidService.submitBid(state.bid!.id);

      if (response.success && response.data != null) {
        emit(
          state.copyWith(
            status: BidDetailsStatus.loaded,
            bid: response.data,
            successMessage: 'Bid submitted successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: BidDetailsStatus.loaded, // Revert to loaded
            errorMessage: response.message ?? 'Failed to submit bid',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: BidDetailsStatus.loaded,
          errorMessage: 'Failed to submit bid',
        ),
      );
    }
  }
}
