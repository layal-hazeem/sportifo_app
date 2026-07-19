
import '../../data/models/get_profile_response.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

// ================= جلب بيانات البروفايل =================
class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
   final ProfileResponseModel profileModel;

  ProfileSuccess(this.profileModel);
}

// تم تغيير الاسم من ProfileError إلى ProfileFailure ليتوافق مع كود الـ HomePage الخاص بكِ
class ProfileFailure extends ProfileState { 
  final String message;
  ProfileFailure(this.message);
}

// ================= تحديث صورة البروفايل =================
class ProfileImageUpdating extends ProfileState {}

class ProfileImageUpdated extends ProfileState {
  final ProfileResponseModel profile;
  ProfileImageUpdated(this.profile);
}

class ProfileImageUpdateFailure extends ProfileState {
  final String message;
  ProfileImageUpdateFailure(this.message);
}

// ================= تحديث البيانات النصية للبروفايل (تعديل الحساب) =================
class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final ProfileResponseModel profile;
  ProfileUpdateSuccess(this.profile);
}

class ProfileUpdateFailure extends ProfileState {
  final String message;
  ProfileUpdateFailure(this.message);
}

// ================= حذف الحساب =================

class DeleteAccountLoading extends ProfileState {}

class DeleteAccountSuccess extends ProfileState {
  final String message;

  DeleteAccountSuccess(this.message);
}

class DeleteAccountFailure extends ProfileState {
  final String message;

  DeleteAccountFailure(this.message);
}