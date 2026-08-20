import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sportifo_app/core/di/service_locator.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import 'package:sportifo_app/features/edit_self_plan/presentation/view_model/edit_self_plan_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/my_plan_model.dart';
import '../view_model/plan_days_cubit.dart';
import '../view_model/plan_days_state.dart';
import 'day_overview_screen.dart';
import 'package:sportifo_app/features/edit_self_plan/presentation/view/edit_self_plan_screen.dart';

class PlanDaysScreen extends StatelessWidget {
  final PlanModel plan;

  const PlanDaysScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: BlocBuilder<PlanDaysCubit, PlanDaysState>(
        builder: (context, state) {
          if (state is PlanDaysLoading) {
            return _buildDaysShimmerLoading();
          }

          if (state is PlanDaysFailure) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(
                  color: AppColors.hintText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          if (state is PlanDaysSuccess) {
            final detailedPlan = state.planDetails;

            if (detailedPlan.days.isEmpty) {
              return _buildEmptyState(l10n);
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildPremiumAppBar(context, detailedPlan, l10n),

                SliverToBoxAdapter(
                  child: _buildWeekProgressBar(state, context, l10n),
                ),

                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: 40,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final day = detailedPlan.days[index];
                      // Smart check: Is this day completed based on its planDayId?
                      final isDoneThisWeek = state.isDayCompleted(day.id);
                      return _AnimatedDayCard(
                        index: index,
                        child: _buildPremiumDayCard(
                          context,
                          day,
                          index,
                          detailedPlan.id,
                          isDoneThisWeek,
                          l10n,
                        ),
                      );
                    }, childCount: detailedPlan.days.length),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPremiumAppBar(BuildContext context, dynamic detailedPlan, AppLocalizations l10n) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color appBarColor = isDarkMode
        ? AppColors.primaryBtn
        : const Color(0xFF12141C);

    final Color editButtonColor = isDarkMode
        ? const Color(0xFF12141C)
        : AppColors.primaryBtn;

    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: appBarColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (detailedPlan.isSelfMade == true)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Material(
                color: editButtonColor,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => getIt<EditSelfPlanCubit>(),
                          child: EditSelfPlanScreen(plan: detailedPlan),
                        ),
                      ),
                    );

                    if (result == true && context.mounted) {
                      context.read<PlanDaysCubit>().fetchPlanDays(plan.id);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 20, right: 24),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.workoutDays,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              plan.goal?.toUpperCase() ?? l10n.yourFitnessJourney,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        background: Stack(
          children: [
            Positioned(
              right: -30,
              top: -10,
              child: Icon(
                Icons.calendar_view_day_rounded,
                size: 150,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekProgressBar(PlanDaysSuccess state, BuildContext context, AppLocalizations l10n) {
    int totalWeeks = state.totalWeeks > 0 ? state.totalWeeks : 1;

    // The backend does not stop the user from continuing to play even after finishing
    // all weeks of the plan (current_week can be greater than totalWeeks).
    // This is intended. We show the actual number ("Week 9 of 8") as is.
    // The visual progress bar stops at 100% since it physically cannot exceed its limits.
    int currentWeek = state.currentWeek;

    // Magic here: Accurate calculation of progress percentage starting from 0%
    int totalDaysInWeek = state.planDetails.days.length;
    int completedDaysThisWeek = state.completedPlanDayIds.length;

    // Calculate how many days finished in this week
    double weekProgress = totalDaysInWeek > 0
        ? (completedDaysThisWeek / totalDaysInWeek)
        : 0.0;

    // Calculate total progress
    double progress = ((currentWeek - 1) + weekProgress) / totalWeeks;
    progress = progress.clamp(0.0, 1.0); // Keep visual bar at max 100%

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.weeklyProgress,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${l10n.week} $currentWeek ${l10n.of_word} $totalWeeks",
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: progress == 1.0
                      ? Colors.green.shade50
                      : AppColors.primaryBtn.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    color: progress == 1.0
                        ? Colors.green.shade700
                        : AppColors.primaryBtn,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress, // Will be 0.0 initially
              minHeight: 10,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green.shade500 : AppColors.primaryBtn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDayCard(
      BuildContext context,
      PlanDayModel day,
      int index,
      int planId,
      bool isDoneThisWeek,
      AppLocalizations l10n,
      ) {
    // Check app theme (Dark Mode or Light Mode)
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Dynamic colors based on theme and completion status
    final Color mainColor = isDoneThisWeek
        ? const Color(0xFF10B981)
        : AppColors.primaryBtn;

    final Color bgColor = isDoneThisWeek
        ? const Color(0xFF10B981).withOpacity(isDarkMode ? 0.12 : 0.06)
        : (isDarkMode
        ? const Color(0xFF1E222D)
        : Colors.white); // Card background color adapts to theme

    final Color borderColor = isDoneThisWeek
        ? (isDarkMode ? Colors.green.shade700 : Colors.green.shade300)
        : (isDarkMode ? Colors.white.withOpacity(0.08) : Colors.transparent);

    // Background color of the day number icon and internal icons
    final Color innerBoxColor = isDoneThisWeek
        ? (isDarkMode ? Colors.green.withOpacity(0.2) : Colors.green.shade100)
        : (isDarkMode ? const Color(0xFF12141C) : const Color(0xFF12141C));

    // Secondary text colors and inner small containers
    final Color badgeBgColor = isDoneThisWeek
        ? (isDarkMode ? Colors.green.withOpacity(0.2) : Colors.white)
        : (isDarkMode ? Colors.white.withOpacity(0.06) : Colors.grey.shade100);

    final Color badgeTextColor = isDoneThisWeek
        ? (isDarkMode ? Colors.green.shade300 : Colors.green.shade700)
        : (isDarkMode ? Colors.white70 : Colors.grey.shade700);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            highlightColor: mainColor.withOpacity(0.05),
            splashColor: mainColor.withOpacity(0.1),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DayOverviewScreen(
                    day: day,
                    dayNumber: index + 1,
                    planId: planId,
                  ),
                ),
              );
              if (context.mounted) {
                context.read<PlanDaysCubit>().refreshProgress();
              }
            },
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 6, color: mainColor),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: innerBoxColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: isDoneThisWeek
                            ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 32,
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.dayLabel,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 22,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day.name.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(
                                  0xFF12141C,
                                ), // Exercise title color adapts to theme
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeBgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.fitness_center_rounded,
                                        size: 14,
                                        color: badgeTextColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${day.exercises.length} ${l10n.exercises}',
                                        style: TextStyle(
                                          color: badgeTextColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isDoneThisWeek)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.completedStatus,
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.green.shade300
                                            : Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: mainColor.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Shimmer structure similar to "Weekly Progress" card top + day cards below
  Widget _buildDaysShimmerLoading() {
    return SafeArea(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const LoadingShimmer(
            width: double.infinity,
            height: 90,
            borderRadius: 24,
          ),
          const SizedBox(height: 20),
          ...List.generate(
            4,
                (index) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LoadingShimmer(
                width: double.infinity,
                height: 96,
                borderRadius: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDaysCreated,
              style: const TextStyle(
                color: AppColors.hintText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedDayCard extends StatefulWidget {
  final Widget child;
  final int index;
  const _AnimatedDayCard({required this.child, required this.index});
  @override
  State<_AnimatedDayCard> createState() => _AnimatedDayCardState();
}

class _AnimatedDayCardState extends State<_AnimatedDayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}