import 'package:hive/hive.dart';
import 'package:sales_bid_app/screens/dashboard/dashboard_state.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/bid_model.dart';
import 'connectivity_service.dart';

class BidService {
  final ApiClient _apiClient;
  final Box _bidBox;
  final Box _syncBox;
  final ConnectivityService _connectivityService;

  BidService({
    required ApiClient apiClient,
    required Box bidBox,
    required Box syncBox,
    required ConnectivityService connectivityService,
  }) : _apiClient = apiClient,
       _bidBox = bidBox,
       _syncBox = syncBox,
       _connectivityService = connectivityService;

  // ==================== CRUD OPERATIONS ====================

  /// Get all bids
  Future<ApiResponse<List<BidModel>>> getBids({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Check connectivity
      if (_connectivityService.isConnected) {
        // Fetch from API
        final response = await _apiClient.get(
          ApiEndpoints.bids,
          queryParameters: {
            if (status != null) 'status': status,
            'page': page,
            'per_page': perPage,
          },
        );

        final bids =
            (response['data'] as List?)
                ?.map((json) => BidModel.fromJson(json))
                .toList() ??
            [];

        // Cache locally
        await _cacheBids(bids);

        return ApiResponse.success(
          data: bids,
          meta: response['meta'] != null
              ? PaginationMeta.fromJson(response['meta'])
              : null,
        );
      } else {
        // Return from local cache
        return ApiResponse.success(
          data: _getLocalBids(status: status),
          message: 'Showing offline data',
        );
      }
    } on ApiException catch (e) {
      // Return cached data on error
      return ApiResponse.success(
        data: _getLocalBids(status: status),
        message: 'Showing cached data: ${e.message}',
      );
    } catch (e) {
      return ApiResponse.success(
        data: _getLocalBids(status: status),
        message: 'Showing cached data',
      );
    }
  }

  /// Get bid by ID
  Future<ApiResponse<BidModel>> getBidById(String id) async {
    try {
      // Check local first
      final localBid = _getLocalBidById(id);

      if (_connectivityService.isConnected) {
        try {
          final response = await _apiClient.get(ApiEndpoints.bidDetails(id));
          final bid = BidModel.fromJson(response['data'] ?? response);

          // Cache locally
          await _saveBidLocally(bid);

          return ApiResponse.success(data: bid);
        } catch (e) {
          // Return local if API fails
          if (localBid != null) {
            return ApiResponse.success(
              data: localBid,
              message: 'Showing cached data',
            );
          }
          rethrow;
        }
      } else {
        if (localBid != null) {
          return ApiResponse.success(
            data: localBid,
            message: 'Showing offline data',
          );
        }
        return ApiResponse.error(message: 'Bid not found offline');
      }
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message);
    } catch (e) {
      return ApiResponse.error(message: 'Failed to load bid');
    }
  }

  /// Create new bid
  Future<ApiResponse<BidModel>> createBid(BidModel bid) async {
    try {
      // Always save locally first
      final localBid = bid.copyWith(isSynced: _connectivityService.isConnected);
      await _saveBidLocally(localBid);

      if (_connectivityService.isConnected) {
        // Create on server
        final response = await _apiClient.post(
          ApiEndpoints.bids,
          data: bid.toJson(),
        );

        final serverBid = BidModel.fromJson(response['data'] ?? response);

        // Update local with server ID
        final syncedBid = localBid.copyWith(
          serverBidId: serverBid.id,
          isSynced: true,
        );
        await _saveBidLocally(syncedBid);

        return ApiResponse.success(
          data: syncedBid,
          message: response['message'] ?? 'Bid created successfully',
        );
      } else {
        // Add to sync queue
        await _addToSyncQueue(localBid.id, 'create', localBid.toJson());

        return ApiResponse.success(
          data: localBid,
          message: 'Bid saved offline. Will sync when online.',
        );
      }
    } on ApiException catch (e) {
      // Save locally if API fails
      final offlineBid = bid.copyWith(isSynced: false);
      await _saveBidLocally(offlineBid);
      await _addToSyncQueue(offlineBid.id, 'create', offlineBid.toJson());

      return ApiResponse.success(
        data: offlineBid,
        message: 'Saved offline due to error: ${e.message}',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Failed to create bid');
    }
  }

  /// Update bid
  Future<ApiResponse<BidModel>> updateBid(BidModel bid) async {
    try {
      // Update locally first
      final localBid = bid.copyWith(
        updatedAt: DateTime.now(),
        isSynced: _connectivityService.isConnected,
      );
      await _saveBidLocally(localBid);

      if (_connectivityService.isConnected) {
        final response = await _apiClient.put(
          ApiEndpoints.updateBid(bid.serverBidId ?? bid.id),
          data: bid.toJson(),
        );

        final syncedBid = localBid.copyWith(isSynced: true);
        await _saveBidLocally(syncedBid);

        return ApiResponse.success(
          data: syncedBid,
          message: response['message'] ?? 'Bid updated successfully',
        );
      } else {
        await _addToSyncQueue(localBid.id, 'update', localBid.toJson());

        return ApiResponse.success(
          data: localBid,
          message: 'Bid updated offline. Will sync when online.',
        );
      }
    } on ApiException catch (e) {
      final offlineBid = bid.copyWith(isSynced: false);
      await _saveBidLocally(offlineBid);
      await _addToSyncQueue(offlineBid.id, 'update', offlineBid.toJson());

      return ApiResponse.success(
        data: offlineBid,
        message: 'Saved offline due to error: ${e.message}',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Failed to update bid');
    }
  }

  /// Delete bid
  Future<ApiResponse<void>> deleteBid(String id) async {
    try {
      final bid = _getLocalBidById(id);

      if (_connectivityService.isConnected && bid?.serverBidId != null) {
        await _apiClient.delete(ApiEndpoints.deleteBid(bid!.serverBidId!));
      }

      // Delete locally
      await _bidBox.delete(id);

      // Remove from sync queue if exists
      await _syncBox.delete(id);

      return ApiResponse.success(message: 'Bid deleted successfully');
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message);
    } catch (e) {
      return ApiResponse.error(message: 'Failed to delete bid');
    }
  }

  /// Submit bid (change status to pending)
  Future<ApiResponse<BidModel>> submitBid(String id) async {
    final bid = _getLocalBidById(id);
    if (bid == null) {
      return ApiResponse.error(message: 'Bid not found');
    }

    final submittedBid = bid.copyWith(
      status: 'pending',
      submittedAt: DateTime.now(),
    );

    return await updateBid(submittedBid);
  }

  // ==================== LOCAL STORAGE OPERATIONS ====================

  /// Get all local bids
  List<BidModel> _getLocalBids({String? status}) {
    final allBids = <BidModel>[];

    for (final key in _bidBox.keys) {
      final data = _bidBox.get(key);
      if (data != null) {
        try {
          final bid = BidModel.fromJson(Map<String, dynamic>.from(data));
          if (status == null || bid.status == status) {
            allBids.add(bid);
          }
        } catch (e) {
          print('Error parsing bid: $e');
        }
      }
    }

    // Sort by created date (newest first)
    allBids.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allBids;
  }

  /// Get local bid by ID
  BidModel? _getLocalBidById(String id) {
    final data = _bidBox.get(id);
    if (data != null) {
      try {
        return BidModel.fromJson(Map<String, dynamic>.from(data));
      } catch (e) {
        print('Error parsing bid: $e');
      }
    }
    return null;
  }

  /// Save bid locally
  Future<void> _saveBidLocally(BidModel bid) async {
    await _bidBox.put(bid.id, bid.toJson());
  }

  /// Cache bids from server
  Future<void> _cacheBids(List<BidModel> bids) async {
    for (final bid in bids) {
      // Don't overwrite local unsynced bids
      final existingBid = _getLocalBidById(bid.id);
      if (existingBid == null || existingBid.isSynced) {
        await _saveBidLocally(bid.copyWith(isSynced: true));
      }
    }
  }

  // ==================== SYNC QUEUE OPERATIONS ====================

  /// Add to sync queue
  Future<void> _addToSyncQueue(
    String id,
    String action,
    Map<String, dynamic> data,
  ) async {
    await _syncBox.put(id, {
      'id': id,
      'action': action,
      'data': data,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }

  /// Get unsynced bids
  List<BidModel> getUnsyncedBids() {
    return _getLocalBids().where((bid) => !bid.isSynced).toList();
  }

  /// Get sync queue items
  List<Map<String, dynamic>> getSyncQueue() {
    final items = <Map<String, dynamic>>[];
    for (final key in _syncBox.keys) {
      final data = _syncBox.get(key);
      if (data != null) {
        items.add(Map<String, dynamic>.from(data));
      }
    }
    return items;
  }

  /// Remove from sync queue
  Future<void> removeFromSyncQueue(String id) async {
    await _syncBox.delete(id);
  }

  /// Mark bid as synced
  Future<void> markBidAsSynced(String id, {String? serverBidId}) async {
    final bid = _getLocalBidById(id);
    if (bid != null) {
      final syncedBid = bid.copyWith(
        isSynced: true,
        serverBidId: serverBidId ?? bid.serverBidId,
      );
      await _saveBidLocally(syncedBid);
    }
  }

  // ==================== DASHBOARD STATS ====================

  /// Get dashboard stats
  Future<DashboardStats> getDashboardStats() async {
    final bids = _getLocalBids();

    return DashboardStats(
      totalBids: bids.length,
      pendingBids: bids.where((b) => b.isPending).length,
      approvedBids: bids.where((b) => b.isApproved).length,
      rejectedBids: bids.where((b) => b.isRejected).length,
      draftBids: bids.where((b) => b.isDraft).length,
      totalAmount: bids.fold(0.0, (sum, b) => sum + b.grandTotal),
      approvedAmount: bids
          .where((b) => b.isApproved)
          .fold(0.0, (sum, b) => sum + b.grandTotal),
      unsyncedCount: bids.where((b) => !b.isSynced).length,
    );
  }

  /// Get recent bids
  List<BidModel> getRecentBids({int limit = 5}) {
    final bids = _getLocalBids();
    return bids.take(limit).toList();
  }

  // ==================== SEARCH & FILTER ====================

  /// Search bids
  List<BidModel> searchBids(String query) {
    if (query.isEmpty) return _getLocalBids();

    final queryLower = query.toLowerCase();
    return _getLocalBids().where((bid) {
      return bid.clientName.toLowerCase().contains(queryLower) ||
          bid.projectName.toLowerCase().contains(queryLower) ||
          bid.id.toLowerCase().contains(queryLower);
    }).toList();
  }

  /// Filter bids by date range
  List<BidModel> filterBidsByDate(DateTime startDate, DateTime endDate) {
    return _getLocalBids().where((bid) {
      return bid.createdAt.isAfter(startDate) &&
          bid.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // ==================== CLEAR DATA ====================

  /// Clear all local bids
  Future<void> clearAllLocalBids() async {
    await _bidBox.clear();
    await _syncBox.clear();
  }
}
