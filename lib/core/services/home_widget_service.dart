import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String androidWidgetName = 'CalorieWidgetProvider';

  static Future<void> updateCaloriesWidget({
    required int currentCalories,
    required int targetCalories,
    int currentProtein = 0,
    int targetProtein = 120,
    int currentCarbs = 0,
    int targetCarbs = 150,
    int currentFat = 0,
    int targetFat = 60,
  }) async {
    try {
      // 1. حفظ السعرات
      await HomeWidget.saveWidgetData<int>('current_calories', currentCalories);
      await HomeWidget.saveWidgetData<int>('target_calories', targetCalories);

      // 2. حفظ البروتين
      await HomeWidget.saveWidgetData<int>('current_protein', currentProtein);
      await HomeWidget.saveWidgetData<int>('target_protein', targetProtein);

      // 3. حفظ الكاربوهيدرات
      await HomeWidget.saveWidgetData<int>('current_carbs', currentCarbs);
      await HomeWidget.saveWidgetData<int>('target_carbs', targetCarbs);

      // 4. حفظ الدهون
      await HomeWidget.saveWidgetData<int>('current_fat', currentFat);
      await HomeWidget.saveWidgetData<int>('target_fat', targetFat);

      // 5. إرسال إشعار تحديث للويدجت الخارجي
      await HomeWidget.updateWidget(name: androidWidgetName);
    } catch (e) {
      print("Error updating home widget: $e");
    }
  }
}