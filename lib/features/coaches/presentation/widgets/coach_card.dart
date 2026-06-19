import 'package:flutter/material.dart';
import '../../data/models/coach_model.dart';

class CoachCard extends StatelessWidget {
  final CoachModel coach;
  final VoidCallback onTap;

  const CoachCard({
    super.key,
    required this.coach,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,                      // 🔽 من 115 إلى 95
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12), // 🔽 من 20 إلى 12
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10), // 🔽 من (10,15) إلى (6,10)
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(80),   // 🔽 قليل من التقليل للحفاظ على النسبة
            topRight: Radius.circular(80),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 70,                 // 🔽 من 90 إلى 70
              height: 80,                // 🔽 من 100 إلى 80
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  coach.profilePic,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey, size: 24), // 🔽 أيقونة أصغر
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),    // 🔽 من 9 إلى 6

            Text(
              coach.fullName,
              style: const TextStyle(
                fontSize: 11,             // 🔽 من 13 إلى 11
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),

            Text(
              coach.description,
              style: TextStyle(
                fontSize: 9,              // 🔽 من 10 إلى 9
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}