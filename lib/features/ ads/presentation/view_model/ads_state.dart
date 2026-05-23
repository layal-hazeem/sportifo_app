import '../../data/models/ad_model.dart';

sealed class AdsState {}

final class AdsInitial extends AdsState {}

final class AdsLoading extends AdsState {}

final class AdsSuccess extends AdsState {
  final List<AdModel> ads;
  AdsSuccess(this.ads);
}

final class AdsFailure extends AdsState {
  final String errorMessage;
  AdsFailure(this.errorMessage);
}