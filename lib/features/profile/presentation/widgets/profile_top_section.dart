import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_colors.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';

class ProfileTopSection extends StatelessWidget {
  final String? imageUrl;
  final File? localImage;
  final String? firstName;
  final VoidCallback onEditImage;
  final bool? gender;
  final VoidCallback onOpenImage;

  const ProfileTopSection({
    super.key,
    required this.imageUrl,
    required this.localImage,
    required this.firstName,
    required this.onEditImage,
    required this.gender,
    required this.onOpenImage,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (localImage != null) {
      imageProvider = FileImage(localImage!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl!);
    } else if (gender != null) {
      imageProvider = AssetImage(
        gender! ? "assets/images/male.jpg" : "assets/images/female.jpg",
      );
    } else {
      imageProvider = const AssetImage("assets/images/default_avatar.jpg");
    }

    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primaryBtn,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Hero(
                    tag: "profile-image",
                    child: GestureDetector(
                      onTap: onOpenImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: imageProvider,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onEditImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 24,
                          color: AppColors.primaryBtn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
