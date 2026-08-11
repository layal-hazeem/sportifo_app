import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workout/data/models/exercise_model.dart';
import '../view_model/active_workout_cubit.dart';
import '../view_model/active_workout_state.dart';
import '../widgets/set_input_card.dart';
import '../widgets/timed_set_input_card.dart';
import '../widgets/workout_confirm_dialog.dart';
import 'exercise_preview_screen.dart';
import 'rest_workout_screen.dart';

class ActivePlayScreen extends StatefulWidget {
  final String dayName;
  final int planId;
  final int dayId;

  const ActivePlayScreen({
    super.key,
    required this.dayName,
    required this.planId,
    required this.dayId,
  });

  @override
  State<ActivePlayScreen> createState() => _ActivePlayScreenState();
}

class _ActivePlayScreenState extends State<ActivePlayScreen> {
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  bool _isLoading = false;

  Timer? _globalTimer;
  int _globalSeconds = 0;
  bool _isPaused = true;

  bool _isTimedExercise = false;

  bool _isCountingDown = false;
  int _countdown = 3;
  Timer? _countdownTimer;

  int? _lastProcessedExerciseIndex;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController();
    _weightController = TextEditingController();
    _startGlobalTimer();

    final currentState = context.read<ActiveWorkoutCubit>().state;
    if (currentState is ActiveWorkoutInProgress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _setupExercise(currentState, isInitial: true);
      });
    }
  }

  void _startGlobalTimer() {
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isCountingDown && mounted) {
        setState(() => _globalSeconds++);
      }
    });
  }

  void _setupExercise(ActiveWorkoutInProgress state, {bool isInitial = false}) {
    _countdownTimer?.cancel();
    _weightController.clear();
    _repsController.clear();

    final exercise = state.currentExercise;

    bool isCardioCategory = exercise.category != null && exercise.category!.name.toLowerCase() == 'cardio';
    bool hasDuration = exercise.duration != null && exercise.duration.toString().isNotEmpty && exercise.duration.toString() != "0";
    _isTimedExercise = isCardioCategory || hasDuration;

    if (!_isTimedExercise) {
      _updateDefaultRepsInput(state);
    }

    bool isNewExercise = _lastProcessedExerciseIndex != state.currentIndex;
    if (isNewExercise || isInitial) {
      _lastProcessedExerciseIndex = state.currentIndex;
      _startCountdown();
    } else {
      setState(() {
        _isCountingDown = false;
        _isPaused = false;
      });
    }
  }

  // 🔥 اللوجيك المحدث والمنطقي للعداد (يبدأ من 3 بثبات)
  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdown = 3; // البداية الأكيدة
      _isPaused = true;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_countdown > 1) {
          _countdown--;
        } else {
          // الانتهاء بعد 3 ثواني
          timer.cancel();
          _isCountingDown = false;
          _isPaused = false;
        }
      });
    });
  }

  void _updateDefaultRepsInput(ActiveWorkoutInProgress state) {
    final exercise = state.currentExercise;
    int currentSetIdx = state.completedSets.length;
    if (exercise.reps != null && exercise.reps!.isNotEmpty) {
      List<String> repsList = exercise.reps!.split(RegExp(r'[:,/\-]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (repsList.isNotEmpty) {
        String target = currentSetIdx < repsList.length ? repsList[currentSetIdx] : repsList.last;
        _repsController.text = target.replaceAll(RegExp(r'[^0-9]'), '');
      }
    }
  }

  void _togglePause() {
    if (_isCountingDown) return;
    setState(() => _isPaused = !_isPaused);
  }

  void _onCancelWorkout() {
    WorkoutConfirmDialog.show(
      context: context,
      icon: Icons.close_rounded,
      iconColor: Colors.red,
      title: "Cancel Workout?",
      message: "All progress for this session will be lost and won't be saved.",
      primaryText: "No, Keep Going",
      onPrimary: () {},
      primaryColor: AppColors.primaryBtn,
      secondaryText: "Yes, Cancel Workout",
      onSecondary: () => Navigator.pop(context),
    );
  }

  void _onFinishWorkout() {
    final workoutCubit = context.read<ActiveWorkoutCubit>();
    final state = workoutCubit.state;
    if (state is! ActiveWorkoutInProgress) return;

    WorkoutConfirmDialog.show(
      context: context,
      icon: Icons.pause_circle_outline_rounded,
      iconColor: AppColors.primaryBtn,
      title: "End Session",
      message: "Would you like to save your current progress and continue later, or discard this session completely?",
      primaryText: "Save & Exit",
      primaryColor: AppColors.primaryBtn,
      onPrimary: () async {
        await workoutCubit.saveSessionLocally(widget.planId, widget.dayId, state.currentIndex);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: workoutCubit,
              child: ExercisePreviewScreen(
                exercise: state.currentExercise,
                dayName: widget.dayName,
                planId: widget.planId,
                dayId: widget.dayId,
                completedSets: state.completedSets,
                isFinishedEarly: true,
                isLastExercise: false,
              ),
            ),
          ),
        );
      },
      secondaryText: "Discard Session",
      onSecondary: () async {
        await workoutCubit.clearSessionLocally();
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  void _showHowToDialog(String? description) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.info_outline_rounded, color: AppColors.primaryBtn),
            SizedBox(width: 8),
            Text("How to perform?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Text(
          (description == null || description.isEmpty)
              ? "No instructions available for this exercise."
              : description,
          style: const TextStyle(height: 1.5, fontSize: 14, color: AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Got It", style: TextStyle(color: AppColors.primaryBtn, fontWeight: FontWeight.bold)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
      ),
    );
  }

  void _onLogSet(ActiveWorkoutInProgress state) {
    if (_repsController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter weight and reps')));
      return;
    }
    context.read<ActiveWorkoutCubit>().logSet(weight: _weightController.text, reps: _repsController.text);
    _handlePostSetActions(state, state.currentExercise, state.completedSets.length);
  }

  void _onLogTimedSet(ActiveWorkoutInProgress state) {
    if (_repsController.text.isEmpty) return;
    context.read<ActiveWorkoutCubit>().logSet(weight: "0.0", reps: _repsController.text);
    _handlePostSetActions(state, state.currentExercise, state.completedSets.length);
  }

  void _onSkipSet(ActiveWorkoutInProgress state) {
    context.read<ActiveWorkoutCubit>().skipSet();
    _handlePostSetActions(state, state.currentExercise, state.completedSets.length);
  }

  void _handlePostSetActions(ActiveWorkoutInProgress state, ExerciseModel exercise, int currentSetIdx) {
    setState(() => _isPaused = true);

    int totalSets = exercise.sets ?? 1;
    bool isLastSetOfExercise = (currentSetIdx + 1) >= totalSets;
    bool isAbsoluteLastExercise = (state.currentIndex == state.exercises.length - 1);

    if (isLastSetOfExercise) {
      final updatedState = context.read<ActiveWorkoutCubit>().state;
      List<LoggedSetModel> finalSets = [];
      if (updatedState is ActiveWorkoutInProgress) finalSets = updatedState.completedSets;

      context.read<ActiveWorkoutCubit>().syncExerciseToServer(planId: widget.planId, exercise: exercise);
      String totalTimeStr = '${(_globalSeconds ~/ 60).toString().padLeft(2, '0')}:${(_globalSeconds % 60).toString().padLeft(2, '0')}';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ActiveWorkoutCubit>(),
            child: ExercisePreviewScreen(
              exercise: exercise,
              dayName: widget.dayName,
              planId: widget.planId,
              dayId: widget.dayId,
              completedSets: finalSets,
              isLastExercise: isAbsoluteLastExercise,
              workoutTimeStr: totalTimeStr,
            ),
          ),
        ),
      );
    } else {
      ExerciseModel? nextEx;
      if (state.currentIndex < state.exercises.length - 1) {
        nextEx = state.exercises[state.currentIndex + 1];
      }
      _showBlurryRestSheet(isLastSet: false, nextExercise: nextEx, exercise: exercise, currentSetIndex: currentSetIdx);
    }
  }

  void _showBlurryRestSheet({required bool isLastSet, required ExerciseModel? nextExercise, required ExerciseModel exercise, required int currentSetIndex}) {
    setState(() => _isPaused = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) {
        return RestWorkoutScreen(
          restTimeSeconds: 45,
          isLastSet: isLastSet,
          nextExercise: nextExercise,
          currentExerciseName: exercise.name,
          currentSetIndex: currentSetIndex,
          onRestFinished: () {
            Navigator.pop(ctx);
            setState(() {
              _isPaused = false;
              final updatedState = context.read<ActiveWorkoutCubit>().state;
              if (updatedState is ActiveWorkoutInProgress) {
                if (!_isTimedExercise) _updateDefaultRepsInput(updatedState);
              }
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    _countdownTimer?.cancel();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActiveWorkoutCubit, ActiveWorkoutState>(
      listener: (context, state) {
        if (state is ActiveWorkoutCompleted) {
          String totalTimeStr = '${(_globalSeconds ~/ 60).toString().padLeft(2, '0')}:${(_globalSeconds % 60).toString().padLeft(2, '0')}';
          int totalEx = context.read<ActiveWorkoutCubit>().exercises.length;

          Navigator.pushReplacementNamed(
            context,
            AppRoutes.workoutSummary,
            arguments: {
              'dayName': widget.dayName,
              'totalTime': totalTimeStr,
              'totalExercises': totalEx,
              'exercises': context.read<ActiveWorkoutCubit>().exercises,
              'allLoggedSets': context.read<ActiveWorkoutCubit>().allLoggedSets,
            },
          );
        } else if (state is ActiveWorkoutInProgress) {
          _setupExercise(state);
        }
      },
      builder: (context, state) {
        if (state is! ActiveWorkoutInProgress) return const Scaffold(backgroundColor: Color(0xFFF8F9FC));

        final exercise = state.currentExercise;
        final totalSets = exercise.sets ?? 1;
        final completedSets = state.completedSets;
        int currentActiveSetIndex = completedSets.length;

        String imageUrl = exercise.images.isNotEmpty ? (exercise.images.firstWhere((img) => img.type == 'gif', orElse: () => exercise.images.first).url ?? '') : '';
        String formatTime(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
        String repsDisplay = exercise.reps != null ? exercise.reps!.replaceAll(RegExp(r'[:,/\-]+'), ' ') : '10 10 10';

        final scaffold = Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exercise.name.toUpperCase(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "EXERCISE ${state.currentIndex + 1} OF ${state.exercises.length}",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.hintText, letterSpacing: 0.5),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              if (!_isTimedExercise)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: AppColors.primaryBtn, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          formatTime(_globalSeconds),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textDark, fontFeatures: [FontFeature.tabularFigures()]),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              height: 280,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorWidget: (c, u, e) => const SizedBox(height: 300, child: Icon(Icons.fitness_center, size: 50, color: Colors.grey)),
                            ),
                          ),
                          if (_isPaused && !_isCountingDown)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.35),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle),
                                        child: const Icon(Icons.pause_rounded, color: AppColors.textDark, size: 36),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => _showHowToDialog(exercise.description),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "?",
                                    style: TextStyle(
                                      color: AppColors.primaryBtn,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isPaused && !_isCountingDown)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.pause_rounded, color: Colors.orange, size: 16),
                              const SizedBox(width: 6),
                              Text("Paused", style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department_outlined, color: AppColors.primaryBtn, size: 18),
                          const SizedBox(width: 4),
                          Text("$totalSets Sets", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark)),
                          const SizedBox(width: 20),
                          Icon(_isTimedExercise ? Icons.timer_outlined : Icons.repeat_rounded, color: AppColors.primaryBtn, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            _isTimedExercise ? "Target ${exercise.duration ?? "1:00"} Min" : "Reps $repsDisplay",
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isTimedExercise
                          ? TimedSetInputCard(
                        currentSet: currentActiveSetIndex + 1,
                        totalSets: totalSets,
                        targetDuration: exercise.duration ?? "1:00",
                        durationController: _repsController,
                        isPaused: _isPaused,
                        isLoading: _isLoading,
                        onLogSet: () => _onLogTimedSet(state),
                        onSkipSet: () => _onSkipSet(state),
                      )
                          : SetInputCard(
                        currentSet: currentActiveSetIndex + 1,
                        totalSets: totalSets,
                        weightController: _weightController,
                        repsController: _repsController,
                        isPaused: _isPaused,
                        isLoading: _isLoading,
                        onLogSet: () => _onLogSet(state),
                        onSkipSet: () => _onSkipSet(state),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: _onCancelWorkout,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(border: Border.all(color: Colors.black87, width: 1.5), shape: BoxShape.circle),
                            child: const Icon(Icons.close_rounded, color: Colors.black87, size: 22),
                          ),
                          const SizedBox(height: 4),
                          const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _togglePause,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(border: Border.all(color: Colors.black87, width: 1.5), shape: BoxShape.circle),
                            child: Icon(_isPaused && !_isCountingDown ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.black87, size: 22),
                          ),
                          const SizedBox(height: 4),
                          const Text("Pause", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _onFinishWorkout,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(border: Border.all(color: AppColors.primaryBtn, width: 1.5), shape: BoxShape.circle),
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.primaryBtn, borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text("Finish", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryBtn)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _onFinishWorkout();
          },
          child: Stack(
            children: [
              scaffold,
              // 🔥 واجهة GET READY مع حل مشكلة الخطوط 🔥
              if (_isCountingDown)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Material( // 👈 المُنقِذ السري! Material شفاف لمنع الخطوط الصفراء
                      color: Colors.transparent,
                      child: Container(
                        color: const Color(0xFF0F111A).withOpacity(0.85),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "PREPARE FOR",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  decoration: TextDecoration.none, // 👈 حماية إضافية
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                exercise.name.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                  decoration: TextDecoration.none, // 👈 حماية إضافية
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                                        CurvedAnimation(parent: animation, curve: Curves.elasticOut)
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                "$_countdown",
                                key: ValueKey<int>(_countdown),
                                style: const TextStyle(
                                  color: AppColors.primaryBtn,
                                  fontSize: 120,
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.none, // 👈 حماية إضافية
                                  fontFeatures: [FontFeature.tabularFigures()],
                                  shadows: [
                                    Shadow(color: AppColors.primaryBtn, blurRadius: 30),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}