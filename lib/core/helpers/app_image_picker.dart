import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';

class AppImagePicker {
  static final ImagePicker _picker = ImagePicker();

  // دالة لاختيار الصورة بناءً على المصدر
  static Future<File?> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // ضغط الصورة لتقليل حجمها قبل الرفع للسيرفر
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
    return null;
  }

  static Future<File?> pickImageFromGallery() async {
    return await _pickImage(ImageSource.gallery);
  }

  // دالة إظهار الـ BottomSheet المشتركة (في التسجيل وإكمال البروفايل)
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    File? selectedImage;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Choose Image Source", // يمكنك استبدالها بالترجمة l10n لاحقاً
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.primaryBtn),
                  title: const Text("Gallery"),
                  onTap: () async {
                    selectedImage = await _pickImage(ImageSource.gallery);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppColors.primaryBtn),
                  title: const Text("Camera"),
                  onTap: () async {
                    selectedImage = await _pickImage(ImageSource.camera);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    return selectedImage;
  }
}