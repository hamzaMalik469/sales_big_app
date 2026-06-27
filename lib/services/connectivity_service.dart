import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionStatus { online, offline }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Stream controller for connection status
  final _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  // Current status
  ConnectionStatus _currentStatus = ConnectionStatus.offline;

  // Subscription - FIXED: Now uses List<ConnectivityResult>
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService() {
    _init();
  }

  /// Initialize and start listening
  void _init() {
    // Check initial status
    _checkConnection();

    // Listen for changes - FIXED: Now handles List<ConnectivityResult>
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// Stream of connection status changes
  Stream<ConnectionStatus> get statusStream =>
      _connectionStatusController.stream;

  /// Current connection status
  ConnectionStatus get currentStatus => _currentStatus;

  /// Check if currently connected
  bool get isConnected => _currentStatus == ConnectionStatus.online;

  /// Check if currently offline
  bool get isOffline => _currentStatus == ConnectionStatus.offline;

  /// Check connection (returns Future)
  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
    return isConnected;
  }

  /// Private: Check connection and update status
  Future<void> _checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  /// Private: Update connection status based on result
  /// FIXED: Now accepts List<ConnectivityResult>
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    ConnectionStatus newStatus;

    // Check if any connection is available
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.vpn)) {
      newStatus = ConnectionStatus.online;
    } else if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      newStatus = ConnectionStatus.offline;
    } else {
      // For other types (bluetooth, other), consider as online
      newStatus = ConnectionStatus.online;
    }

    // Only emit if status changed
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _connectionStatusController.add(newStatus);

      // Log status change
      print(
        '🌐 Connectivity: ${newStatus == ConnectionStatus.online ? "Online" : "Offline"} - $results',
      );
    }
  }

  /// Get connection type name
  Future<String> getConnectionType() async {
    final results = await _connectivity.checkConnectivity();

    if (results.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (results.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else if (results.contains(ConnectivityResult.none)) {
      return 'No Connection';
    } else {
      return 'Unknown';
    }
  }

  /// Get all active connection types
  Future<List<String>> getActiveConnectionTypes() async {
    final results = await _connectivity.checkConnectivity();
    final types = <String>[];

    for (final result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
          types.add('WiFi');
          break;
        case ConnectivityResult.mobile:
          types.add('Mobile Data');
          break;
        case ConnectivityResult.ethernet:
          types.add('Ethernet');
          break;
        case ConnectivityResult.vpn:
          types.add('VPN');
          break;
        case ConnectivityResult.bluetooth:
          types.add('Bluetooth');
          break;
        case ConnectivityResult.other:
          types.add('Other');
          break;
        case ConnectivityResult.none:
          types.add('None');
          break;
      }
    }

    return types;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectionStatusController.close();
  }
}
