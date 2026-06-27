import 'dart:async';

import 'package:hive/hive.dart';

import '../models/bid_model.dart';
import 'bid_service.dart';
import 'connectivity_service.dart';

enum SyncState { idle, syncing, success, error }

class SyncStatus {
  final SyncState state;
  final int totalItems;
  final int syncedItems;
  final int failedItems;
  final String? message;
  final DateTime? lastSyncAt;

  const SyncStatus({
    this.state = SyncState.idle,
    this.totalItems = 0,
    this.syncedItems = 0,
    this.failedItems = 0,
    this.message,
    this.lastSyncAt,
  });

  factory SyncStatus.idle() => const SyncStatus(state: SyncState.idle);

  factory SyncStatus.syncing({int totalItems = 0, int syncedItems = 0}) {
    return SyncStatus(
      state: SyncState.syncing,
      totalItems: totalItems,
      syncedItems: syncedItems,
    );
  }

  factory SyncStatus.success({int totalItems = 0, DateTime? lastSyncAt}) {
    return SyncStatus(
      state: SyncState.success,
      totalItems: totalItems,
      syncedItems: totalItems,
      message: 'Sync completed successfully',
      lastSyncAt: lastSyncAt ?? DateTime.now(),
    );
  }

  factory SyncStatus.error({String? message, int failedItems = 0}) {
    return SyncStatus(
      state: SyncState.error,
      failedItems: failedItems,
      message: message ?? 'Sync failed',
    );
  }

  SyncStatus copyWith({
    SyncState? state,
    int? totalItems,
    int? syncedItems,
    int? failedItems,
    String? message,
    DateTime? lastSyncAt,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      totalItems: totalItems ?? this.totalItems,
      syncedItems: syncedItems ?? this.syncedItems,
      failedItems: failedItems ?? this.failedItems,
      message: message ?? this.message,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  double get progress {
    if (totalItems == 0) return 0.0;
    return syncedItems / totalItems;
  }

  bool get isIdle => state == SyncState.idle;
  bool get isSyncing => state == SyncState.syncing;
  bool get isSuccess => state == SyncState.success;
  bool get isError => state == SyncState.error;

  int get pendingItems => totalItems - syncedItems - failedItems;
}

class SyncService {
  final BidService _bidService;
  final ConnectivityService _connectivityService;
  final Box _syncBox;

  // Stream controller for sync status
  final _syncStatusController = StreamController<SyncStatus>.broadcast();

  // Current status
  SyncStatus _currentStatus = const SyncStatus();

  // Timer for periodic sync
  Timer? _periodicSyncTimer;

  // Sync lock
  bool _isSyncing = false;

  SyncService({
    required BidService bidService,
    required ConnectivityService connectivityService,
    required Box syncBox,
  }) : _bidService = bidService,
       _connectivityService = connectivityService,
       _syncBox = syncBox {
    _init();
  }

  /// Initialize sync service
  void _init() {
    // Listen to connectivity changes
    _connectivityService.statusStream.listen((status) {
      if (status == ConnectionStatus.online) {
        // Auto sync when coming online
        syncAll();
      }
    });

    // Start periodic sync (every 5 minutes)
    _startPeriodicSync();
  }

  /// Start periodic sync timer
  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_connectivityService.isConnected && !_isSyncing) {
        syncAll();
      }
    });
  }

  /// Stream of sync status changes
  Stream<SyncStatus> get statusStream => _syncStatusController.stream;

  /// Current sync status
  SyncStatus get currentStatus => _currentStatus;

  /// Check if syncing
  bool get isSyncing => _isSyncing;

  /// Get pending sync count
  int get pendingSyncCount => _bidService.getSyncQueue().length;

  /// Get unsynced bids
  List<BidModel> get unsyncedBids => _bidService.getUnsyncedBids();

  /// Sync all pending items
  Future<SyncStatus> syncAll() async {
    if (_isSyncing) {
      return _currentStatus;
    }

    if (!_connectivityService.isConnected) {
      _updateStatus(SyncStatus.error(message: 'No internet connection'));
      return _currentStatus;
    }

    _isSyncing = true;
    final syncQueue = _bidService.getSyncQueue();

    if (syncQueue.isEmpty) {
      _updateStatus(SyncStatus.success(lastSyncAt: DateTime.now()));
      _isSyncing = false;
      return _currentStatus;
    }

    _updateStatus(SyncStatus.syncing(totalItems: syncQueue.length));

    int syncedCount = 0;
    int failedCount = 0;

    for (final item in syncQueue) {
      try {
        await _processSyncItem(item);
        syncedCount++;
        _updateStatus(_currentStatus.copyWith(syncedItems: syncedCount));
      } catch (e) {
        failedCount++;
        print('❌ Sync failed for item ${item['id']}: $e');

        // Increment retry count
        await _incrementRetryCount(item['id']);
      }
    }

    if (failedCount == 0) {
      _updateStatus(
        SyncStatus.success(totalItems: syncedCount, lastSyncAt: DateTime.now()),
      );
    } else {
      _updateStatus(
        SyncStatus(
          state: failedCount == syncQueue.length
              ? SyncState.error
              : SyncState.success,
          totalItems: syncQueue.length,
          syncedItems: syncedCount,
          failedItems: failedCount,
          message: 'Synced $syncedCount, failed $failedCount',
          lastSyncAt: DateTime.now(),
        ),
      );
    }

    _isSyncing = false;
    return _currentStatus;
  }

  /// Sync single item
  Future<bool> syncItem(String id) async {
    if (!_connectivityService.isConnected) {
      return false;
    }

    final item = _syncBox.get(id);
    if (item == null) return false;

    try {
      await _processSyncItem(Map<String, dynamic>.from(item));
      return true;
    } catch (e) {
      print('❌ Sync failed for item $id: $e');
      return false;
    }
  }

  /// Process single sync item
  Future<void> _processSyncItem(Map<String, dynamic> item) async {
    final id = item['id'] as String;
    final action = item['action'] as String;
    final data = Map<String, dynamic>.from(item['data']);

    switch (action) {
      case 'create':
        final bid = BidModel.fromJson(data);
        final response = await _bidService.createBid(bid);
        if (response.success && response.data != null) {
          await _bidService.removeFromSyncQueue(id);
        } else {
          throw Exception(response.message);
        }
        break;

      case 'update':
        final bid = BidModel.fromJson(data);
        final response = await _bidService.updateBid(bid);
        if (response.success && response.data != null) {
          await _bidService.removeFromSyncQueue(id);
        } else {
          throw Exception(response.message);
        }
        break;

      case 'delete':
        final response = await _bidService.deleteBid(id);
        if (response.success) {
          await _bidService.removeFromSyncQueue(id);
        } else {
          throw Exception(response.message);
        }
        break;
    }

    print('✅ Synced item $id ($action)');
  }

  /// Increment retry count for failed item
  Future<void> _incrementRetryCount(String id) async {
    final item = _syncBox.get(id);
    if (item != null) {
      final data = Map<String, dynamic>.from(item);
      final retryCount = (data['retry_count'] ?? 0) + 1;

      // Remove if too many retries (max 5)
      if (retryCount >= 5) {
        await _syncBox.delete(id);
        print('⚠️ Removed item $id after 5 failed attempts');
      } else {
        data['retry_count'] = retryCount;
        data['last_retry'] = DateTime.now().toIso8601String();
        await _syncBox.put(id, data);
      }
    }
  }

  /// Update status and notify listeners
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
    print('🔄 Sync status: ${status.state.name} - ${status.message ?? ""}');
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    await _syncBox.clear();
    _updateStatus(const SyncStatus());
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    return _currentStatus.lastSyncAt;
  }

  /// Force sync
  Future<SyncStatus> forceSync() async {
    _isSyncing = false; // Reset lock
    return await syncAll();
  }

  /// Dispose
  void dispose() {
    _periodicSyncTimer?.cancel();
    _syncStatusController.close();
  }
}
