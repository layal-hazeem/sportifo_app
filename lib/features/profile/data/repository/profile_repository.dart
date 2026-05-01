import 'package:sportifo_app/core/network/api_error_handler.dart';
import 'package:sportifo_app/core/network/api_result.dart';
import 'package:sportifo_app/features/profile/data/models/profile_response.dart';
import 'package:sportifo_app/features/profile/data/web_services/profile_web_service.dart';

class ProfileRepository {
  final ProfileWebService _profileWebService;

  ProfileRepository(this._profileWebService);

  Future<ApiResult<ProfileResponsModel>> getProfile() async {
    try {
      final response = await _profileWebService.getProfile();
      return Success(ProfileResponsModel.fromJson(response.data['data']));
    } catch (e) {
      return Failure(ApiErrorHandler.handle(e));
    }
  }
}
