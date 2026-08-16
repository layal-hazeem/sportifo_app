import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Skeleton placeholder shown while [CoachHomeCubit] is loading, mirroring
/// the loaded layout (greeting, ads, stats, trainees, quick actions) so the
/// screen doesn't "jump" once real content arrives. Self-contained animated
/// gradient — no extra dependency (e.g. `shimmer`) required.
class CoachHomeSkeleton extends StatefulWidget {
  const CoachHomeSkeleton({super.key});

  @override
  State<CoachHomeSkeleton> createState() => _CoachHomeSkeletonState();
}

class _CoachHomeSkeletonState extends State<CoachHomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          children: [
            _shimmerBox(width: 56, height: 56, radius: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 80, height: 12),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 140, height: 16),
                ],
              ),
            ),
            _shimmerBox(width: 44, height: 44, radius: 22),
          ],
        ),
        const SizedBox(height: 20),
        _shimmerBox(width: double.infinity, height: 120, radius: 16),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _shimmerBox(width: double.infinity, height: 80, radius: 16)),
            const SizedBox(width: 12),
            Expanded(child: _shimmerBox(width: double.infinity, height: 80, radius: 16)),
            const SizedBox(width: 12),
            Expanded(child: _shimmerBox(width: double.infinity, height: 80, radius: 16)),
          ],
        ),
        const SizedBox(height: 24),
        _shimmerBox(width: 120, height: 16),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: Row(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 14),
                child: _shimmerBox(width: 70, height: 100, radius: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _shimmerBox(width: double.infinity, height: 70, radius: 16),
      ],
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + value * 2, 0),
              end: Alignment(0 + value * 2, 0),
              colors: [
                AppColors.hintText.withOpacity(0.08),
                AppColors.hintText.withOpacity(0.18),
                AppColors.hintText.withOpacity(0.08),
              ],
            ),
          ),
        );
      },
    );
  }
}