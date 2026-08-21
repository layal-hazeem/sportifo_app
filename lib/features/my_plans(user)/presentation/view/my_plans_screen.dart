import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/widgets/no_internet_view.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../coaches/presentation/views/all_coaches_screen.dart';
import '../../../platform_plans/presentation/widgets/platform_plan_card.dart';
import '../../data/models/my_plan_model.dart';
import '../../data/repository/my_plans_repository.dart';
import '../view_model/my_plans_cubit.dart';
import '../view_model/my_plans_state.dart';
import '../widgets/workout_plan_card.dart';

class _PlanTabConfig {
  final PlanTabType type;
  final String label;
  final String emptyTitle;
  final String emptySubtitle;
  final String? emptyButtonText;
  final void Function(BuildContext context)? onEmptyButtonTap;

  const _PlanTabConfig({
    required this.type,
    required this.label,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.emptyButtonText,
    this.onEmptyButtonTap,
  });
}

class MyPlansScreen extends StatefulWidget {
  const MyPlansScreen({super.key});

  static final ValueNotifier<int> activeTabNotifier = ValueNotifier<int>(0);

  @override
  State<MyPlansScreen> createState() => _MyPlansScreenState();
}

class _MyPlansScreenState extends State<MyPlansScreen> {
  late int _activeTabIndex;

  final List<PlanTabType> _tabTypes = [
    PlanTabType.coach,
    PlanTabType.custom,
    PlanTabType.saved,
  ];

  List<_PlanTabConfig> _getTabConfigs(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _PlanTabConfig(
        type: PlanTabType.coach,
        label: l10n.coachPlan,
        emptyTitle: l10n.noCoachPlanFound,
        emptySubtitle: l10n.noCoachPlanSub,
        emptyButtonText: l10n.exploreCoaches,
        onEmptyButtonTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AllCoachesScreen()),
          );
        },
      ),
      _PlanTabConfig(
        type: PlanTabType.custom,
        label: l10n.myPlans,
        emptyTitle: l10n.noCustomPlans,
        emptySubtitle: l10n.noCustomPlansSub,
        emptyButtonText: l10n.createCustomPlan,
        onEmptyButtonTap: (context) {
          Navigator.pushNamed(context, AppRoutes.createSelfPlan);
        },
      ),
      _PlanTabConfig(
        type: PlanTabType.saved,
        label: l10n.saved,
        emptyTitle: l10n.noSavedPlans,
        emptySubtitle: l10n.noSavedPlansSub,
        emptyButtonText: l10n.exploreFreePlans,
        onEmptyButtonTap: (context) {
          Navigator.pushNamed(context, AppRoutes.allPlatformPlans);
        },
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _activeTabIndex = MyPlansScreen.activeTabNotifier.value;
    context.read<MyPlansCubit>().fetchTab(_tabTypes[_activeTabIndex]);

    MyPlansScreen.activeTabNotifier.addListener(_onExternalTabChange);
  }

  void _onExternalTabChange() {
    final newIndex = MyPlansScreen.activeTabNotifier.value;
    if (mounted) {
      setState(() => _activeTabIndex = newIndex);
      context.read<MyPlansCubit>().fetchTab(_tabTypes[newIndex]);
    }
  }

  @override
  void dispose() {
    MyPlansScreen.activeTabNotifier.removeListener(_onExternalTabChange);
    super.dispose();
  }

  void _onTabTap(int index) {
    setState(() => _activeTabIndex = index);
    MyPlansScreen.activeTabNotifier.value = index;
    context.read<MyPlansCubit>().fetchTab(_tabTypes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // 🌐 جلب الترجمة
    final tabConfigs = _getTabConfigs(context);
    final activeConfig = tabConfigs[_activeTabIndex];

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom: 4,
              ),
              height: 56,
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  for (int i = 0; i < tabConfigs.length; i++)
                    _buildToggleButton(tabConfigs[i].label, i),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<MyPlansCubit, MyPlansState>(
                builder: (context, state) {
                  final status = state.statusFor(activeConfig.type);
                  return switch (status) {
                    TabLoading() || TabInitial() => _buildShimmerLoading(),
                    TabFailure() => NoInternetView(
                      onRetry: () => context.read<MyPlansCubit>().fetchTab(
                        activeConfig.type,
                        isRefresh: true,
                      ),
                      title: l10n.unableToLoadPlans, // 🌐 تم الاستبدال
                      subtitle: l10n.unableToLoadPlansSub, // 🌐 تم الاستبدال
                    ),
                    TabSuccess() => _buildPlansList(activeConfig, status.plans),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String title, int tabIndex) {
    final isSelected = _activeTabIndex == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTap(tabIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBtn : context.backgroundColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.hintText,
              fontWeight: FontWeight.bold,
              fontSize: 13.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlansList(_PlanTabConfig config, List<PlanModel> plans) {
    if (plans.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primaryBtn,
        onRefresh: () async => await context.read<MyPlansCubit>().fetchTab(
          config.type,
          isRefresh: true,
        ),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    config.emptyTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    config.emptySubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.hintText,
                      fontSize: 14.0,
                      height: 1.5,
                    ),
                  ),
                  if (config.emptyButtonText != null) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: config.onEmptyButtonTap != null
                            ? () => config.onEmptyButtonTap!(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBtn,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        child: Text(
                          config.emptyButtonText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryBtn,
      onRefresh: () async => await context.read<MyPlansCubit>().fetchTab(
        config.type,
        isRefresh: true,
      ),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          if (config.type == PlanTabType.saved) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Align(
                alignment: Alignment.center,
                child: PlatformPlanCard(
                  plan: plans[index],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.planDays,
                      arguments: plans[index],
                    );
                  },
                ),
              ),
            );
          }

          return WorkoutPlanCard(plan: plans[index]);
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LoadingShimmer(
                width: double.infinity,
                height: 140,
                borderRadius: 18,
              ),
              const SizedBox(height: 14),
              LoadingShimmer(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 16,
                borderRadius: 6,
              ),
              const SizedBox(height: 10),
              LoadingShimmer(
                width: MediaQuery.of(context).size.width * 0.35,
                height: 12,
                borderRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}