import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sportifo_app/core/theme/app_theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../workout/data/models/exercise_model.dart';
import '../view_model/active_workout_state.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final String dayName;
  final String totalTime;
  final int totalExercises;
  final List<ExerciseModel>? exercises;
  final Map<int, List<LoggedSetModel>>? allLoggedSets;

  const WorkoutSummaryScreen({
    super.key,
    required this.dayName,
    required this.totalTime,
    required this.totalExercises,
    this.exercises,
    this.allLoggedSets,
  });

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  // 🔥 متغير للتحكم بحالة التحميل للزر
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.workoutSummary,
          style: TextStyle(
            color: context.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // 🏆 كارت الإنجاز العلوي
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBtn.withOpacity(0.12),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primaryBtn,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.workoutCompleted,
                            style: TextStyle(
                              color: context.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${l10n.sessionSummaryFor} ${widget.dayName}.",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 📊 إحصائيات الوقت والتمارين
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.timer_outlined,
                      l10n.duration,
                      widget.totalTime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.fitness_center_rounded,
                      l10n.exercises,
                      "${widget.totalExercises}",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.performanceSummary,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 📋 قائمة تفاصيل التمارين
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.exercises?.length ?? 0,
                  itemBuilder: (context, index) {
                    final exercise = widget.exercises![index];
                    final loggedSets = widget.allLoggedSets?[index] ?? [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: TextStyle(
                              color: context.textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (loggedSets.isNotEmpty)
                            ...List.generate(loggedSets.length, (setIdx) {
                              final set = loggedSets[setIdx];
                              // 🔥 فحص ذكي: هل هذا كاردیو (weight = 0) ولا مقاومة
                              bool isCardio =
                                  set.weight == "0" || set.weight == "0.0";
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${l10n.set} ${setIdx + 1}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    set.isSkipped
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              l10n.skipped,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            isCardio
                                                ? "${set.reps} Min"
                                                : "${set.weight} ${l10n.kg}  ×  ${set.reps} ${l10n.reps}",
                                            style: const TextStyle(
                                              color: AppColors.primaryBtn,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                            ),
                                          ),
                                  ],
                                ),
                              );
                            })
                          else
                            Text(
                              l10n.noSetsLogged,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // 🔘 زر العودة (الذي يحتوي على السحر ✨)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  // منع الضغط المتكرر إذا كان في حالة تحميل
                  onPressed: _isSyncing
                      ? null
                      : () async {
                          setState(() {
                            _isSyncing = true;
                          });

                          // ⏳ لودينغ وهمي (أو انتظار للباك إند) لمدة ثانية ونصف ليعطي إحساس فخم للمتدرب
                          await Future.delayed(
                            const Duration(milliseconds: 1500),
                          );

                          if (mounted) {
                            // 🔥 السحر هنا: نرجع خطوتين لوراء بالـ Stack
                            // (عشان نتخطى شاشة "تفاصيل اليوم" ونوصل لشاشة "الأيام" مباشرة)
                            int count = 0;
                            Navigator.of(context).popUntil((_) => count++ >= 2);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBtn,
                    disabledBackgroundColor: AppColors.primaryBtn.withOpacity(
                      0.7,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSyncing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          l10n.done,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBtn, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: context.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
