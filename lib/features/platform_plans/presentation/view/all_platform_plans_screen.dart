import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
 import '../../../../core/widgets/wave_app_bar.dart';
import '../view_model/platform_plans_cubit.dart';
import '../view_model/platform_plans_state.dart';
import '../widgets/platform_plan_card.dart';

class AllPlatformPlansScreen extends StatelessWidget {
  const AllPlatformPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PlatformPlansCubit>()..fetchPlatformPlans(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        // 🔥 التعديل هنا: استدعاء الـ WaveAppBar بكل بساطة
        appBar: const WaveAppBar(
          title: 'Explore Platform Plans',
        ),
        body: BlocBuilder<PlatformPlansCubit, PlatformPlansState>(
          builder: (context, state) {
            if (state is PlatformPlansLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBtn),
              );
            }

            if (state is PlatformPlansError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.hintText),
                ),
              );
            }

            if (state is PlatformPlansSuccess) {
              final plans = state.plans;

              if (plans.isEmpty) {
                return const Center(
                  child: Text(
                    'No platform plans available right now.',
                    style: TextStyle(color: AppColors.hintText, fontSize: 16),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryBtn,
                onRefresh: () async {
                  await context.read<PlatformPlansCubit>().fetchPlatformPlans();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: PlatformPlanCard(
                          plan: plan,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.planDays,
                              arguments: plan,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}