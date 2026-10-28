import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/custom_cached_image.dart';
import '../../../../../core/widgets/custom_glass_bottom_sheet.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../data/models/ad_model.dart';

class AdDetailsBottomSheet extends StatelessWidget {
  final AdModel ad;

  const AdDetailsBottomSheet({super.key, required this.ad});

  static void show(BuildContext context, AdModel ad) {
    final l10n = AppLocalizations.of(context)!;

    CustomGlassBottomSheet.show(
      context: context,

      // 1. القسم العلوي الشفاف (السلايدر والنقاط)
      topHeader: _AdCarouselHeader(images: ad.images),

      // 2. محتوى البطاقة (تم استدعاء الويدجت هنا)
      child: AdDetailsBottomSheet(ad: ad),

      // 3. الزر السفلي الثابت
      stickyBottomButton: ElevatedButton(
        onPressed: () => _launchURL(ad.url),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBtn,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          ad.type == 'product' ? l10n.shopNow : l10n.learnMore,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;

    final cleanUrl = urlString.trim();
    final Uri url = Uri.parse(cleanUrl);

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("First launch method failed: $e");
      try {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } catch (err) {
        debugPrint("All URL launch methods failed: $err");
      }
    }
  }

  // 🔴 هذه هي الدالة التي كانت مفقودة وسببت الخطأ
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (ad.type == 'product' && ad.price != null) ...[
          Text(
            "\$${ad.price}",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBtn,
            ),
          ),
          const SizedBox(height: 12),
        ],

        Text(
          ad.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 6),

        if (ad.companyName.isNotEmpty) ...[
          Text(
            ad.companyName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],

        const SizedBox(height: 30),

        Text(
          l10n.details,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 10),

        Text(
          ad.details ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// 🖼️ ويدجت السلايدر المنفصل
class _AdCarouselHeader extends StatefulWidget {
  final List<String> images;
  const _AdCarouselHeader({required this.images});

  @override
  State<_AdCarouselHeader> createState() => _AdCarouselHeaderState();
}

class _AdCarouselHeaderState extends State<_AdCarouselHeader> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: widget.images.length,
          options: CarouselOptions(
            height: screenHeight * 0.26,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            enableInfiniteScroll: widget.images.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Center(
                child: CustomCachedImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.images.asMap().entries.map((entry) {
            bool isActive = _currentImageIndex == entry.key;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 14.0 : 7.0,
              height: 7.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}