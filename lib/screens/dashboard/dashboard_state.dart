import '../../models/bid_model.dart';
import '../../services/sync_service.dart';
import '../../services/connectivity_service.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState {
  final DashboardStatus status;
  final DashboardStats stats;
  final List<BidModel> recentBids;
  final SyncStatus syncStatus;
  final ConnectionStatus connectionStatus;
  final String? errorMessage;
  final bool isRefreshing;
  final DateTime? lastUpdated;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.stats = const DashboardStats(),
    this.recentBids = const [],
    this.syncStatus =
        const SyncStatus(), // ✅ Now works because SyncStatus has const constructor
    this.connectionStatus = ConnectionStatus.online,
    this.errorMessage,
    this.isRefreshing = false,
    this.lastUpdated,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardStats? stats,
    List<BidModel>? recentBids,
    SyncStatus? syncStatus,
    ConnectionStatus? connectionStatus,
    String? errorMessage,
    bool? isRefreshing,
    DateTime? lastUpdated,
  }) {
    return DashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      recentBids: recentBids ?? this.recentBids,
      syncStatus: syncStatus ?? this.syncStatus,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      errorMessage: errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Getters
  bool get isLoading => status == DashboardStatus.loading;
  bool get isLoaded => status == DashboardStatus.loaded;
  bool get hasError => status == DashboardStatus.error;
  bool get isOffline => connectionStatus == ConnectionStatus.offline;
  bool get hasPendingSync => stats.unsyncedCount > 0;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

/// Dashboard Stats Model - Single source of truth
class DashboardStats {
  final int totalBids;
  final int pendingBids;
  final int approvedBids;
  final int rejectedBids;
  final int draftBids;
  final double totalAmount;
  final double approvedAmount;
  final int unsyncedCount;
  final int thisMonthBids;
  final double thisMonthAmount;

  const DashboardStats({
    this.totalBids = 0,
    this.pendingBids = 0,
    this.approvedBids = 0,
    this.rejectedBids = 0,
    this.draftBids = 0,
    this.totalAmount = 0.0,
    this.approvedAmount = 0.0,
    this.unsyncedCount = 0,
    this.thisMonthBids = 0,
    this.thisMonthAmount = 0.0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalBids: json['total_bids'] ?? 0,
      pendingBids: json['pending_bids'] ?? 0,
      approvedBids: json['approved_bids'] ?? 0,
      rejectedBids: json['rejected_bids'] ?? 0,
      draftBids: json['draft_bids'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      approvedAmount: (json['approved_amount'] ?? 0).toDouble(),
      unsyncedCount: json['unsynced_count'] ?? 0,
      thisMonthBids: json['this_month_bids'] ?? 0,
      thisMonthAmount: (json['this_month_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_bids': totalBids,
      'pending_bids': pendingBids,
      'approved_bids': approvedBids,
      'rejected_bids': rejectedBids,
      'draft_bids': draftBids,
      'total_amount': totalAmount,
      'approved_amount': approvedAmount,
      'unsynced_count': unsyncedCount,
      'this_month_bids': thisMonthBids,
      'this_month_amount': thisMonthAmount,
    };
  }

  // Success rate percentage
  double get successRate {
    if (totalBids == 0) return 0;
    return (approvedBids / totalBids) * 100;
  }

  // Copy with
  DashboardStats copyWith({
    int? totalBids,
    int? pendingBids,
    int? approvedBids,
    int? rejectedBids,
    int? draftBids,
    double? totalAmount,
    double? approvedAmount,
    int? unsyncedCount,
    int? thisMonthBids,
    double? thisMonthAmount,
  }) {
    return DashboardStats(
      totalBids: totalBids ?? this.totalBids,
      pendingBids: pendingBids ?? this.pendingBids,
      approvedBids: approvedBids ?? this.approvedBids,
      rejectedBids: rejectedBids ?? this.rejectedBids,
      draftBids: draftBids ?? this.draftBids,
      totalAmount: totalAmount ?? this.totalAmount,
      approvedAmount: approvedAmount ?? this.approvedAmount,
      unsyncedCount: unsyncedCount ?? this.unsyncedCount,
      thisMonthBids: thisMonthBids ?? this.thisMonthBids,
      thisMonthAmount: thisMonthAmount ?? this.thisMonthAmount,
    );
  }
}
