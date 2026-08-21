import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view_model/connectivity_cubit.dart';
import '../view_model/connectivity_state.dart';
import 'no_internet_overlay.dart';

class AppConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const AppConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return Stack(
          alignment: Alignment.topLeft, // <-- هون التعديل
          fit: StackFit.expand,
          children: [
            child,
            if (state is ConnectivityDisconnected)
              const NoInternetOverlay(),
          ],
        );
      },
    );
  }
}