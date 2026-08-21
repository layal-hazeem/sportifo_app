import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/coaches/data/models/coach_model.dart';
import 'package:sportifo_app/features/profile/data/models/get_profile_response.dart';
import 'package:sportifo_app/features/profile/data/repository/profile_repository.dart';
import 'package:sportifo_app/features/subscriptions/data/models/users_subscribed_model.dart';
import 'package:sportifo_app/features/subscriptions/data/repository/subscription_repository.dart';

abstract class CoachHomeRepository {
  Future<CoachModel> getCoachInfo();

  Future<int> getUnreadNotificationsCount();

  Future<List<UsersSubscribedModel>> getMyClients();
}

class CoachHomeRepositoryImpl implements CoachHomeRepository {
  final ProfileRepository _profileRepository;
  final SubscriptionRepository _subscriptionRepository;

  CoachHomeRepositoryImpl(
    this._profileRepository,
    this._subscriptionRepository,
  );

  @override
  Future<CoachModel> getCoachInfo() async {
    final result = await _profileRepository.getProfile();

    if (result is Success<ProfileResponseModel>) {
      final profile = result.data;
      final coach = profile.coach;

      final fullName = coach?.fullName?.trim().isNotEmpty == true
          ? coach!.fullName!.trim()
          : '${profile.firstName} ${profile.lastName}'.trim();

      return CoachModel(
        id: coach?.id ?? profile.id ?? 0,
        fullName: fullName,
        description: coach?.description ?? '',
        yearsOfExp: coach?.yearsOfExp ?? 0,
        dateOfBirth: profile.dateOfBirth.toIso8601String(),
        gender: profile.gender == true ? 1 : 0,
        profilePic: profile.profilePic ?? '',
      );
    }

    if (result is Failure) {
      throw Exception(result);
    }

    throw Exception('Failed to load coach profile');
  }

  @override
  Future<int> getUnreadNotificationsCount() async {
    // لا يوجد حاليًا Notifications API ضمن الـ architecture المرسلة.
    // لذلك نرجع 0 بدل اختراع endpoint غير موجود.
    return 0;
  }

  @override
  Future<List<UsersSubscribedModel>> getMyClients() async {
    return await _subscriptionRepository.fetchSubscriptions();
  }
}
