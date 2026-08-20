import 'package:flutter/material.dart';

@immutable
sealed class RegisterState {
  const RegisterState();
}

final class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

final class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

final class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

final class RegisterFailure extends RegisterState {
  final String errorMessage;

  const RegisterFailure({required this.errorMessage});
}