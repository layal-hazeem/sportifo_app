import 'package:flutter/material.dart';
import '../../../../core/widgets/loading_shimmer.dart'; // 👈 مسار الـ LoadingShimmer تبعك

class NotificationsShimmerLoading extends StatelessWidget {
  const NotificationsShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LoadingShimmer(width: 48, height: 48, borderRadius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingShimmer(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 14,
                      borderRadius: 6,
                    ),
                    const SizedBox(height: 10),
                    LoadingShimmer(
                      width: double.infinity,
                      height: 12,
                      borderRadius: 6,
                    ),
                    const SizedBox(height: 6),
                    LoadingShimmer(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 12,
                      borderRadius: 6,
                    ),
                    const SizedBox(height: 10),
                    LoadingShimmer(
                      width: 60,
                      height: 10,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}