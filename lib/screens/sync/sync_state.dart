import '../../services/sync_service.dart';

class SyncScreenState {
  final SyncStatus status;
  final bool isConnected;

  const SyncScreenState({
    this.status = const SyncStatus(),
    this.isConnected = true,
  });

  SyncScreenState copyWith({SyncStatus? status, bool? isConnected}) {
    return SyncScreenState(
      status: status ?? this.status,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
