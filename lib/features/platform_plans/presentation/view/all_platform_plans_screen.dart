import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/wave_app_bar.dart';
import '../../../../core/widgets/loading_shimmer.dart'; // 🔥 استدعاء الشيمر
import '../../../../l10n/app_localizations.dart'; // 🔥 استدعاء الترجمة
import '../view_model/platform_plans_cubit.dart';
import '../view_model/platform_plans_state.dart';
import '../widgets/platform_plan_card.dart';

class AllPlatformPlansScreen extends StatefulWidget {
  const AllPlatformPlansScreen({super.key});

  @override
  State<AllPlatformPlansScreen> createState() => _AllPlatformPlansScreenState();
}

class _AllPlatformPlansScreenState extends State<AllPlatformPlansScreen> {
  Locale? _currentLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_currentLocale != locale) {
      _currentLocale = locale;
      getIt<PlatformPlansCubit>().fetchPlatformPlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: getIt<PlatformPlansCubit>(),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: WaveAppBar(title: l10n.exploreFreePlans), // 🔥 ترجمة العنوان
        body: BlocBuilder<PlatformPlansCubit, PlatformPlansState>(
          builder: (context, state) {
            if (state is PlatformPlansLoading) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LoadingShimmer(
                            width: double.infinity,
                            height: 135,
                            borderRadius: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const LoadingShimmer(width: 150, height: 16, borderRadius: 6),
                                const SizedBox(height: 12),
                                const LoadingShimmer(width: 100, height: 12, borderRadius: 6),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                return Center(
                  child: Text(
                    l10n.noCustomPlans,
                    style: const TextStyle(color: AppColors.hintText, fontSize: 16),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryBtn,
                onRefresh: () async {
                  await context.read<PlatformPlansCubit>().fetchPlatformPlans();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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