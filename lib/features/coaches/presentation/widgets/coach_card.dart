import 'package:flutter/material.dart';
import '../../data/models/coach_model.dart';

class CoachCard extends StatelessWidget {
  final CoachModel coach;
  final VoidCallback onTap;
  final bool isGridMode;

  const CoachCard({
    super.key,
    required this.coach,
    required this.onTap,
    this.isGridMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isGridMode ? null : 115,
        margin: isGridMode ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 6, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(100),
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
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
              width: isGridMode ? 110 : 90,
              height: isGridMode ? 120 : 100,
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
                      child: const Icon(Icons.person, color: Colors.grey, size: 30),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 9),

            Text(
              coach.fullName,
              style: TextStyle(
                fontSize: isGridMode ? 15 : 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            Text(
              coach.description,
              style: TextStyle(
                fontSize: isGridMode ? 12 : 10,
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