import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/custom_cached_image.dart';
import '../../../../../l10n/app_localizations.dart'; // 🔥 استيراد الترجمة
import '../../data/models/ad_model.dart';

class AdDetailsBottomSheet extends StatefulWidget {
  final AdModel ad;

  const AdDetailsBottomSheet({super.key, required this.ad});

  static void show(BuildContext context, AdModel ad) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AdDetailsBottomSheet(ad: ad),
        );
      },
    );
  }

  @override
  State<AdDetailsBottomSheet> createState() => _AdDetailsBottomSheetState();
}

class _AdDetailsBottomSheetState extends State<AdDetailsBottomSheet> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.98,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 17, sigmaY: 17),
                    child: Container(color: Colors.black.withOpacity(0.13)),
                  ),
                ),
              ),

              ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.backgroundColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  CarouselSlider.builder(
                    itemCount: widget.ad.images.length,
                    options: CarouselOptions(
                      height: screenHeight * 0.26,
                      viewportFraction: 0.85,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: widget.ad.images.length > 1,
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
                            imageUrl: widget.ad.images[index],
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
                    children: widget.ad.images.asMap().entries.map((entry) {
                      bool isActive = _currentImageIndex == entry.key;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 14.0 : 7.0,
                        height: 7.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 17),

                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: screenHeight * 0.5),
                    decoration: BoxDecoration(
                      color: context.backgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(35),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 35, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.ad.type == 'product' &&
                            widget.ad.price != null) ...[
                          Text(
                            "\$${widget.ad.price}",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBtn,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        Text(
                          widget.ad.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: context.textColor,
                          ),
                        ),
                        const SizedBox(height: 6),

                        if (widget.ad.companyName.isNotEmpty) ...[
                          Text(
                            widget.ad.companyName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),

                        // 🔥 تم إصلاح هذا الجزء بنجاح
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
                          widget.ad.details ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 15, 24, 30),
                  color: context.backgroundColor,
                  child: ElevatedButton(
                    onPressed: () => _launchURL(widget.ad.url),
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
                      widget.ad.type == 'product'
                          ? l10n.shopNow
                          : l10n.learnMore, // 🔥 ترجمة نص الزر
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String? urlString) async {
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
}