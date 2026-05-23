import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gif_view/gif_view.dart';
import '../theme/app_colors.dart';

class CachedStaticGif extends StatefulWidget {
  final String imageUrl;
  final bool autoPlay;
  const CachedStaticGif({super.key, required this.imageUrl,this.autoPlay = false,});

  @override
  State<CachedStaticGif> createState() => _CachedStaticGifState();
}

class _CachedStaticGifState extends State<CachedStaticGif> {
  Future<Uint8List>? _bytesFuture;
  bool _isCached = false; // متغير لنعرف الحالة

  @override
  void initState() {
    super.initState();
    _checkCacheAndLoad();
  }

  Future<void> _checkCacheAndLoad() async {
    // 1. شيكي إذا الملف موجود بالكاش بدون تحميل من النت
    final cacheManager = DefaultCacheManager();
    final fileInfo = await cacheManager.getFileFromCache(widget.imageUrl);

    if (fileInfo != null) {
      // الملف موجود! اقرئيه فوراً
      final bytes = await fileInfo.file.readAsBytes();
      if (mounted) {
        setState(() {
          _isCached = true;
          _bytesFuture = Future.value(bytes);
        });
      }
    } else {
      // الملف مو موجود، لازم نحمله
      if (mounted) {
        setState(() {
          _bytesFuture = _loadGifBytes();
        });
      }
    }
  }

  Future<Uint8List> _loadGifBytes() async {
    final file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
    return await file.readAsBytes();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytesFuture,
      builder: (context, snapshot) {
        // أثناء التحميل: نعرض خلفية رمادية ناعمة مع لودر صغير جداً وأنيق
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _isCached
              ? const SizedBox.shrink()
              : Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade100, // خلفية رمادية فاتحة تشبه الـ Shimmer
            child: const Center(
              child: SizedBox(
                width: 20, // 🔥 لودر صغير وناعم
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2, // 🔥 سماكة خفيفة وأنيقة
                  color: AppColors.primaryBtn,
                ),
              ),
            ),
          );
        }

        // في حال فشل الرابط
        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade100,
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 24),
            ),
          );
        }

        // عرض الـ GIF
        return GifView.memory(
          snapshot.data!,
          fit: BoxFit.contain,
          autoPlay: widget.autoPlay,
        );
      },
    );
  }
}