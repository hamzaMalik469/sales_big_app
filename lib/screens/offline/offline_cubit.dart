import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/bid_model.dart';
import '../../services/bid_service.dart';
import '../../services/sync_service.dart';
import 'offline_state.dart';

class OfflineCubit extends Cubit<OfflineState> {
  final BidService _bidService;
  final SyncService _syncService;

  OfflineCubit({
    required BidService bidService,
    required SyncService syncService,
  }) : _bidService = bidService,
       _syncService = syncService,
       super(const OfflineState());

  /// Load bids that haven't been synced yet
  void loadOfflineEntries() {
    emit(state.copyWith(status: OfflineStatus.loading));

    try {
      final offlineBids = _bidService.getUnsyncedBids();

      emit(
        state.copyWith(status: OfflineStatus.loaded, offlineBids: offlineBids),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: OfflineStatus.error,
          errorMessage: 'Failed to load offline entries',
        ),
      );
    }
  }

  /// Trigger sync for all items
  Future<void> syncAll() async {
    if (state.isSyncing || state.offlineBids.isEmpty) return;

    emit(state.copyWith(isSyncing: true));

    try {
      await _syncService.syncAll();

      // Reload list after sync attempt
      loadOfflineEntries();

      emit(
        state.copyWith(
          isSyncing: false,
          successMessage: 'Sync process completed',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSyncing: false,
          errorMessage: 'Sync failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Delete a specific offline entry
  Future<void> deleteEntry(String id) async {
    try {
      await _bidService.deleteBid(id);
      loadOfflineEntries();
      emit(state.copyWith(successMessage: 'Entry deleted'));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete entry'));
    }
  }
}
