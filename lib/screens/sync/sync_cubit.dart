import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/connectivity_service.dart';
import '../../services/sync_service.dart';
import 'sync_state.dart';

class SyncCubit extends Cubit<SyncScreenState> {
  final SyncService _syncService;
  final ConnectivityService _connectivityService;

  StreamSubscription<SyncStatus>? _syncSubscription;
  StreamSubscription<ConnectionStatus>? _connSubscription;

  SyncCubit({
    required SyncService syncService,
    required ConnectivityService connectivityService,
  }) : _syncService = syncService,
       _connectivityService = connectivityService,
       super(const SyncScreenState()) {
    _init();
  }

  void _init() {
    // Initial status
    emit(
      state.copyWith(
        status: _syncService.currentStatus,
        isConnected: _connectivityService.isConnected,
      ),
    );

    // Listen to sync stream
    _syncSubscription = _syncService.statusStream.listen((status) {
      emit(state.copyWith(status: status));
    });

    // Listen to connectivity
    _connSubscription = _connectivityService.statusStream.listen((status) {
      emit(state.copyWith(isConnected: status == ConnectionStatus.online));
    });
  }

  Future<void> startSync() async {
    await _syncService.forceSync();
  }

  @override
  Future<void> close() {
    _syncSubscription?.cancel();
    _connSubscription?.cancel();
    return super.close();
  }
}
