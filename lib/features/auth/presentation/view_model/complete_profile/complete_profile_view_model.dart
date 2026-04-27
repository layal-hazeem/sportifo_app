import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/features/auth/data/models/complete_prfile/complete_profile_request_model.dart';
import 'package:sportifo_app/features/home/presentation/view/home_page.dart';
import 'package:sportifo_app/l10n/app_localizations.dart';

class CompleteProfileViewModel extends ChangeNotifier {
  String? firstName;
  String? lastName;
  String? email;
  String? phone;

  double? weight;
  double? height;
  String? gender;
  DateTime? birthDate;
  String? userImagePath;

  double? shoulders;
  double? chestCircumference;
  double? waist;
  double? hipCircumference;
  double? thighCircumference;
  double? handCircumference;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isDataComplete {
    return weight != null &&
        height != null &&
        gender != null &&
        birthDate != null;
  }

  void updateWeight(String val) {
    weight = double.tryParse(val);
    notifyListeners();
  }

  void updateHeight(String val) {
    height = double.tryParse(val);
    notifyListeners();
  }

  void updateGender(String? val) {
    gender = val;
    notifyListeners();
  }

  void updateBirthDate(DateTime date) {
    birthDate = date;
    notifyListeners();
  }

  void updateProfileImage(String path) {
    userImagePath = path;
    notifyListeners();
  }

  Future<void> submitProfile(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (!isDataComplete) {
      _showErrorSnackBar(context, l10n.messageOfIncompleteInfo);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // هنا يتم استدعاء الـ API لإرسال البيانات للباك إند (Laravel)
      // مثال: await _authRepository.completeProfile(data);
      await Future.delayed(const Duration(seconds: 2)); // محاكاة لعملية الإرسال

      // الانتقال للـ HomePage ومنع العودة للخلف (Best Practice) [3]
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, "حدث خطأ أثناء الاتصال بالسيرفر");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  CompleteProfileRequestModel toRequestModel() {
    return CompleteProfileRequestModel(
      first_name: firstName,
      last_name: lastName,
      email: email,
      phone: phone,

      // نحول التاريخ لـ String (format بسيط)
      date_of_birth: birthDate != null
          ? "${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}"
          : null,

      // نفترض male = true ، female = false
      gender: gender == 'male' ? true : false,

      height: height,
      weight: weight,

      // الصورة
      update_pic: userImagePath != null,
      profile_pic: userImagePath,

      // القياسات
      shoulders_width: shoulders,
      chest_perimeter: chestCircumference,
      waist_perimeter: waist, // إذا عندك waist غير belly
      thigh_perimeter: thighCircumference,
      hip_perimeter: hipCircumference,
      arm_perimeter: handCircumference,
    );
  }
}
