import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../view_model/platform_plans_cubit.dart';
import '../view_model/platform_plans_state.dart';
import 'platform_plan_card.dart';

class PlatformPlansSection extends StatelessWidget {
  const PlatformPlansSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformPlansCubit, PlatformPlansState>(
      builder: (context, state) {
        if (state is PlatformPlansLoading) {
          // 🔥 هيكل شيمير أفقي قريب من شكل PlatformPlanCard (270×135 صورة + نصين)
          return SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: 270,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LoadingShimmer(width: 250, height: 135, borderRadius: 16),
                      const SizedBox(height: 12),
                      const LoadingShimmer(width: 180, height: 14, borderRadius: 6),
                      const SizedBox(height: 8),
                      const LoadingShimmer(width: 120, height: 12, borderRadius: 6),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (state is PlatformPlansSuccess) {
          final plans = state.plans;
          if (plans.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header السكشن
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sportifo Plans',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.allPlatformPlans);
                      },
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: AppColors.primaryBtn,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // قائمة الكروت الأفقية
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return PlatformPlanCard(
                      plan: plan,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.planDays,
                          arguments: plan,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}