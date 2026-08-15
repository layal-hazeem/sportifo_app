import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/wave_app_bar.dart';
import '../view_model/platform_plans_cubit.dart';
import '../view_model/platform_plans_state.dart';
import '../widgets/platform_plan_card.dart';

class AllPlatformPlansScreen extends StatefulWidget {
  const AllPlatformPlansScreen({super.key});

  @override
  State<AllPlatformPlansScreen> createState() => _AllPlatformPlansScreenState();
}

class _AllPlatformPlansScreenState extends State<AllPlatformPlansScreen> {

  @override
  void initState() {
    super.initState();
    // نجلب الداتا مرة تانية لتتحدث القائمة (اختياري بس مفضل عشان يجيب أحدث الخطط)
    getIt<PlatformPlansCubit>().fetchPlatformPlans();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 التعديل هنا: استخدمنا BlocProvider.value عشان ما يتدمر الكيوبيت بس نطلع من الشاشة
    return BlocProvider.value(
      value: getIt<PlatformPlansCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const WaveAppBar(
          title: 'Sportifo Plans',
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