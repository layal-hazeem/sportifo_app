import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workout/data/models/exercise_model.dart';
import '../view_model/active_workout_cubit.dart';
import '../view_model/active_workout_state.dart';
import 'active_play_screen.dart';

class ExercisePreviewScreen extends StatelessWidget {
  final ExerciseModel exercise;
  final String dayName;
  final int planId;
  final int dayId;
  final List<LoggedSetModel>? completedSets;
  final bool isLastExercise;
  final bool isFinishedEarly;
  final String? workoutTimeStr;

  const ExercisePreviewScreen({
    super.key,
    required this.exercise,
    required this.dayName,
    required this.planId,
    required this.dayId,
    this.completedSets,
    this.isLastExercise = false,
    this.isFinishedEarly = false,
    this.workoutTimeStr,
  });

  @override
  Widget build(BuildContext context) {
    int totalSets = exercise.sets ?? 1;
    List<String> repsList = exercise.reps?.split(RegExp(r'[:,/\-]+')) ?? [];

    bool isCompleted = completedSets != null && completedSets!.isNotEmpty;
    if (isFinishedEarly && completedSets != null) isCompleted = true;

    bool isFullyCompleted = !isFinishedEarly &&
        completedSets != null &&
        completedSets!.length >= totalSets;

    // فحص ذكي لنوع التمرين (مقاومة أم كارديو)
    bool isCardio = (exercise.category?.name.toLowerCase() == 'cardio') ||
        (exercise.duration != null && exercise.duration.toString().isNotEmpty && exercise.duration.toString() != "0");

    String targetDuration = exercise.duration ?? "1:00"; // الوقت الافتراضي للكارديو

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1️⃣ هيدر التمرين (الاسم + الصورة)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.2),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: AppColors.primaryBtn.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  exercise.category?.name ?? 'Exercise',
                                  style: const TextStyle(color: AppColors.primaryBtn, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 140, height: 140,
                          decoration: BoxDecoration(
                            color: isFullyCompleted ? Colors.green.withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: isFullyCompleted
                              ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60)
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: exercise.gifUrl ?? exercise.images.firstOrNull?.url ?? '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey.shade100),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 2️⃣ جدول الجولات (🔥 التصميم الجديد المُميز للـ UX 🔥)
                    ...List.generate(totalSets, (index) {
                      String targetRep = index < repsList.length ? repsList[index] : (repsList.isNotEmpty ? repsList.last : '10');

                      LoggedSetModel? loggedSet;
                      bool isSetLogged = false;
                      bool isSetSkipped = false;

                      if (completedSets != null && index < completedSets!.length) {
                        loggedSet = completedSets![index];
                        isSetSkipped = loggedSet.isSkipped;
                        isSetLogged = !isSetSkipped;
                      }

                      // تحديد الألوان بناءً على حالة السيت
                      Color bgColor = isSetLogged ? Colors.green.shade50 : (isSetSkipped ? Colors.grey.shade50 : Colors.white);
                      Color borderColor = isSetLogged ? Colors.green.shade200 : Colors.grey.shade200;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            // 🔢 رقم الجولة أو علامة الصح ✅
                            SizedBox(
                              width: 40,
                              child: isSetLogged
                                  ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28)
                                  : Column(
                                children: [
                                  Text("SET", style: TextStyle(fontSize: 10, color: isSetSkipped ? Colors.grey.shade400 : Colors.grey, fontWeight: FontWeight.bold)),
                                  Text("${index + 1}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isSetSkipped ? Colors.grey.shade400 : Colors.black87)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // 🎯 الهدف (Reps / Duration)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(isCardio ? "Target" : "Goal", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                      isCardio ? "$targetDuration Min" : "$targetRep Reps",
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isSetSkipped ? Colors.grey.shade400 : Colors.black87)
                                  ),
                                ],
                              ),
                            ),

                            // 📝 الإنجاز الفعلي (تم التمييز بشكل رائع)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(isSetLogged ? "You Did" : (isCardio ? "Actual" : "Weight"), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 4),

                                if (isSetLogged && loggedSet != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      isCardio ? "${loggedSet.reps} Min" : "${loggedSet.weight} kg",
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 14),
                                    ),
                                  )
                                else if (isSetSkipped)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                                    child: Text("Skipped", style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                                  )
                                else
                                  Container(
                                    width: 50, height: 28,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                    child: const Text("-", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // 3️⃣ أزرار الإجراءات السفلية
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (isFinishedEarly) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                    else if (isFullyCompleted) {
                      if (isLastExercise) {
                        // 🛑 السحر المعماري هنا لمنع مشكلة الكاش والتأخير واختفاء الداتا 🛑

                        // 1. إظهار دائرة تحميل شفافة لتمنع الانتقال قبل رد السيرفر
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppColors.primaryBtn)),
                        );

                        final workoutCubit = context.read<ActiveWorkoutCubit>();

                        // 🔥 أخذ نسخة احتياطية من البيانات "قبل" ما تتمسح من الذاكرة 🔥
                        final Map<int, List<LoggedSetModel>> savedSetsCopy = Map.from(workoutCubit.allLoggedSets);
                        final List<ExerciseModel> exercisesCopy = List.from(workoutCubit.exercises);

                        // 2. إجبار التطبيق ينتظر (await) حتى يختم السيرفر اليوم كلياً ويمسح الكاش
                        await workoutCubit.completeWorkout(
                          planId: planId,
                          planDayId: dayId,
                        );

                        // 3. إخفاء دائرة التحميل بعد تأكيد السيرفر
                        if (context.mounted) Navigator.pop(context);

                        // 4. الآن ننتقل لشاشة الملخص ونمرر لها "النسخ المحفوظة" بدلاً من الكيوبيت الممسوح!
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.workoutSummary,
                            arguments: {
                              'dayName': dayName,
                              'totalTime': workoutTimeStr ?? "00:00",
                              'totalExercises': exercisesCopy.length,
                              'exercises': exercisesCopy,
                              'allLoggedSets': savedSetsCopy,
                            },
                          );
                        }
                      } else {
                        // 🧠 اللوجيك الذكي للتمرين التالي
                        final workoutCubit = context.read<ActiveWorkoutCubit>();

                        int currentIndex = 0;
                        if (workoutCubit.state is ActiveWorkoutInProgress) {
                          currentIndex = (workoutCubit.state as ActiveWorkoutInProgress).currentIndex;
                        } else {
                          currentIndex = workoutCubit.exercises.indexOf(exercise);
                        }

                        if (currentIndex == -1) currentIndex = 0;
                        int nextIndex = currentIndex + 1;

                        final nextExercise = workoutCubit.exercises[nextIndex];
                        int nextTotalSets = nextExercise.sets ?? 1;

                        bool isNextAlreadyDone = workoutCubit.allLoggedSets.containsKey(nextIndex) &&
                            (workoutCubit.allLoggedSets[nextIndex]?.length ?? 0) >= nextTotalSets;

                        workoutCubit.nextExercise();

                        if (isNextAlreadyDone) {
                          bool isAbsoluteLast = (nextIndex == workoutCubit.exercises.length - 1);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: workoutCubit,
                                child: ExercisePreviewScreen(
                                  exercise: nextExercise,
                                  dayName: dayName,
                                  planId: planId,
                                  dayId: dayId,
                                  completedSets: workoutCubit.allLoggedSets[nextIndex],
                                  isLastExercise: isAbsoluteLast,
                                ),
                              ),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: workoutCubit,
                                child: ActivePlayScreen(dayName: dayName, planId: planId, dayId: dayId),
                              ),
                            ),
                          );
                        }
                      }
                    }
                    else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ActiveWorkoutCubit>(),
                            child: ActivePlayScreen(dayName: dayName, planId: planId, dayId: dayId,),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFinishedEarly ? const Color(0xFF1E293B) : AppColors.primaryBtn,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                      isFinishedEarly
                          ? "End Workout"
                          : isFullyCompleted
                          ? (isLastExercise ? "Finish Workout" : "Next Exercise")
                          : (isCompleted ? "Resume Exercise" : "Start"),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}