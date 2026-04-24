class AppValidators {
  // 1. التحقق من الحقول الفارغة (للاسم الأول والأخير مثلاً)
  static String? validateRequired(String? value, {required String message}) {
    if (value == null || value.trim().isEmpty) {
      return message; // رسالة الخطأ نمررها من الواجهة لكي تدعم الترجمة l10n
    }
    return null; // null تعني أن الإدخال صحيح
  }

  // 2. التحقق من الإيميل
  static String? validateEmail(String? value, {required String message}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    // كود (Regex) للتحقق من أن الصيغة هي صيغة إيميل حقيقية
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email'; // يفضل تمريرها بالترجمة أيضاً
    }
    return null;
  }

  // 3. التحقق من رقم الهاتف
  static String? validatePhone(String? value, {required String message}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    // التحقق من أن الطول مناسب (مثلاً لا يقل عن 9 أرقام)
    if (value.length < 9) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // 4. التحقق من كلمة المرور
  static String? validatePassword(String? value, {required String message}) {
    if (value == null || value.isEmpty) {
      return message;
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // 5. التحقق من تأكيد كلمة المرور (لكِ أنتِ في شاشة التسجيل)
  static String? validateConfirmPassword(String? value, String? password, {required String message}) {
    if (value == null || value.isEmpty) {
      return message;
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}