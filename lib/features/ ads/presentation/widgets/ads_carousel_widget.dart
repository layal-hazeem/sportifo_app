import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_cached_image.dart';
import '../../data/models/ad_model.dart';
import '../view_model/ads_cubit.dart';
import '../view_model/ads_state.dart';

class AdsCarouselWidget extends StatefulWidget {
  const AdsCarouselWidget({super.key});

  @override
  State<AdsCarouselWidget> createState() => _AdsCarouselWidgetState();
}

class _AdsCarouselWidgetState extends State<AdsCarouselWidget> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    context.read<AdsCubit>().fetchAds();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsCubit, AdsState>(
      builder: (context, state) {
        if (state is AdsLoading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryBtn)),
          );
        } else if (state is AdsSuccess && state.ads.isNotEmpty) {
          return Column(
            children: [
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: state.ads.length,
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                  // enableInfiniteScroll: false, // Prevents leading and trailing items from overlapping
                  autoPlayInterval: const Duration(seconds: 3),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });

                    // Smooth custom loop to return to first item when reaching the end
                    if (index == state.ads.length - 1) {
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted && _currentIndex == state.ads.length - 1) {
                          _carouselController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                          );
                        }
                      });
                    }
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return _buildAdCard(state.ads[index]);
                },
              ),
              const SizedBox(height: 12),
              // Dots Indicator perfectly synchronized with current image index
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: state.ads.asMap().entries.map((entry) {
                  bool isActive = _currentIndex == entry.key;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 18.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isActive ? AppColors.primaryBtn : Colors.grey.shade300,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAdCard(AdModel ad) {
    final imageUrl = ad.images.isNotEmpty ? ad.images.first : '';

    return GestureDetector(
      onTap: () {
        debugPrint("Clicked on Ad ID: ${ad.id}");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Clean image layer filling the entire card area
              // داخل الـ Stack في كرت الإعلان
              CustomCachedImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),

              // Product Price Badge displayed on top-right corner if applicable
              if (ad.type == 'product' && ad.price != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBtn,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "\$${ad.price}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}