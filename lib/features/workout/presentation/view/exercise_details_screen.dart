import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/exercise_model.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    // نجلب الـ GIF، وإذا لم يوجد نجلب صورة عادية
    final imageUrl = exercise.gifUrl ?? (exercise.pictureUrls.isNotEmpty ? exercise.pictureUrls.first : '');

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark Theme
      body: Column(
        children: [
          // 🔥 1. النصف العلوي: الصورة أو الـ GIF
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>  Container(color: Colors.grey),
                ),
              ),
              // التدرج الأسود لدمج الصورة مع الخلفية
              Positioned(
                bottom: 0, left: 0, right: 0,
                height: 100,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xFF121212)],
                    ),
                  ),
                ),
              ),
              // زر العودة
              SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),

          // 🔥 2. النصف السفلي: التفاصيل
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // كبسولات المعلومات (Tags)
                  Row(
                    children: [
                      // تم إزالة duration لأنه غير موجود في ExerciseModel
                      _buildTag(Icons.fitness_center, exercise.category?.organ?.name ?? "Full Body"),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Instructions",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    exercise.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 100), // مساحة للزر السفلي
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔥 3. الزر الثابت في الأسفل
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBtn,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              // بدء التمرين (سيتم برمجته لاحقاً)
            },
            child: const Text(
              "START WORKOUT",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
        ),
      ),
    );
  }

  // Widget بسيط للكبسولات
  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBtn.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBtn.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBtn, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: AppColors.primaryBtn, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
