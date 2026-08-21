import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/connectivity_service.dart';
import 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _service;
  StreamSubscription? _subscription;

  ConnectivityCubit(this._service) : super(ConnectivityInitial()) {
    _service.initialize();
    _subscription = _service.connectionStream.listen((isConnected) {
      if (isConnected) {
        emit(ConnectivityConnected());
      } else {
        emit(ConnectivityDisconnected());
      }
    });
  }

  Future<void> checkConnection() async {
    final isConnected = await _service.checkConnection();
    if (isConnected) {
      emit(ConnectivityConnected());
    } else {
      emit(ConnectivityDisconnected());
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}