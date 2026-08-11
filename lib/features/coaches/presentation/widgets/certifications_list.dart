import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportifo_app/features/coaches/data/models/coach_image_model.dart';
import '../../../../core/widgets/loading_shimmer.dart';

class CertificationsList extends StatelessWidget {
  final List<CoachImageModel> pics;

  const CertificationsList({super.key, required this.pics});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pics.length,
        itemBuilder: (context, index) {
          final pic = pics[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: pic.url,
                width: 160,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => const LoadingShimmer(
                  width: 160,
                  height: 120,
                  borderRadius: 12,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 160,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
