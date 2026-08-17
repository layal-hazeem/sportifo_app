package com.example.sportifo_app // 👈 تأكد إنه نفس الباكج نيم تبعك

import android.app.PendingIntent // 🔥 إمبورت جديد
import android.content.Intent // 🔥 إمبورت جديد
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class CalorieWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.calorie_widget).apply {

                // 🚀 كود فتح التطبيق عند الضغط على الويدجت
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent) // ربط الضغطة بالـ ID اللي ضفناه

                // ---------------------------------------------------
                // 1. السعرات الحرارية
                val currentCalories = widgetData.getInt("current_calories", 0)
                val targetCalories = widgetData.getInt("target_calories", 2000)
                val caloriePercent = if (targetCalories > 0) (currentCalories * 100) / targetCalories else 0

                setTextViewText(R.id.tv_calories_consumed, "$currentCalories")
                setTextViewText(R.id.tv_calories_target, "/ $targetCalories")
                setTextViewText(R.id.tv_calories_percent, "$caloriePercent%")
                setProgressBar(R.id.progress_calories, 100, caloriePercent, false)

                // 2. البروتين
                val currentProtein = widgetData.getInt("current_protein", 0)
                val targetProtein = widgetData.getInt("target_protein", 120)
                val proteinPercent = if (targetProtein > 0) (currentProtein * 100) / targetProtein else 0

                setTextViewText(R.id.tv_protein_grams, "${currentProtein}g")
                setTextViewText(R.id.tv_protein_percent, "$proteinPercent%")
                setProgressBar(R.id.progress_protein, 100, proteinPercent, false)

                // 3. الكاربوهيدرات
                val currentCarbs = widgetData.getInt("current_carbs", 0)
                val targetCarbs = widgetData.getInt("target_carbs", 150)
                val carbsPercent = if (targetCarbs > 0) (currentCarbs * 100) / targetCarbs else 0

                setTextViewText(R.id.tv_carbs_grams, "${currentCarbs}g")
                setTextViewText(R.id.tv_carbs_percent, "$carbsPercent%")
                setProgressBar(R.id.progress_carbs, 100, carbsPercent, false)

                // 4. الدهون
                val currentFat = widgetData.getInt("current_fat", 0)
                val targetFat = widgetData.getInt("target_fat", 60)
                val fatPercent = if (targetFat > 0) (currentFat * 100) / targetFat else 0

                setTextViewText(R.id.tv_fat_grams, "${currentFat}g")
                setTextViewText(R.id.tv_fat_percent, "$fatPercent%")
                setProgressBar(R.id.progress_fat, 100, fatPercent, false)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}