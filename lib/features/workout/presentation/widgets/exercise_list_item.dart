import 'package:flutter/material.dart';
// import '../../../../core/theme/app_colors.dart'; // للون البرتقالي

class ExerciseListItem extends StatelessWidget {
  final String exerciseName;
  final String muscleName;
  final String imageUrl; // هنا نمرر الـ GIF أو الصورة
  final VoidCallback onTap;

  const ExerciseListItem({
    super.key,
    required this.exerciseName,
    required this.muscleName,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBtn = Color(0xFFFF7A00);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // رمادي داكن فخم جداً
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // 1. صورة التمرين (GIF)
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                // لمعالجة خطأ التحميل لو الصورة غير موجودة
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90, height: 90, color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 15),

            // 2. تفاصيل التمرين
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    muscleName,
                    style: const TextStyle(
                      color: primaryBtn, // اسم العضلة باللون البرتقالي
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 3. سهم الانتقال
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}