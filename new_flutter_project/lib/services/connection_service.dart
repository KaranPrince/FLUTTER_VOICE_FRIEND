import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectionService {
  InternetStatus? connectionStatus;
  bool hasInternet = true;
  StreamSubscription<InternetStatus>? _subscription;
  final InternetConnection _internetConnection;

  final StreamController<InternetStatus> _connectionStatusController =
      StreamController.broadcast();

  Stream<InternetStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  // Updated constructor with optional parameter
  ConnectionService({InternetConnection? internetConnection})
      : _internetConnection = internetConnection ?? InternetConnection() {
    initialize();
  }

  void initialize() async {
    connectionStatus = await _internetConnection.internetStatus;
    hasInternet = connectionStatus == InternetStatus.connected;
    _connectionStatusController.add(connectionStatus!);
    startMonitoring();
  }

  Future<void> forceUpdate() async {
    connectionStatus = await _internetConnection.internetStatus;
    hasInternet = connectionStatus == InternetStatus.connected;
  }

  void startMonitoring() {
    _subscription = _internetConnection.onStatusChange.listen((status) {
      connectionStatus = status;
      hasInternet = connectionStatus == InternetStatus.connected;
      _connectionStatusController.add(status);
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
    _connectionStatusController.close();
  }
}
