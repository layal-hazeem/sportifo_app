import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String? image;
  final String firstName;
  final String? lastName;
  final String? email;
  final bool? gender;

  const ProfileHeader({
    super.key,
    required this.image,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    final name = "$firstName ${lastName ?? ""}";
    final firstLetter = firstName.isNotEmpty ? firstName[0] : "?";

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 6,
        color: Colors.white,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: image != null ? NetworkImage(image!) : null,
            child: image == null
                ? Text(firstLetter, style: const TextStyle(fontSize: 20))
                : null,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email ?? "No email",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Text(gender == true ? "Male" : "Female"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}