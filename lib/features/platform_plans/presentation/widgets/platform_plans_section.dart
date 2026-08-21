import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../l10n/app_localizations.dart'; // 🔥 استدعاء الترجمة
import '../view_model/platform_plans_cubit.dart';
import '../view_model/platform_plans_state.dart';
import 'platform_plan_card.dart';

class PlatformPlansSection extends StatelessWidget {
  const PlatformPlansSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PlatformPlansCubit, PlatformPlansState>(
      builder: (context, state) {
        if (state is PlatformPlansLoading) {
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
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingShimmer(
                      width: 270,
                      height: 135,
                      borderRadius: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LoadingShimmer(
                            width: 180,
                            height: 16,
                            borderRadius: 6,
                          ),
                          SizedBox(height: 12),
                          LoadingShimmer(
                            width: 120,
                            height: 12,
                            borderRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.exploreFreePlans, // 🔥 ترجمة العنوان من الـ JSON
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.allPlatformPlans,
                        );
                      },
                      child: Text(
                        l10n.see_all,
                        style: const TextStyle(
                          color: AppColors.primaryBtn,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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