import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;
  
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen((dynamic result) {
      _handleResult(result);
    });
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final dynamic result = await _connectivity.checkConnectivity();
    _handleResult(result);
  }

  void _handleResult(dynamic result) {
    List<ConnectivityResult> results;
    
    if (result is List<ConnectivityResult>) {
      results = result;
    } else if (result is ConnectivityResult) {
      results = [result];
    } else {
      results = [];
    }

    final isConnected = results.any((r) => 
      r == ConnectivityResult.wifi || 
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.ethernet
    );
    
    _isConnected = isConnected;
    _connectionController.add(isConnected);
  }

  Future<bool> checkConnection() async {
    final dynamic result = await _connectivity.checkConnectivity();
    _handleResult(result);
    return _isConnected;
  }

  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}