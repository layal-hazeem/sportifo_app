import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/my_plan_model.dart';
import '../view_model/active_workout_cubit.dart';
import '../widgets/workout_confirm_dialog.dart';
import 'exercise_preview_screen.dart';

class DayOverviewScreen extends StatelessWidget {
  final PlanDayModel day;
  final int dayNumber;
  final int planId;

  const DayOverviewScreen({
    super.key,
    required this.day,
    required this.dayNumber,
    required this.planId,
  });

  // 🔥 دالة سحرية للتعامل مع بدء التمرين من أي مكان
  void _startWorkoutFlow(BuildContext context, int targetIndex) async {
    final l10n = AppLocalizations.of(context)!;
    if (day.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.no_exercises_found), backgroundColor: AppColors.primaryBtn));
      return;
    }

    final activeWorkoutCubit = getIt<ActiveWorkoutCubit>();
    final savedSession = await activeWorkoutCubit.getSavedSession();
    bool isSameDay = savedSession != null && savedSession['day_id'] == day.id;

    if (isSameDay) {
      int savedIndex = savedSession['exercise_index'] ?? 0;
      if (savedIndex < 0 || savedIndex >= day.exercises.length) savedIndex = 0;

      final unfinishedExercise = day.exercises[savedIndex];
      final tappedExercise = day.exercises[targetIndex];

      WorkoutConfirmDialog.show(
        context: context,
        icon: Icons.history_toggle_off_rounded,
        iconColor: AppColors.primaryBtn,
        title: "Unfinished Exercise",
        message:
        "You still have an unfinished exercise in this day: \"${unfinishedExercise.name}\".\n\n"
            "Would you like to go finish it, or discard it and start \"${tappedExercise.name}\" instead?",
        primaryText: "Go Finish It",
        primaryColor: AppColors.primaryBtn,
        onPrimary: () async {
          await activeWorkoutCubit.restoreSessionData();
          activeWorkoutCubit.startWorkout(day.exercises, startIndex: savedIndex);
          Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider.value(
            value: activeWorkoutCubit,
            child: ExercisePreviewScreen(
              exercise: day.exercises[savedIndex],
              dayName: day.name,
              planId: planId,
              dayId: day.id,
              completedSets: activeWorkoutCubit.allLoggedSets[savedIndex],
            ),
          )));
        },
        secondaryText: "Discard & Start \"${tappedExercise.name}\"",
        onSecondary: () {
          activeWorkoutCubit.clearSessionLocally();
          activeWorkoutCubit.startWorkout(day.exercises, startIndex: targetIndex);
          Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider.value(
            value: activeWorkoutCubit,
            child: ExercisePreviewScreen(exercise: day.exercises[targetIndex], dayName: day.name, planId: planId, dayId: day.id),
          )));
        },
      );
    } else {
      activeWorkoutCubit.startWorkout(day.exercises, startIndex: targetIndex);
      Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider.value(
        value: activeWorkoutCubit,
        child: ExercisePreviewScreen(exercise: day.exercises[targetIndex], dayName: day.name, planId: planId, dayId: day.id),
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildPremiumHeader(context),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.exercisesList,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBtn.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${day.exercises.length} ${l10n.total}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryBtn),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final exercise = day.exercises[index];

                  String imageUrl = '';
                  if (exercise.images.isNotEmpty) {
                    final imageObj = exercise.images.firstWhere(
                          (img) => img.type == 'gif',
                      orElse: () => exercise.images.first,
                    );
                    imageUrl = imageObj.url ?? '';
                  }

                  // 🔥 فحص نوع التمرين بناءً على الكاتيجوري أو وجود الـ Duration
                  bool isCardio = (exercise.category != null && exercise.category!.name.toLowerCase() == 'cardio') ||
                      (exercise.duration != null && exercise.duration.toString().isNotEmpty && exercise.duration.toString() != "0");

                  String displaySets = '${exercise.sets ?? 0} ${l10n.set}s';
                  String displayDetailInfo = '';
                  IconData detailIcon = Icons.repeat_rounded;

                  if (isCardio) {
                    // إذا كارديو: اعرض أيقونة ساعة والوقت المطلوب
                    displayDetailInfo = '${l10n.duration} ${exercise.duration ?? "N/A"}';
                    detailIcon = Icons.timer_outlined;
                  } else {
                    // إذا حديد: اعرض أيقونة إعادة والعدّات
                    final String repsStr = exercise.reps ?? '';
                    displayDetailInfo = repsStr.contains(':')
                        ? repsStr
                        : (repsStr.isNotEmpty ? '$repsStr ${l10n.reps}' : 'N/A');
                    detailIcon = Icons.repeat_rounded;
                  }

                  return _AnimatedExerciseCard(
                    index: index,
                    child: GestureDetector(
                      onTap: () => _startWorkoutFlow(context, index),
                      child: _buildExerciseCard(imageUrl, exercise, displaySets, displayDetailInfo, detailIcon, index),
                    ),
                  );
                },
                childCount: day.exercises.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF12141C),
      iconTheme: const IconThemeData(color: Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20, right: 90),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DAY $dayNumber',
              style: TextStyle(
                color: AppColors.primaryBtn,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1.5,
                shadows: [Shadow(color: AppColors.primaryBtn.withOpacity(0.3), blurRadius: 8)],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        background: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Text(
                '0$dayNumber',
                style: TextStyle(
                  fontSize: 130,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.04),
                  letterSpacing: -10,
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 16,
              child: _GlowingPlayButton(
                onPressed: () => _startWorkoutFlow(context, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(String imageUrl, dynamic exercise, String displaySets, String displayDetailInfo, IconData detailIcon, int index) {
    final String exerciseNumber = (index + 1) < 10 ? '0${index + 1}' : '${index + 1}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 90,
                    width: 90,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: const Color(0xFFF0F0F0)),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFF0F0F0),
                        child: const Icon(Icons.fitness_center, color: AppColors.hintText),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF12141C),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      exerciseNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textDark, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // 🔥 تعديل مكان الأيقونات وعرض المعلومات
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.local_fire_department_rounded, displaySets),
                      _buildInfoChip(detailIcon, displayDetailInfo, isPrimary: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📐 ودجت رقاقات المعلومات المحدث ليستقبل Icon
  Widget _buildInfoChip(IconData icon, String text, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primaryBtn.withOpacity(0.08) : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isPrimary ? AppColors.primaryBtn : Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isPrimary ? AppColors.primaryBtn : Colors.grey.shade700,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedExerciseCard extends StatefulWidget {
  final Widget child;
  final int index;
  const _AnimatedExerciseCard({required this.child, required this.index});
  @override
  State<_AnimatedExerciseCard> createState() => _AnimatedExerciseCardState();
}

class _AnimatedExerciseCardState extends State<_AnimatedExerciseCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
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
    return FadeTransition(opacity: _fadeAnimation, child: SlideTransition(position: _slideAnimation, child: widget.child));
  }
}

class _GlowingPlayButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _GlowingPlayButton({required this.onPressed});
  @override
  State<_GlowingPlayButton> createState() => _GlowingPlayButtonState();
}

class _GlowingPlayButtonState extends State<_GlowingPlayButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    Future.delayed(const Duration(milliseconds: 300), () {
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBtn.withOpacity(0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: FloatingActionButton(
          onPressed: widget.onPressed,
          backgroundColor: AppColors.primaryBtn,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
        ),
      ),
    );
  }
}