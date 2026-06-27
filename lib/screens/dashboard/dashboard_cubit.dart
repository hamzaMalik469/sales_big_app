import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/bid_model.dart';
import '../../services/bid_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/sync_service.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final BidService _bidService;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  StreamSubscription<ConnectionStatus>? _connectivitySubscription;
  StreamSubscription<SyncStatus>? _syncSubscription;

  DashboardCubit({
    required BidService bidService,
    required ConnectivityService connectivityService,
    required SyncService syncService,
  }) : _bidService = bidService,
       _connectivityService = connectivityService,
       _syncService = syncService,
       super(const DashboardState()) {
    _init();
  }

  void _init() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.statusStream.listen((
      status,
    ) {
      emit(state.copyWith(connectionStatus: status));

      // Auto refresh when coming online
      if (status == ConnectionStatus.online) {
        refresh();
      }
    });

    // Listen to sync status changes
    _syncSubscription = _syncService.statusStream.listen((syncStatus) {
      emit(state.copyWith(syncStatus: syncStatus));
    });

    // Set initial connectivity status
    emit(state.copyWith(connectionStatus: _connectivityService.currentStatus));
  }

  /// Load dashboard data
  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      // Load stats
      final stats = await _bidService.getDashboardStats();

      // Load recent bids
      final recentBids = _bidService.getRecentBids(limit: 5);

      emit(
        state.copyWith(
          status: DashboardStatus.loaded,
          stats: stats,
          recentBids: recentBids,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: 'Failed to load dashboard data',
        ),
      );
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    emit(state.copyWith(isRefreshing: true));

    try {
      // Fetch bids from API if online
      if (_connectivityService.isConnected) {
        await _bidService.getBids();
      }

      // Reload stats and recent bids
      final stats = await _bidService.getDashboardStats();
      final recentBids = _bidService.getRecentBids(limit: 5);

      emit(
        state.copyWith(
          status: DashboardStatus.loaded,
          stats: stats,
          recentBids: recentBids,
          isRefreshing: false,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isRefreshing: false,
          errorMessage: 'Failed to refresh data',
        ),
      );
    }
  }

  /// Sync pending data
  Future<void> syncData() async {
    if (_syncService.isSyncing) return;

    await _syncService.syncAll();
    await refresh();
  }

  /// Get bids by status
  void navigateToBidsByStatus(String status) {
    // This will be handled by the UI layer
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _syncSubscription?.cancel();
    return super.close();
  }
}
