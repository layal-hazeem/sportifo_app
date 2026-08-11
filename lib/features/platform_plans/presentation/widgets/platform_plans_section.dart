import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
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
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryBtn),
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
                      'Free Plans',
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